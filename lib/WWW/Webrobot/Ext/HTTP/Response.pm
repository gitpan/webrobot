package WWW::Webrobot::Ext::HTTP::Response;
use strict;
use warnings;


# extend LWPs HTTP::Response without subclassing
package HTTP::Response;
use strict;

sub elapsed_time {
    my ($self, $value) = @_;
    $self->{_elapsed_time} = $value if defined $value;
    return $self->{_elapsed_time} || 0;
}

1;
