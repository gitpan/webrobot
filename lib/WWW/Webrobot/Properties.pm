package WWW::Webrobot::Properties;
use strict;
use warnings;

use Carp;


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    my %parm = (@_); # accept parameter list as hash

    # check for duplicates in 'listmode'
    my %listmode = ();
    foreach (@{$parm{listmode}}) {
        croak "'$_' defined twice in 'listmode'" if $listmode{$_}++;
    }

    # check for duplicates in 'key_value' and 'multi_value'
    my %duplicate;
    foreach ((@{$parm{key_value}}, @{$parm{multi_value}})) {
        croak "'$_' defined twice in 'key_value' or 'multi_value'" if $duplicate{$_}++;
        # add key_value/muli_value items to listmode if not already specified
        push @{$parm{listmode}}, $_ if ! $listmode{$_}++;
    }
    $self->{_listmode} = $parm{listmode} if defined $parm{listmode};
    $self->{_listmode_hash} = \%listmode if defined $parm{listmode};
    $self->{_key_value} = $parm{key_value} if defined $parm{key_value};
    $self->{_multi_value} = $parm{multi_value} if defined $parm{multi_value};
    $self->{_structurize} = $parm{structurize} if defined $parm{structurize};
    return $self;
}

sub property {
    my ($self, $name, $value) = @_;
    $self->{prop}->{$name} = $value if defined $value; # setter
    return $self->{prop}->{$name} if defined $name; # setter/getter
    return $self->{prop}; # return hash of properties
}

sub clear_properties {
    my ($self) = @_;
    $self->{prop} = {};
    if ($self->{_listmode}) {
        foreach (@{$self->{_listmode}}) {
            $self->property($_, []);
        }
    }
}

sub make_key_value {
    my $self = shift;
    foreach my $prop (@{$self->{_key_value}}) {
        my %hash = ();
        foreach my $elem (@{$self->{prop}->{$prop}}) {
            my ($key, $value) = split /\s*=\s*/, $elem, 2;
            $hash{$key} = $value;
        }
        $self->{prop}->{$prop} = \%hash;
    }
}

sub make_multi_value {
    my $self = shift;
    foreach my $prop (@{$self->{_multi_value}}) {
        foreach my $elem (@{$self->{prop}->{$prop}}) {
            my ($split_char, $rest) = $elem =~ /^(.)(.*)$/;
            $split_char = quotemeta $split_char;
            my @list = split /$split_char/, $rest;
            $elem = \@list;
        }
    }
}

sub structurize {
    my $self = shift;
    foreach my $prop (@{$self->{_structurize}}) {
        foreach (keys %{$self->{prop}}) {
            my ($end) = /^$prop\.(.*)$/;
            if ($end) {
                $self->{prop}->{$prop}->{$end} = $self->{prop}->{$_};
                delete $self->{prop}->{$_};
            }
        }
    }
}

# private
sub load {
    my ($self, $input, $cmd_properties) = @_;
    croak "No handle specified" if !defined $input;
    $self->clear_properties();
    my $p = "";
    while (defined $input->()) {
        chomp;
        if (m/.*\\$/) {
            chop;
            $p .= $_;
            next;
        }
        if ($p) {
            s/^\s*//;
            $_ = $p . $_;
            $p = "";
        }

        next if /^\s*[#!]/ || /^\s*$/; # skip comment, lines containing white space only
        s/(\\ |[^\s\\])\s+$/$1/; # skip trailing white space except '\ ' and '\'
        my ($key, $tmp0, $tmp1, $value) = /^\s*(([^=: ])+)\s*([=:])?\s*(.*)$/;
        (my $new_key = $key) =~ s/^(.*)\.\d+$/$1/;
        $key = $new_key if $self->{_listmode_hash}->{$new_key};
        $value = "" if !defined $value;

        if (ref $self->property($key) eq 'ARRAY') {
            push @{$self->property($key)}, $value;
        }
        else {
            $self->property($key, $value);
        }
    }

    $self->property(@$_) foreach (@$cmd_properties);
    $self->make_key_value();
    $self->make_multi_value();
    $self->structurize();
    unescape($self->{prop});
    return $self->{prop};
}

sub unescape0 {
    my ($prop) = @_;
    $prop =~ s/\\n/\n/g;
    $prop =~ s/\\r/\t/g;
    $prop =~ s/\\t/\t/g;
    $prop =~ s/\\(["' ])/$1/g;
    # \uxxxx not implemented
    return $prop;
}

sub unescape {
    my ($prop) = @_;
    #return if ! defined $prop;
    if (ref $prop eq 'ARRAY') {
        foreach (@$prop) {
            if (ref) {
                unescape($_);
            }
            else {
                $_ = unescape0($_);
            }
        }
    }
    elsif (ref $prop eq 'HASH') {
        foreach (keys %$prop) {
            my $value = $prop->{$_};
            if (ref $value) {
                unescape($value);
            }
            else {
                $prop->{$_} = unescape0($value);
            }
        }
    }
    else {
        die "ARRAY, HASH or scalar expected";
    }
}

sub load_string {
    my ($self, $string, $cmd_properties) = @_;
    return $self->load(sub {
        (my $str, $string) = $string =~ m/^([^\n]*)\n(.*)$/s;
        return $_ = $str;
    }, $cmd_properties);
}

sub load_handle {
    my ($self, $handle, $cmd_properties) = @_;
    return $self->load(sub {$_ = <$handle>; return $_;}, $cmd_properties);
}

sub load_file {
    my ($self, $filename, $cmd_properties) = @_;
    local *HANDLE;
    open HANDLE, "<$filename" or croak "Can't open $filename: $!";
    my $cfg = $self->load_handle(*HANDLE, $cmd_properties);
    close HANDLE;
    return $cfg;
}

1;

=head1 NAME

WWW::Webrobot::Properties - Implements a subset of Java Properties

=head1 SYNOPSIS

    my $config = WWW::Webrobot::Properties->new(
        listmode => [qw(names auth_basic output http_header proxy no_proxy)],
        key_value => [qw(names http_header proxy)],
        multi_value => [qw(auth_basic)],
        structurize => [qw(load mail)],
    );
    my $cfg = $config->load_file($cfg_name, $cmd_param);


=head1 DESCRIPTION

This class implements a subset of Java Properties, see
L<http:E<sol>E<sol>java.sun.comE<sol>j2seE<sol>1.3E<sol>docsE<sol>apiE<sol>javaE<sol>utilE<sol>Properties.html>
for more docs.

=head2 NOT IMPLEMENTED

 \uxxxx  Unicode characters

=head2 EXTENDED FORMAT

Listmode properties may be written

 listprop=value0
 listprop=value1
 listprop=value2

or

 listprop.0=value0
 listprop.1=value1
 listprop.2=value2



=head1 METHODS

=over

=item $wr = WWW::Webrobot::Properties -> new(%options);

Construct an object.
Options marked (F) affect the semantics of the properties format.
All options affect the internal representation.

 listmode => [...]    F  Multiple definitions enforce an array of options.
                         Multiple definition options may (but needn't) be
                         written with additional digits.
                         'names.1=xxx names.27=yyy ...'
 key_value => [...]   F  Option value as 'key=value' deparsed.
 multi_value => [...] F  Option value as '/v0/v1/v2/v3...' deparsed as array
                         / is any literal character
 structurize => [...] -  Common prefix options deparse as array, e.g.
                         'load.num=xx load.base=yy' yields
                         'load => {num => "xx", base => "yy"}'

For a complete guide of the semantics of the options
see the test L<t/t.properties.t>.

=back

