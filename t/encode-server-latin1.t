#!/usr/bin/perl -w
use strict;
use warnings;

use WWW::Webrobot::SelftestRunner qw(RunTestplan HttpdEcho Config);

MAIN: {
    exit RunTestplan(HttpdEcho(charset=>"iso-8859-1"),
        Config(qw/Test/) . "names=umlauta=\%E4\n",
        \"t/encode/plan-umlaut.xml"
    );
}
