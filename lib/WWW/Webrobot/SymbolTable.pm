package WWW::Webrobot::SymbolTable;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Carp;


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    $self->{_symbols} = {};
    $self->{_scope}   = [{}];
    return $self;
}

sub push_scope {
    my ($self) = @_;
    push @{$self->{_scope}}, {};
}

sub pop_scope {
    my ($self) = @_;
    my $scope = $self->{_scope};
    my $symbols = $self->{_symbols};

    foreach (keys %{$scope->[-1]}) {
        pop @{$symbols->{$_}};
        delete $symbols->{$_} if scalar @{$symbols->{$_}} == 0;
    }
    pop @$scope;
}

sub define_symbol {
    my ($self, $l, $r) = @_;
    my $symbols = $self->{_symbols};
    my $last_scope = $self->{_scope}->[-1];
    # was: my $entry = [$l, $r || "", qr/(?<!\\){$l}/];
    my $entry = $r || "";

    if ($last_scope->{$l}) { # entry exists in last scope, overwrite
        $symbols->{$l}->[-1] = $entry;
    }
    else { # no entry yet
        $last_scope->{$l} = 1;
        push @{$symbols->{$l}}, $entry;
    }
}

# private
sub _evaluate_string {
    my ($self, $str) = @_;
    return undef if !defined $str;
    my $symbols = $self->{_symbols};
    $str =~ s/ \${ ([^}]+) } / $symbols->{$1} ? $symbols->{$1}->[-1] : "\${$1}" /gex;
    return $str;
}

sub evaluate {
    my ($self, $entry) = @_;
    SWITCH: foreach (ref $entry) {
        /^HASH$/ and do {
            foreach my $key (keys %$entry) {
                # substitute value
                if (ref $entry->{$key}) {
                    $self -> evaluate($entry->{$key});
                }
                else {
                    my $tmp = $entry->{$key};
                    $self -> evaluate(\$tmp);
                    $entry->{$key} = $tmp;
                }

                # substitute key
                my $nkey = $key;
                $self -> evaluate(\$nkey);
                if ($key ne $nkey) {
                    $entry->{$nkey} = delete $entry->{$key};
                }
            }
            last;
        };
        /^ARRAY$/ and do {
            foreach my $e (@$entry) {
                $self -> evaluate((ref $e) ? $e : \$e);
            }
            last;
        };
        /^SCALAR$/ and do {
            $$entry = $self->_evaluate_string($$entry);
            last;
        };
        /^$/ and do {
            $entry = $self->_evaluate_string($entry);
            last;
        }
        # ??? missing error handling
        # my $ref = ref $entry;
        # die "ARRAY or HASH expected, found $ref";
    }
    return $entry;
}


1;
