package WWW::Webrobot::Print::Test;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use WWW::Webrobot::Util qw/textify/;
use Test::More qw/no_plan/;


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    return $self;
}

sub global_start {
    #my $self = shift;
}

sub item_pre {
    #my $self = shift;
    #my ($arg) = @_;
}

sub responses {
    my ($r) = @_;
    my @list = ();
    while (defined $r) {
        push @list, " "x8 . "$r->{_rc} $r->{_request}->{_uri}";
        $r = $r -> {_previous};
    }
    return @list;
}

sub bool_assert { $_[0] ? "FALSE" : "TRUE " }
sub bool { $_[0] ? "TRUE " : "FALSE" }

sub item_post {
    my ($self, $r, $arg) = @_;
    my $data = $arg->{data};
    my $out_ok = "$arg->{method} $arg->{url}";
    $out_ok .= " '$_'=>'$data->{$_}'" foreach (keys %$data);
    my $tmp = $arg->{fail_str};
    my $fail_str = (ref $tmp eq 'ARRAY') ? join("\n", @$tmp) : $tmp || "";
    if (! ok(! $arg->{fail}, textify $out_ok)) {
        diag " "x4 . textify "Request:     $arg->{method} $arg->{url}";
        diag " "x4 . textify "Description: $arg->{description}";
        if ($data && scalar keys %$data) {
            diag " "x4 . textify "Data:";
            diag " "x8 . textify "'$_' => '$data->{$_}'" foreach (keys %$data);
        }
        diag textify " "x4 . "Assertions:  " . bool_assert($arg->{fail});
        if (my $s = $fail_str) {
            $s =~ s/^(.)/ bool($1) /gme;
            $s =~ s/^/        /gm;
            diag textify $s;
        }
        diag " "x4 . textify "Responses:";
        diag textify($_) foreach (responses($r));
        if ($arg->{new_properties}) {
            diag " "x4 . textify "New properties:";
            diag " "x8 . textify "property '$_->[0]' => '$_->[1]'" foreach (@{$arg->{new_properties}});
        }
        if ($r && (my $c = $r->content)) {
            my $line = substr($c, 0, 132);
            diag " "x4 . textify "Content: [$line]" ;
        }
    }

}

sub global_end {
    #my $self = shift;
}

1;

=head1 NAME

WWW::Webrobot::Print::Test - write response content according to L<Test::More>

=head1 DESCRIPTION

This module adapts to L<Test::Harness>.

=head1 METHODS

See L<WWW::Webrobot::pod::OutputListeners>.

=over

=item WWW::Webrobot::Print::Test -> new ();

=back
