package WWW::Webrobot::Print::Null;
use base "WWW::Webrobot::Print::Util::Base";
use strict;
use warnings;

=head1 NAME

WWW::Webrobot::Print::Null - Zero response output listener

=head1 DESCRIPTION

This module does nothing.
It is the default output listener.

=head1 METHODS

See L<WWW::Webrobot::pod::OutputListeners>.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = $class -> SUPER::new();
    bless ($self, $class);
    return $self;
}

sub global_start {}
sub item_pre {}
sub item_post {}
sub global_end {}

1;
