package WWW::Webrobot::Print::Text;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Data::Dumper;


sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = bless({}, ref($class) || $class);
    my %parm = (@_);

    $self -> {summary} = defined $parm{summary} ? $parm{summary} : 0;
    $self -> {format} = defined $parm{format} ? $parm{format} : 1;
    $self -> {failed} = [];
    bless ($self, $class);
    return $self;
}

sub global_start {
    my $self = shift;
}

sub item_pre {
    my $self = shift;
    my ($arg) = @_;
    my $url = $arg->{url};
    my $url_out = ref($url) ? Dumper($url) : ($url || "");
    my $points = $arg->{is_recursive} ? "... " : "";
    ($self -> {format} > 0) && print "$points$arg->{method} $url_out\n";
}

my @fail_str = ("ok     ", "fail   ", "invalid");
my @fail_str_long = ("Ok", "FAILED", "INVALID");

sub item_post {
    my ($self, $r, $arg) = @_;
    my $last_errcode = "  -";
    foreach ($self -> stack_responses($r)) {
	print $self->response2string($_), "\n" if $self->{format} > 0;
	$last_errcode = $_->{_rc};
    }
    if ($self -> {format} > 0) {
	print " "x8, $fail_str_long[$arg->{fail}], ": ",
	$arg->{description} || "No description", "\n";
    }
    else {
        print $fail_str[$arg->{fail}], " $last_errcode ",
        $arg->{method}, " ", $arg->{url}, "\n";
    }
    push @{$self -> {failed}}, $arg if $arg->{fail};
}

sub global_end {
    my $self = shift;
    if ($self -> {summary}) {
	if (scalar @{$self -> {failed}} == 0) {
	    print "Es sind keine Fehler aufgetreten.\n";
	}
	else {
	    print "\n", "Fehlerliste:\n", "------------\n";
	    foreach my $arg (@{$self -> {failed}}) {
		print $fail_str[$arg->{fail}], ": ", $arg->{method}, " ", $arg->{url}, "\n";
	    }
	}
    }
}


# private
sub stack_responses {
    my ($self, $r) = @_;
    my @seq = ();
    while (defined($r)) {
        unshift(@seq, $r);
        $r = $r -> {'_previous'};
    }
    return @seq;
}

# private
sub response2string {
    my ($self, $r) = @_;
    return "" if !defined($r);
    return " " x 8,
        $r -> {_rc}, " ",
        $r -> {_request} -> {_method}, " ",
        $r -> {_request} -> {_uri}, " (",
        $r -> {_msg}, ")";
}


1;

=head1 NAME

WWW::Webrobot::Print::Text - write response content to STDOUT

=head1 DESCRIPTION

This module writes requests and part of the response to STDOUT.

You may consider to use L<WWW::Webrobot::Print::Test> instead.

=head1 METHODS

See L<WWW::Webrobot::pod::OutputListeners>.

=over

=item WWW::Webrobot::Print::Text -> new(%parameters)

 Parameters     Description
 ================================================================
 summary (0|1)  add a summary of failed request at the end
 format (0|1)   select output details
                0: only final response for any request
                1: all requests and responses for any request
                   This affects redirections and authentification

=back
