package WWW::Webrobot::WebrobotLoad;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use WWW::Webrobot;
use WWW::Webrobot::Global;
use WWW::Webrobot::Forker;
use WWW::Webrobot::Statistic;
use WWW::Webrobot::Histogram;
use WWW::Webrobot::Print::ChildSend;


=head1 NAME

WWW::Webrobot::WebrobotLoad - Run testplans with multiple clients

=head1 SYNOPSIS

    my $cfg = WWW::Webrobot -> read_configuration($cfg_name, $cmd_param);
    my $wrl = WWW::Webrobot::WebrobotLoad->new();
    my ($statistic, $histogram, $url_statistic, $http_errcode, $assert_ok) =
        $wrl -> run($cfg, $testplan_name);

=head1 DESCRIPTION

Runs multiple clients.

[missing documentation]
Look into the sources L<webrobot-load>.

=head1 METHODS

=over

=item $wr = WWW::Webrobot::WebrobotLoad -> new( );

Construct an object.

=cut

sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    WWW::Webrobot::Global->save_memory(1);
    return $self;
}


=item ($statistic, $histogram, $url_statistic, $http_errcode, $assert_ok) = run($cfg, $testplan_name);

Run a test.

B<INPUT VARIABLES:>

=over

=item $cfg

Config, see L<WWW::Webrobot::pod::Config>

=item $testplan_name

Name of the testplan

=back

B<OUTPUT VARIABLES:>

=over

=item $statistic

see L<WWW::Webrobot::Statistic>

=item $histogram

see L<WWW::Webrobot::Histogram>

=item $url_statistic

=item $http_errcode

=item $assert_ok

=back

=cut

sub run {
    my ($self, $cfg, $testplan_name) = @_;

    my $statistic = WWW::Webrobot::Statistic -> new(extended => 1);
    my $histogram = WWW::Webrobot::Histogram -> new(base => $cfg->{load}->{base} || 2);
    my $url_statistic = {};
    my $http_errcode = {};
    my $assert_ok = [];
    my $forker = WWW::Webrobot::Forker -> new();
    $forker -> fork_children($cfg->{load}->{number_of_clients}, child($cfg, $testplan_name));
    $forker -> eventloop(parent($statistic, $histogram, $url_statistic, $http_errcode, $assert_ok));
    return ($statistic, $histogram, $url_statistic, $http_errcode, $assert_ok);
}

sub child {
    my ($cfg, $testplan_name) = @_;
    my $webrobot = WWW::Webrobot -> new($cfg);
    return sub {
        my ($child_id) = @_;
        my $exit = $webrobot -> run($testplan_name);
    }
}


sub parent {
    my ($statistic, $histogram, $url_stat, $http_errcode, $assert_ok) = @_;
    return sub {
        my ($child_id, $line) = @_;
        my ($cmd, $rest) = split /\s+/, $line, 2;
        if ($cmd eq "TIME") {
            my ($float, $fail,  $errcode,$method, $url) = split /\s+/, $rest, 5;
            $statistic -> add($float);
            $histogram -> add($float);
            $url_stat->{$url} = WWW::Webrobot::Statistic->new() if !defined $url_stat->{$url};
            $url_stat->{$url} -> add($float);
            $http_errcode->{$errcode}++;
            $assert_ok->[$fail]++;
            printf "T%02d %6.3f %3d %s\n", $child_id, $float, $errcode, $url;
        }
        else {
            print "*** UNKNOWN COMMAND: $child_id $line\n";
            #die;
        }
    }
}


=back

=head1 SEE ALSO

L<webrobot-load>

L<webrobot>

L<WWW::Webrobot::pod::Config>

L<WWW::Webrobot::pod::Testplan>

=cut

1;
