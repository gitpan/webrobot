package WWW::Webrobot::XML2Tree;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG

=head1 NAME

WWW::Webrobot::XML2Tree - wrapper for L<XML::Parser>

=cut

use XML::Parser;


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    $self->{parser} = new XML::Parser(Style => 'Tree', ErrorContext => 5);
    #$self->{u2i} = Unicode::Lite::convertor('utf8', 'latin1') if $has_converter;
    return $self;
}

sub parsefile {
    my ($self, $file) = @_;
    my $tree = $self->{parser}->parsefile($file);
    return $self->_parse0($tree);
}

sub parse {
    my ($self, $string) = @_;
    my $tree = $self->{parser}->parse($string);
    return $self->_parse0($tree);
}

sub _parse0 {
    my ($self, $tree) = @_;
    unshift @$tree, {};
    _delete_white_space($tree);
    #$self->_utf2isolatin($tree) if $has_converter;
    #use Data::Dumper; print "DUMP: ", Dumper($tree);
    return $tree;
}


sub _delete_white_space {
    my ($tree) = @_;
    return _delete_white_space($tree->[1]) if scalar @$tree == 2; # root is special

    # Note: scalar @$tree % 2 == 1
    for (my $i = scalar @$tree; $i > 1; $i-=2) {
        if (! $tree->[$i-2] && $tree->[$i-1] =~ m/^\s*$/s) {
            splice(@$tree, $i-2, 2);
        }
        elsif (ref $tree->[$i-1]) {
            _delete_white_space($tree->[$i-1]);
        }
    }
}

#sub _utf2isolatin {
#    my ($self, $tree) = @_;
#    return $self->_utf2isolatin($tree->[1]) if scalar @$tree == 2; # root is special
#
#    # Note: scalar @$tree % 2 == 1
#    for (my $i = scalar @$tree; $i > 1; $i-=2) {
#        if (! $tree->[$i-2]) {
#            $tree->[$i-1] = $self->{u2i}->($tree->[$i-1]);
#        }
#        elsif (ref $tree->[$i-1]) {
#            $tree->[$i-2] = $self->{u2i}->($tree->[$i-2]); # convert tag
#            $self->_utf2isolatin($tree->[$i-1]); # recurse (content)
#        }
#        else {
#            die "NO REF";
#        }
#    }
#    my $attr = $tree->[0];
#    foreach (keys %$attr) {
#        $attr->{$_} = $self->{u2i}->($attr->{$_});
#    }
#}


1;
