package WWW::Webrobot::SymbolTable;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Carp;


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    $self->{_symbols} = [];
    $self->{_scope}   = [];
    return $self;
}

sub push_scope {
    my ($self) = @_;
    push @{$self->{_scope}}, scalar @{$self->{_symbols}};
}

sub pop_scope {
    my ($self) = @_;
    my $new_size = pop @{$self->{_scope}} or croak "Can't pop empty stack";
    pop @{$self->{_symbols}} while @{$self->{_symbols}} > $new_size;
}

sub push_symbol {
    my ($self, $l, $r) = @_;
    push @{$self->{_symbols}}, [$l, $r || "", qr/(?<!\\){$l}/];
}

sub evaluate {
    my ($self, $str) = @_;
    return undef if !defined $str;
    foreach (@{$self->{_symbols}}) {
        my ($l, $r, $l_qr) = @$_;
        $str =~ s/$l_qr/$r/g;
    }
    $str =~ s/\\(.)/$1/g; # delete backslash-escaping
    return $str;
}


1;
