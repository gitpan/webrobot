package WWW::Webrobot::UserAgentConnection;
use strict;
use warnings;

use HTTP::Cookies;
use HTTP::Request::Common;
use Time::HiRes;

use WWW::Webrobot::MyUserAgent;
use WWW::Webrobot::Ext::General::HTTP::Response;


=head1 NAME

WWW::Webrobot::UserAgentConnection - create and configure a user agent

=head1 SYNOPSIS

 WWW::Webrobot::UserAgentConnection -> new($cfg, user => $user);

=head1 DESCRIPTION

Helper class.

=head1 METHODS

=over

=item WWW::Webrobot::UserAgentConnection -> new ($cfg, %opt)

 $cfg
        Config, see L<WWW::Webrobot::pod::Config>
 %opt
        user => "an id for a user agent"

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my ($cfg, %opt) = @_;

    my $str_agent = "Webrobot " . $WWW::Webrobot::VERSION;
    $str_agent .= " - $opt{user}" if $opt{user} ne "";

    # setup user agent
    my $cookie_jar = HTTP::Cookies -> new(File => "cookies_.txt", AutoSave => 0);
    my $ua = WWW::Webrobot::MyUserAgent -> new();
    $ua -> cookie_jar($cookie_jar);
    foreach (keys %{$cfg -> {proxy}}) {
        if (/^https$/) {
            # OpenSSL's proxy handling is incompatible to LWP's proxy handling
            my $https_proxy = $cfg->{proxy}->{$_};
            # yet more incompatible: remove trailing slash, bug in Crypt::SSLeay
            $https_proxy =~ s,/$,,;
            $ENV{HTTPS_PROXY} = $https_proxy;
        }
        else {
            $ua -> proxy($_, $cfg -> {proxy} -> {$_});
        }
    }
    $ua -> no_proxy(@{$cfg -> {no_proxy}}) if $cfg -> {no_proxy};
    $ua -> timeout($cfg -> {timeout} || 30);
    $ua -> agent($str_agent);
    $ua -> set_basic_realm($cfg -> {auth_basic}) if $cfg -> {auth_basic};
    $ua -> client_302_bug(1) if $cfg->{client_302_bug};

    my $self = {
        _ua => $ua,
        _cookie => $cookie_jar,
        _cfg => $cfg,
    };
    bless ($self, $class);

    return $self;
}


=item $conn -> ua

get the user agent, see L<LWP::UserAgent>

=cut

sub ua {
    my $self = shift;
    return $self -> {_ua};
}


sub norm_response {
    my ($r) = @_;
    if (defined $r && $r->protocol eq 'HTTP/0.9' && $r->message eq 'EOF') {
        # ??? Dieses Verhalten sollte besser von einer Konfigurationsvariable
        # ??? abhaengig gemacht werden.
        $r->code(500);
        $r->protocol("HTTP/1.0");
        $r->message("Internal Server Error: unexpected EOF");
        $r->headers->{webrobot_orig_response} = "HTTP/0.9 200 EOF";
        $r->headers->{webrobot_message} = "converted to http code 500 by webrobot";
    }
    return $r;
}

my %ACTION = (
    NOP => sub {
        return undef;
    },
    HEAD => sub {
	my ($ua, $url, $data, @header) = @_;
        return norm_response($ua -> request(HEAD(@_)));
    },
    GET => sub {
	my ($ua, $url, $data, @header) = @_;
        return norm_response($ua -> request(GET($url, @header)));
        #return $ua -> request(HTTP::Request -> new(GET => $url, @header));
    },
    POST => sub {
	my ($ua, $url, $data, @header) = @_;
        return norm_response($ua -> request(POST($url, $data, @header)));
    },
    PUT => sub {
	my ($ua, $url, $data, @header) = @_;
        return norm_response($ua -> request(PUT(@_)));
    },
    COOKIES => sub {
	my ($ua, $url, $data, @header) = @_;
        SWITCH: foreach ($url) {
            m/^clear$/i and do {
                my $cookie_jar = HTTP::Cookies -> new(File => "cookies.txt", AutoSave => 0);
                $ua->cookie_jar($cookie_jar) if $ua->cookie_jar();
                last;
            };
            m/^on$/i and do {
                my $cookie_jar = HTTP::Cookies -> new(File => "cookies.txt", AutoSave => 0);
                $ua->cookie_jar($cookie_jar);
                last;
            };
            m/^off$/i and do {
                $ua->cookie_jar(undef);
                last;
            };
        }
	return undef;
    },
    BASIC_REALM => sub {
	my ($ua, $url, $data, @header) = @_;
	$ua -> set_basic_realm($url);
	return undef;
    },
);

sub check_assertion {
    my ($r, $assert) = @_;
    my ($fail, $fail_str) = $assert -> check($r);
    return ($fail, $fail_str);
}


=item $user -> treat_single_url ($arg)

C<$arg> is an entry of a testplan, see L<WWW::Webrobot::pod::Testplan>.

Returns the fail state

=cut

sub treat_single_url {
    my ($self, $arg) = @_;

    sleep($self->{_cfg}->{delay}) if $self->{_cfg}->{delay};

    $self -> {_ua} -> clear_redirect_fail();
    my ($r, $fail, $fail_str);
    my $header = [ %{$self->{_cfg}->{http_header} || {}} ]; # cache this value?
    my $METHOD = $ACTION{$arg->{method}} or
        die "'$arg->{method}' is no valid method, expected: ", join ", ", keys %ACTION;

    # do HTTP request
    my ($sec, $usec) = Time::HiRes::gettimeofday();
    eval {
        # NOTE: $r may be undef depending on $METHOD
	$r = $METHOD->($self->{_ua}, $arg->{url}, $arg->{data} || {}, @$header);
    };
    my $elaps = Time::HiRes::tv_interval([$sec, $usec], [ Time::HiRes::gettimeofday() ]);
    $r->elapsed_time($elaps) if $r;

    # check result
    if ($self -> {_ua} -> is_redirect_fail()) {
	$fail = 0;
    }
    elsif ($@) {
	($r, $fail, $fail_str) = (undef, 2, "ANY ERROR");
	# evtl. Fehler diversifizieren, z.B.
	# * $arg->{method}==undef
	# * $arg->{url}==undef
	# * URL nicht unterstützt
	# * Aufruf geht schief
    }
    elsif (! defined $r) {
	($r, $fail, $fail_str) = (undef, 0, "0 RESPONSE IS NULL");
    }
    else {
	($fail, $fail_str) = check_assertion($r, $arg->{assert});
    }

    return ($r, $fail, $fail_str);
}


=back

=cut

1;
