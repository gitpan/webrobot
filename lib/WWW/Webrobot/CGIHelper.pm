package WWW::Webrobot::CGIHelper;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use CGI;

sub param2list {
    my ($cgi, $exclude) = @_;

    my @cmd_param = ();
    FOR: foreach my $key ($cgi->param()) {
        foreach (@$exclude) {
            next FOR if $key =~ /^$_$/;
        }
        push @cmd_param, [$key, $_] foreach (my @value = $cgi->param($key));
    }
    return \@cmd_param;
}

1;
