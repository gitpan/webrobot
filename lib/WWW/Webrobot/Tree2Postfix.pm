package  WWW::Webrobot::Tree2Postfix;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Data::Dumper;


sub _init {
    my ($self, $op, $attr_op, $attr_fun) = @_;
    $self->{$attr_op} = $op;
    $self->{$attr_fun} = sub {
        my ($operator) = @_;
        return $op -> {$operator} || sub {
            die "Operator <$operator> not allowed";
            # croak!
        }
    };
}

sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    my ($unary_op, $binary_op, $predicate) = @_;
    $self->_init($unary_op, "unary_op", "unary_fun");
    $self->_init($binary_op, "binary_op", "binary_fun");
    $self->_init($predicate, "predicate", "predicate_fun");
    return $self;
}

sub tree2postfix {
    my ($self, $tree) = @_;
    $self->{postfix} = [];
    my ($attributes, $tag, $content) = splice(@$tree, 0, 3);
    $self->tree2postfix0($attributes, $tag, $content);
    die "only one predicate allowed at this place: <$tag>" if @$tree;
    #return $self->{postfix};
}

sub tree2postfix0 {
    my ($self, $p_attributes, $p_tag, $p_content) = @_;
    #print "ATT,TAG,CONTENT: $p_attributes, $p_tag, $p_content\n";
    #print Dumper($p_content);
    die "missing predicate" if ! $p_tag;
    if ($self->{binary_op}->{$p_tag}) {
        my ($attributes, $tag, $content) = splice(@$p_content, 0, 3);
        $self->tree2postfix0($attributes, $tag, $content);
        while (scalar @$p_content) {
            ($tag, $content) = splice(@$p_content, 0, 2);
            $self->tree2postfix0($attributes, $tag, $content);
            push @{$self->{postfix}}, $p_tag;
        }
    }
    elsif ($self->{unary_op}->{$p_tag}) {
        my ($attributes, $tag, $content) = splice(@$p_content, 0, 3);
        $self->tree2postfix0($attributes, $tag, $content);
        push @{$self->{postfix}}, $p_tag;
        die "only one predicate allowed at this place: <$tag>" if @$p_content;
    }
    else {
        push @{$self->{postfix}}, [$p_tag, $p_content];
    }
}


sub eval_postfix {
    my ($self, $r) = @_;
    my @stack = ();
    my @error = ();
    foreach my $entry (@{$self->{postfix}}) {
        if (ref $entry eq 'ARRAY') {
            my ($tag, $content) = @$entry;
            my $value = $self->{predicate_fun} -> ($tag) -> ($r, $content->[0]);
            my $stringified = do {
                my $dump = Data::Dumper->new([$content->[0]]);
                $dump->Indent(0);
                (my $tmp = $dump->Dump) =~ s/\$VAR1 *//;
                $tmp;
            };
            push(@error, "$value <$tag> $stringified");
            push @stack, $value;
        }
        elsif (!ref $entry) {
            my $operator = $entry;
            if ($self->{unary_op}->{$operator}) {
                my $operand = pop @stack;
                my $result = $self -> {unary_fun} -> ($entry) -> ($operand);
                push @stack, $result;
            }
            elsif ($self->{binary_op}->{$operator}) {
                my $op1 = pop @stack;
                my $op0 = pop @stack;
                my $result = $self -> {binary_fun} -> ($entry) -> ($op0, $op1);
                push @stack, $result;
            }
            else {
                die "Operator <$operator> not implemented";
            }
        }
        else {
            die "Programmer error: Predicate (ARRAY) or operator (scalar) expected";
        }
    }

    my $result = pop @stack;
    die "Stack not empty after evaluation, stack = " . Dumper(\@stack) if @stack;
    return ($result, \@error);
}

sub postfix {
    my ($self) = @_;
    return $self->{postfix};
}


1;

