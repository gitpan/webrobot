#!/usr/bin/perl -w
use strict;
use warnings;

use WWW::Webrobot::SelftestRunner qw(RunTestplan HttpdEcho Config);

MAIN: {
    exit RunTestplan(HttpdEcho(charset=>"utf-8"),
        Config(qw/Test/),
        \"t/encode/plan-assert-chinese.xml"
    );
}
