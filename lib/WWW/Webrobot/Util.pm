package WWW::Webrobot::Util;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Exporter;
use base qw/Exporter/;
our @EXPORT_OK = qw/ascii textify/;


=head1 NAME

WWW::Webrobot::Util - some simple utilities

=head1 SYNOPSIS

 WWW::Webrobot::Util::ascii("a\x{76EE}b");

=head1 DESCRIPTION

Some simple utility functions.

=head1 METHODS

=cut

sub _encode_text {
    my ($fun) = shift;
    if (wantarray) {
        return map {$fun->($_)} @_;
    }
    else {
        return join "", map {$fun->($_)} @_;
    }
}

=over

=item ascii

encode all multi-byte and control characters in printable form

=back

=cut

sub ascii {
    _encode_text(sub {
        join("",
            map {
                $_ > 255 ?                      # if wide character...
                    sprintf("\\x{%04X}", $_)    #     \x{...}
                : chr($_) =~ /[[:cntrl:]]/ ?    # else if control character ...
                    sprintf("\\x%02X", $_)      #     \x..
                :                               # else
                    chr($_)                     #     as themselves
            } unpack("U*", $_[0])
        );
    },
    @_);
}

=over

=item textify

encode all multi-byte characters in printable form

=back

=cut

sub textify {
    _encode_text(sub {
        join("",
            map {
                $_ > 255 ?                      # if wide character...
                    sprintf("\\x{%04X}", $_)    #     \x{...}
                :                               # else
                    chr($_)                     #     as themselves
            } unpack("U*", $_[0])
        );
    },
    @_);
}


1;
