package WWW::Webrobot::AssertDefault;
use strict;
use warnings;


sub new {
    my ($class) = shift;
    my $self = bless({}, ref($class) || $class);
    return $self;
}

sub check {
    my ($self, $r) = @_;
    return undef if !defined $r;
    return (200 <= $r->{_rc} && $r->{_rc} < 300) ? 0 : 1;
}


1;
