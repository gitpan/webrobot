#!/usr/bin/perl
use strict;
use warnings;

use ExtUtils::MakeMaker;


BEGIN {
    require 5.006_001;
    # eval { require File::Spec };
    # $@  and  die "You need to install the File::Spec module first!\n";
    # if(($File::Spec::VERSION || 0) < 0.8) {
    #     die "You need at least version 0.8 of the File::Spec module!\n";
    # }
}

WriteMakefile(
    NAME         => 'WWW::Webrobot',
    VERSION_FROM => 'lib/WWW/Webrobot.pm', # finds $VERSION
    AUTHOR       => 'StefanTrcek (webrobot@abas.de)',
    ABSTRACT     => 'Automated HTTP requests',
    PREREQ_PM    => {

                     'Test::More' => 0,
                     'Bundle::LWP' => 0,
                     'HTML::TreeBuilder' => 0,
                     # 'HTML::Tagset' => 0,
                     'XML::Parser' => 0,
                     'XML::XPath' => 0,
                     'Time::HiRes' => 0,

                     'Unicode::Lite' => 0,
                     # used by Unicode::Lite
                     #'Clone' => 0,
                     # enum => 0,
                     # Unicode::String;
                     # Unicode::Map;
                     # MIME::Lite;


                     # module by LWP
                     # URI
                     # MIME-Base64-2.12.tar.gz
                     # Digest-MD5-2.20.tar.gz
                     # HTML::Parser
                     # ??? libnet-1.12.tar.gz

                     # OPTIONAL 'MIME::Lite' => 0,
                     # OPTIONAL 'Crypt::SSLeay' => 0,
                    },
    DISTNAME => "webrobot",
    EXE_FILES      => [qw(
        bin/webrobot
        bin/webrobot-load
        bin/xpath-shell
        bin/webrobot-gen-plan
     )],

);
