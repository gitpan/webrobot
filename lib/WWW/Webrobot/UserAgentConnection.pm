package WWW::Webrobot::UserAgentConnection;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use HTTP::Cookies;
use HTTP::Request::Common;
use Time::HiRes;

use WWW::Webrobot::Attributes qw(ua cfg);
use WWW::Webrobot::MyUserAgent;
use WWW::Webrobot::Ext::General::HTTP::Response;
use WWW::Webrobot::AssertConstant;


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
        _cfg => $cfg,
    };
    bless ($self, $class);

    return $self;
}


=item $conn -> ua

Get the user agent, see L<LWP::UserAgent>

=item $conn -> cfg

Get the (internal) config data structure

=cut


#privat
sub norm_request {
    my ($self, $r) = @_;
    my $referrer = $self->ua->referrer();
    if ($referrer) {
        if ($self->cfg->{referrer_bug}) {
            $r -> headers() -> header(Referer => $referrer);
        }
        else {
            $r -> headers() -> referer($referrer);
        }
    }
    $self->ua->referrer($r->uri);
    return $r;
}

#static private
sub norm_response {
    my ($r) = @_;
    if (defined $r && ($r->protocol || "") eq 'HTTP/0.9' && ($r->message || "") eq 'EOF') {
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
        my ($uac, $arg, $sym_tbl) = @_;
        my %header = %{$uac->cfg->{http_header}};
        return norm_response($uac -> ua -> request($uac->norm_request(HEAD($arg->{url}, %header))));
    },
    GET => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        my %header = %{$uac->cfg->{http_header}};
        my $data = $arg->{data};
        my $url = $arg->{url};
        if ($data && scalar keys %$data) {
            my $tmp_request = POST($arg->{url}, $arg->{data}, %header);
            $url .= "?" . $tmp_request->content() if $tmp_request->content();
        }
        my $request = GET($url, %header);
        return norm_response($uac -> ua -> request($uac->norm_request($request)));
    },
    POST => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        my %header = %{$uac->cfg->{http_header}};
        return norm_response($uac -> ua -> request($uac->norm_request(POST($arg->{url}, $arg->{data}, %header))));
    },
    PUT => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        my %header = %{$uac->cfg->{http_header}};
        return norm_response($uac -> ua -> request($uac->norm_request(PUT($arg->{url}, $arg->{data}, %header))));
    },
    COOKIES => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        my $ua = $uac->ua;
        SWITCH: foreach ($arg->{url}) {
            m/^on$/i || m/^clear$/i && $ua->cookie_jar() and do {
                if ($ua->cookie_jar()) {
                    my $cookie_jar = HTTP::Cookies -> new(File => "cookies.txt", AutoSave => 0);
                    $ua->cookie_jar($cookie_jar);
                }
                last;
            };
            m/^off$/i and do {
                $ua->cookie_jar(undef);
                last;
            };
        }
        return undef;
    },
    REFERRER => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        my $ua = $uac->ua;
        SWITCH: foreach ($arg->{url}) {
            m/^clear$/i and do {
                $ua->referrer("");
                last;
            };
            m/^on$/i and do {
                $ua->enable_referrer(1);
                last;
            };
            m/^off$/i and do {
                $ua->enable_referrer(0);
                last;
            };
        }
        return undef;
    },
    BASIC_REALM => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        $uac -> ua -> set_basic_realm($arg->{url});
        return undef;
    },
    CONFIG => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        eval {
            SWITCH: foreach ($arg->{_mode}) {
                /^filename$/ || /^script$/ and do {
                    my $filename = $arg->{url};
                    $filename .= " |" if /^script$/;
                    my $err_msg = /^script$/ ? "Can't start script" : "Can't read file";

                    my $handle = do {local *FH; *FH};
                    { # 'open' produces a warning if the shell script doesn't exist!
                        no warnings;
                        open $handle, "$filename" or die "$err_msg: '$arg->{url}'";
                    }
                    my $new_variables = WWW::Webrobot::Properties -> new() -> load_handle($handle) or
                        die "Can't read data from external program '$arg->{url}'";
                    my @new_vars = map { [$_, $new_variables->{$_}] } sort keys %$new_variables;
                    $arg->{new_properties} = \@new_vars;
                    foreach (keys %$new_variables) {
                        $sym_tbl->define_symbol($_, $new_variables->{$_});
                    }
                    close $handle;
                    last;
                };
                die "found $_ in \$arg->{_mode}, expected 'filename', 'script'";
            }
        };
        my $err = $@;
        $arg->{assert} = new WWW::Webrobot::AssertConstant($err, $err ? "0 $err" : undef);
        return undef;
    },
    SLEEP => sub {
        my ($uac, $arg, $sym_tbl) = @_;
        sleep($arg->{url});
        return undef;
    },
);

