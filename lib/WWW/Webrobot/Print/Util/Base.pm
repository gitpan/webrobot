package WWW::Webrobot::Print::Util::Base;
use strict;
use warnings;

=head1 NAME

WWW::Webrobot::Print::Util::Base - base class for output listeners

=head1 DESCRIPTION

This is a base class aka function library for the
output listeners in WWW::Webrobot::Print.

=over

=item WWW::Webrobot::Print::Util::Base -> new ()

Constructor.
This is a helper class only to derive from.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless ($self, $class);
    return $self;
}

=item $obj -> stack_responses ($request)

Return codes 3xx and 4xx may implicitly lead to further requests,
chained in a list via the C<_previous> attribute.
This method converts a chained response into an array
with the final request at index zero.

=cut

sub stack_responses {
    my ($self, $r) = @_;
    my @seq = ();
    while (defined($r)) {
	unshift(@seq, $r);
	$r = $r -> {'_previous'};
    }
    return @seq;
}

=item $obj -> response2string ($r)

This method converts a response somehow into a string.

=cut

sub response2string {
    my ($self, $r) = @_;
    return "" if !defined($r);
    return " " x 8,
	$r -> {_rc}, " ",
	$r -> {_request} -> {_method}, " ",
	$r -> {_request} -> {_uri}, " (",
	$r -> {_msg}, ")";
}

=back

=cut

1;
