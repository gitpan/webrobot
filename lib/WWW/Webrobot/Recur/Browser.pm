package WWW::Webrobot::Recur::Browser;
use WWW::Webrobot::HtmlAnalyzer;
use strict;

=head1 NAME

WWW::Webrobot::Recur::Browser - act like a browser when selecting a url

=head1 SYNOPSIS

see L<WWW::Webrobot::pod::Testplan>

=head1 DESCRIPTION

This module allows to load an HTML page,
all contained frames (recursivly)
and all images.

=head1 METHODS

=over

=item Testplan -> new (%parms)

Constructor.
The parameters are given as hash.

Parameters:

=over

=item url_rejected

A function to show rejected urls.,
mainly for debugging purpose.
        Input: $url [string]
        Output: 0 | 1

=item url_accepted

A function to show accepted urls,
mainly for debugging purpose.
        Input: $url [string]
        Output: 0 | 1

=back

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %parm = (@_);
    my $self  = {
	frame      => [],
        img        => [],
	seen       => {},
	visited    => {},
	url_rejected => $parm{url_rejected} || sub {},
	url_accepted => $parm{url_accepted} || sub {},
    };
    bless ($self, $class);
    return $self;
}


=item $obj -> next ($r)

See L<WWW::Webrobot::pod::Recur/item_next>

=cut

sub next {
    my $self = shift;
    my ($r) = @_;
    my $in = $r -> {'_content'};
    my $uri = $r -> {_request} -> {_uri};
    if ($self -> is_type("text/html", $r->{_headers}->{'content-type'})) {
	# nur in einer HTML-Seite gibt es neue Links
	my ($img, $frame, $a, $refresh) = WWW::Webrobot::HtmlAnalyzer -> get_links($uri, \$in);
	($img, $frame) = $self -> only_allowed($img, $frame);
	push @{$self -> {img}}, @$img;
	push @{$self -> {frame}}, @$frame;
    }
    my $e = $self -> next_link($self->{img}, $self->{frame});
    $self -> {visited} -> {$e} = 1 if defined $e;
    return $e;
}


sub is_type {
    my $self = shift;
    my ($match, $obj) = @_;
    return 0 if !defined $obj;
    $obj = [$obj] if !ref($obj);
    foreach (@$obj) {
	return 1 if m/$match/;
    }
    return 0;
}


=item $obj -> allowed ($url)

See L<WWW::Webrobot::pod::Recur/item_allowed>

=cut

sub allowed {
    my ($self, $uri) = @_;
    return 1;
}


sub only_allowed {
    my $self = shift;
    my @ret = ();
    foreach my $array (@_) {
	# hier in $array die unerlaubten Verweise löschen
	my @new = ();
	foreach (@$array) {
	    if (!defined($self -> {seen} -> {$_})) { # Link noch nicht gesehen
		$self -> {seen} -> {$_} = 1;
		if ($self -> allowed($_)) {
		    push @new, $_;
		    $self -> {url_accepted} -> ($_);
		}
		else {
		    $self -> {url_rejected} -> ($_);
		}
	    }
	}
        push @ret, \@new;
    }
    return @ret;
}


sub next_link {
    my $self = shift;
    foreach my $array (@_) {
        my $n = shift @$array;
	return $n if defined $n;
    }
    return undef;
}

=back

=cut

1;