sub check_assertion {
    my ($r, $assert) = @_;
    my ($fail, $fail_str) = $assert -> check($r);
    return ($fail, $fail_str);
}


=item $user -> treat_single_url ($arg, $sym_tbl)

C<$arg> is an entry of a testplan, see L<WWW::Webrobot::pod::Testplan>.

Returns the fail state

=cut

sub treat_single_url {
    my ($self, $arg, $sym_tbl) = @_;
    #use Data::Dumper; print STDERR Dumper $sym_tbl;

    sleep($self->{_cfg}->{delay}) if $self->{_cfg}->{delay};

    $self -> {_ua} -> clear_redirect_fail();
    my ($r, $fail, $fail_str);
    $self->cfg->{http_header} ||= {}; # ??? really necessary?
    $arg->{data} ||= {}; # ??? really necessary?
    my $METHOD = $ACTION{$arg->{method}} or
        die "'$arg->{method}' is no valid method, expected: ", join ", ", keys %ACTION;

    # do test plan entry (usually HTTP request)
    my ($sec, $usec) = Time::HiRes::gettimeofday();
    eval {
        # NOTE: $r may be undef depending on $METHOD
        $r = $METHOD->($self, $arg, $sym_tbl);
    };
    my $exception = $@;
    my $elaps = Time::HiRes::tv_interval([$sec, $usec], [ Time::HiRes::gettimeofday() ]);
    $r->elapsed_time($elaps) if $r;

    # check result
    if ($self -> {_ua} -> is_redirect_fail()) {
        $fail = 0;
    }
    elsif ($exception) {
        $r = undef;
        ($fail, $fail_str) = (2, "2 CALL TO METHOD '$arg->{method}', URL '$arg->{url}' FAILED: $exception");
    }
    elsif (! defined $arg->{assert}) {
        # Method like COOKIES that don't support assertions
        ($fail, $fail_str) = (0, undef);
    }
    else {
        ($fail, $fail_str) = check_assertion($r, $arg->{assert});
    }

    if (!$fail && $arg->{property}) {
        # evaluate new names
        foreach (@{$arg->{property}}) {
            my ($mode, $name, $expr) = @$_;
            SWITCH: foreach ($mode) {
                /^value$/ and do {
                    $sym_tbl -> define_symbol($name, $expr);
                    last;
                };
                /^regex$/ and do {
                    next if ! $r;
                    my ($value) = $r->content =~ m/$expr/;
                    $sym_tbl -> define_symbol($name, $value);
                    last;
                };
                /^xpath$/ and do {
                    next if ! $r;
                    $sym_tbl -> define_symbol($name, $r->xpath($expr));
                    last;
                };
                /^header$/ and do {
                    next if ! $r;
                    $sym_tbl -> define_symbol($name, $r->header($expr));
                    last;
                };
                /^status$/ and do {
                    next if ! $r;
                    my @val = (qw/code protocol message/);
                    #my %val_hash; @val_hash{@val} = (1)x@val;
                    my %val_hash = map {$_=>1} @val;
                    die("found status=$expr, expected " . join(", ", map {"'$_'"} @val))
                        if ! $val_hash{$expr};
                    $sym_tbl -> define_symbol($name, $r->header($expr));
                    last;
                };
                die "found attribute '$_', expected 'value', 'regex', 'xpath', 'header', 'status'";
            }
        }
        #use Data::Dumper; print STDERR Dumper $arg->{property};
    }

    return ($r, $fail, $fail_str);
}


=back

=cut

1;
