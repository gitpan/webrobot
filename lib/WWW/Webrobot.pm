package WWW::Webrobot;
use strict;
use warnings;

*VERSION = \'0.10';

use Carp;
use WWW::Webrobot::Properties;
use WWW::Webrobot::SymbolTable;
use WWW::Webrobot::XML2Tree;
use WWW::Webrobot::TestplanRunner;
use WWW::Webrobot::Global;
use WWW::Webrobot::AssertDefault;


=head1 NAME

WWW::Webrobot - Run Testplans

=head1 SYNOPSIS

 use WWW::Webrobot;
 WWW::Webrobot -> new($cfg) -> run($test_plan);

configures Webrobot with $cfg, reads a testplan and executes this plan

=head1 DESCRIPTION

Runs a testplan according to a configuration.

=head1 METHODS

=over

=item $wr = WWW::Webrobot -> new( [$cfg] );

Construct an object.
Calls C<cfg($cfg)> if C<$cfg> is set.

=cut

sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    my ($cfg, $cmd_param) = @_;
    $self->cfg($cfg, $cmd_param) if defined $cfg;
    return $self;
}


=item $wr -> cfg();

returns the config variable C<$cfg>

=item $wr -> cfg($cfg_name, $cmd_properties);

=over

=item $cfg

Read in the config data in one of three ways:

 scalar		read from file named $cfg
 ref to scalar	eval scalar as a string
 ref to hash	simple perl expression

=back

B<Example:>

        my $cfg = {
            proxy => {http => "your http proxy", ftp => "your ftp proxy"},
            names => {altavista => "altavista.com"},
        };
        my $wr -> cfg($cfg);

runs C<$cfg> as perl data structure.
Now write $cfg to a file named C<cfg.pl>

        #=== cfg.pl ===
        return {
            proxy => {http => "your http proxy", ftp => "your ftp proxy"},
            names => {altavista => "altavista.com"},
        };

and call

        $wr -> cfg("cfg.pl");

=item $wr -> cfg($cfg);

Set config properties in internal format.
$cfg B<must> be obtained by (some other) $wr->cfg().

=cut

sub cfg {
    my ($self, $cfg, $cmd_param) = @_;
    if (ref $cfg eq "HASH") {
        die if defined $cmd_param;
        $self->{cfg} = $cfg;
    }
    else {
        $self->{cfg} = __PACKAGE__->read_configuration($cfg, $cmd_param) if defined $cfg;
    }
    return $self->{cfg};
}


=item $wr -> run($test_plan);

=over

=item $test_plan

Run a testplan.
Read in the testplan in one of two ways:

 scalar		read from file named $cfg
 ref to scalar	eval scalar as a string

=back


=cut

sub run {
    my $self = shift;
    my ($test_plan_name) = @_;
    my $cfg = $self -> cfg() or die "Missing config definition";

    $test_plan_name = $test_plan_name || $cfg -> {testplan} or
        die "No testplan defined!";
    WWW::Webrobot::Global->plan_name($test_plan_name);

    my $sym_tbl = WWW::Webrobot::SymbolTable->new();
    foreach (keys %{$self->cfg->{names}}) {
        $sym_tbl -> push_symbol($_, $self->cfg->{names}->{$_});
    }
    my $test_plan = __PACKAGE__->read_testplan($test_plan_name, $sym_tbl);

    return WWW::Webrobot::TestplanRunner -> new() -> run($test_plan, $cfg, $sym_tbl);
}

sub read_testplan {
    my ($pkg, $test_plan_name, $sym_tbl) = @_;

    my $parser = WWW::Webrobot::XML2Tree->new();
    my $tree = $parser -> parsefile($test_plan_name);
    my $test_plan = xml2testplan($tree, $sym_tbl);

    # check and normalize 'test_plan'
    die "Can't read file $test_plan_name, err=$?, msg=$@" if $@;
    ref($test_plan) or die "No valid testplan!";
    foreach (@$test_plan) {
        $_ = __PACKAGE__->norm_testplan_entry($_, $sym_tbl);
    }
    return $test_plan;
}

sub assert {
    my ($cond, $text) = @_;
    croak "$text" if !$cond;
}

sub xml2testplan {
    my ($tree, $sym_tbl) = @_;

    # treat root of xml
    delete_white_space($tree);

    #my $plan_attribute = shift @$tree;
    my $plan = xml2plan($tree, $sym_tbl);
    return $plan;
}

sub xml2plan {
    my ($tree, $sym_tbl) = @_;
    my $attributes = shift @$tree;
    my ($tag, $content) = splice(@$tree, 0, 2);
    assert($tag eq "plan", "<plan> expected");
    my $plan = xml2planlist($content, $sym_tbl);
    return $plan;
}

sub xml2planlist {
    my ($tree, $sym_tbl) = @_;

    my $plan = [];
    my $attributes = shift @$tree;
    while (scalar @$tree) {
        my ($tag, $content) = splice(@$tree, 0, 2);
        SWITCH: foreach ($tag) {
            ! $_ and do { last }; # skip white space, obsolete?
            /^plan$/ and do {
                my $plan_attributes = $content->[0];
                my $action = $plan_attributes->{action};
                assert(!defined $action || $action eq "shuffle",
                       "action='$action' not allowed, expected [shuffle]");
                my $sub_plan = xml2planlist($content, $sym_tbl);
                fisher_yates_shuffle($sub_plan) if $action eq "shuffle";
                push @$plan, @$sub_plan;
                last;
            };
            /^request$/ || /^entry$/ and do {
                assert(ref $content eq 'ARRAY', "Test plan request expected");
                push @$plan, xml2entry($content);
                last;
            };
            /^include$/ and do {
                my $attr = shift @$content;
                my $fname = $attr->{file};
                my $parm = get_data($content);
                $sym_tbl->push_scope();
                foreach (keys %$parm) {
                    $sym_tbl->push_symbol($_, $parm->{$_});
                }
                my $iplan = __PACKAGE__->read_testplan($fname, $sym_tbl);
                push @$plan, @$iplan;
                $sym_tbl->pop_scope();
                last;
            };
            /^cookies$/ and do {
                for ($content->[0]->{value} || "") {
                    assert(m/^on$/i || m/^off$/i || m/^clear$/i,
                           "found '$_', expected 'on', 'off, 'clear'");
                    push @$plan, {method => "COOKIES", url => "$_"};
                }
                last;
            };
            assert(0, "found <$tag>, expected <plan>, <entry>, <include>, <cookies>");
        }
    }
    return $plan;
}


