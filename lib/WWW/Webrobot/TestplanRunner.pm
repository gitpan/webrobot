package WWW::Webrobot::TestplanRunner;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use WWW::Webrobot::UserAgentConnection;
use WWW::Webrobot::Print::Null;

use WWW::Webrobot::Attributes qw(sym_tbl);


=head1 NAME

WWW::Webrobot::TestplanRunner - runs a testplan

=head1 SYNOPSIS

WWW::Webrobot::TestplanRunner -> new() -> run($test_plan, $cfg);

=head1 DESCRIPTION

This module configures Webrobot with $cfg,
reads a testplan and executes this plan.


=head1 METHODS

=over

=item $wr = WWW::Webrobot::TestplanRunner -> new();

Construct an object.

=cut

sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    return $self;
}


=item WWW::Webrobot::TestplanRunner -> run($testplan, $cfg);

=over

=item $testplan

Read in the testplan (reference to list).

=item $cfg

[optional] Read the configuration (reference to list).

=back

=cut

sub run {
    my ($self, $testplan, $cfg, $sym_tbl) = @_;

    $self -> {cfg} = $cfg;
    $self -> {_sym_tbl} = $sym_tbl;
    $self -> {_ua_list} = {};
    $self -> {_defined} = [];

    # treat testplan
    my $out = $cfg -> {output} || WWW::Webrobot::Print::Null -> new();
    $_ -> global_start() foreach (@$out);
    my $exit_status = 0;
    foreach my $entry (@$testplan) {
        $sym_tbl -> evaluate($entry);
        $entry->{assert}  = get_plugin($entry->{assert_xml})
            if defined $entry->{assert_xml};
        $entry->{recurse} = get_plugin($entry->{recurse_xml})
            if defined $entry->{recurse_xml};

        my $user = $self -> _get_ua_connection($cfg, $entry -> {useragent});

        # get url in testplan
        $_ -> item_pre($entry) foreach (@$out);
        my ($r_plan, $fail_plan, $fail_plan_str) = $user -> treat_single_url($entry, $sym_tbl);
        $entry->{fail} = $fail_plan;
        $entry->{fail_str} = $fail_plan_str;
        $_ -> item_post($r_plan, $entry, $fail_plan) foreach (@$out);

        # do recursion
        my $fail_all = $fail_plan;
        if (defined(my $recurse = $entry -> {recurse})) {
            $user -> ua() -> set_redirect_ok($recurse);
            my ($newurl, $caller_pages) = $recurse -> next($r_plan);
            while ($newurl) {
                my $entry_recurse = {
                    method => "GET",
                    url => $newurl,
                    description => $entry->{description},
                    assert => $entry->{assert},
                    caller_pages => $caller_pages,
                    is_recursive => 1,
                };

                $_ -> item_pre($entry_recurse) foreach (@$out);
                my ($r, $fail, $fail_str) = $user -> treat_single_url($entry_recurse, $sym_tbl);
                $entry_recurse->{fail} = $fail;
                $entry_recurse->{fail_str} = $fail_str;
                $_ -> item_post($r, $entry_recurse, $fail) foreach (@$out);

                $fail_all = 1 if $fail;
                ($newurl, $caller_pages) = $recurse -> next($r);
                save_memory($r) if WWW::Webrobot::Global->save_memory();
            }
            $user -> ua() -> set_redirect_ok(undef);
        }
        $entry -> {result} = $r_plan;
        $entry -> {fail} = $fail_all;
        $entry -> {fail_str} = $fail_plan_str;
        $exit_status = 1 if $fail_all;
        save_memory($r_plan) if WWW::Webrobot::Global->save_memory();
    }
    $_ -> global_end() foreach (@$out);
    return $exit_status;
}


# SAVE MEMORY: delete _content and _content_xhtml of response
sub save_memory {
    my ($req) = @_;
    while (defined $req) { # for all subrequests
        undef $req->{_content};
        undef $req->{_content_xhtml};
        $req = $req -> {_previous};
    }
}


sub get_plugin {
    my ($list) = @_;
    my ($tag, $content) = splice(@$list, 0, 2);
    $tag =~ s/\./::/g;
    # ??? delete ', 0' in following line
    my $ret = eval "require $tag; $tag -> new(\$content, 0);";
    die "Can't use lib $tag: $@" if $@;
    return $ret;
}

# get useragent - create one if nonexistent
sub _get_ua_connection {
    my ($self, $cfg, $user) = @_;
    if (!exists $self->{_ua_list}->{$user}) {
        $self->{_ua_list}->{$user} =
            WWW::Webrobot::UserAgentConnection -> new($cfg, user => $user);
    }
    return $self->{_ua_list}->{$user};
}

 
=item $conn -> sym_tbl

Get the symbol table, see L<WWW::Webrobot::SymbolTable>.
Symbols are defined within a config file or within a test plan.

=back


=head1 SEE ALSO

=over

=item L<WWW::Webrobot>

is a frontend for this class

=back

=cut

1;
