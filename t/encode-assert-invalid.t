#!/usr/bin/perl -w
use strict;
use warnings;

use WWW::Webrobot::SelftestRunner qw(RunTestplan HttpdEcho Config);

MAIN: {
    exit RunTestplan(HttpdEcho(charset=>"invalid-charset"),
        Config(qw/Test/),
        \"t/encode/plan-assert-invalid.xml"
    );
}