sub xml2entry {
    my ($tree) = @_;

    my %entry = ();
    my $attributes = shift @$tree;
    while (scalar @$tree) {
        my ($tag, $content) = splice(@$tree, 0, 2);
        next if !$tag; # skip white space
        my $attr = shift @{$content};
        # ??? obsolete iff CDATA->value
        if (scalar @$content && ! $content->[0] && ! exists $attr->{value}) {
            $attr->{value} = $content->[1];
        }
        SWITCH: foreach ($tag) {
            /^method$/ and do {
                $entry{method} = trim($attr->{value}) || "GET";
                last;
            };
            /^url$/ and do {
                $entry{url} = trim($attr->{value}) || die "URL required";
                last;
            };
            /^description$/ and do {
                $entry{description} = trim($attr->{value});
                last;
            };
            /^useragent$/ and do {
                $entry{useragent} = trim($attr->{value});
                last;
            };
            /^data$/ and do {
                $entry{data} = get_data($content);
                last;
            };
            /^assert$/ and do {
                $entry{assert_xml} = $content;
                last;
            };
            /^recurse$/ and do {
                $entry{recurse_xml} = $content;
                last;
            };
            assert(0, "<method>, <url>, <description>, <useragent>, <data>, <assert>, <recurse> expected");
        }
    }
    return \%entry;
}

sub get_data {
    my ($list) = @_;
    my %entry = ();
    while (scalar @$list) {
        my ($tag, $content) = splice(@$list, 0, 2);
        next if !$tag; # skip white space
        assert($tag eq 'parm', "<parm> expected");
        my $attr = shift @$content;
        my $lhs = $attr->{name};
        my $rhs = (defined $attr->{value}) ?  $attr->{value} : ($content->[0] ? "" : trim($content->[1]));
        $entry{$lhs} = $rhs;
    }
    return \%entry;
}

sub trim {
    my ($str) = @_;
    return "" if !defined $str;
    $str =~ s/^\s+//s;
    $str =~ s/\s+$//s;
    return $str;
}

sub delete_white_space {
    my ($tree) = @_;
    return delete_white_space($tree->[1]) if scalar @$tree == 2; # root is special

    # Note: scalar @$tree % 2 == 1
    for (my $i = scalar @$tree; $i > 1; $i-=2) {
        if (! $tree->[$i-2] && $tree->[$i-1] =~ m/^\s*$/s) {
            splice(@$tree, $i-2, 2);
        }
        elsif (ref $tree->[$i-1]) {
            delete_white_space($tree->[$i-1]);
        }
    }
}


# static
# shuffle an array randomly inplace
sub fisher_yates_shuffle {
    my ($array) = @_;                     # $array is a reference to an array
    my $last = @$array;
    while ($last--) {
        my $k = int rand ($last+1);
        @$array[$last, $k] = @$array[$k, $last];
    }
}


# static
sub read_configuration {
    my ($package, $cfg_name, $cmd_param) = @_;
    die "Missing config definition" if !$cfg_name;

    # read config file in 'properties' format
    my $config = WWW::Webrobot::Properties->new(
        listmode => [qw(names auth_basic output http_header proxy no_proxy)],
        key_value => [qw(names http_header proxy)],
        multi_value => [qw(auth_basic)],
        structurize => [qw(load mail)],
    );
    my $cfg = $config->load_file($cfg_name, $cmd_param);

    # adjust property 'output' to internal data structure
    $cfg->{output} = [ $cfg->{output} ] if ref($cfg->{output}) ne "ARRAY";
    my $output = $cfg->{output};
    foreach (@$output) {
        my ($class, $rest) = split /\s+/, $_, 2;
        eval "require $class;";
        die "Can't find class='$class', $@" if $@;
        $rest ||= "";
        my @parm = eval("( $rest )");
        die "Invalid parameter list: $@" if $@;
        $_ = $class -> new(@parm);
    }

    # adjust property 'auth_basic' to internal data structure
    my %intern_realm = ();
    foreach (@{$cfg->{auth_basic}}) {
        my ($id, @value) = @$_;
        $intern_realm{$id} = \@value;
    }
    $cfg->{auth_basic} = \%intern_realm;

    # normalize
    $cfg->{load}->{number_of_clients} ||= 1 if defined $cfg->{load};
    return $cfg;
}


my %arg_default = (
                   data => {},
                   option => {},
                   assert => WWW::Webrobot::AssertDefault -> new(),
                   description => '',
                   useragent => '',
                   define => {},
                   is_recursive => 0,
                   fail_str => '',
                   fail => -1,
                  );

sub norm_testplan_entry {
    my ($self, $entry, $sym_tbl) = @_;
    my %arg = (%arg_default, %$entry);
    my $ret = WWW::Webrobot::TestplanRunner -> evaluate_names(\%arg, $sym_tbl);
    return $ret;
}


=back

=head1 SEE ALSO

L<WWW::Webrobot::pod::Config>

L<WWW::Webrobot::pod::Testplan>

=cut

1;
