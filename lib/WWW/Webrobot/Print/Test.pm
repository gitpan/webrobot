package WWW::Webrobot::Print::Test;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use Test::More qw(no_plan);


sub new {
    my $class = shift;
    my $self = bless({}, ref($class) || $class);
    return $self;
}

sub global_start {
    #my $self = shift;
}

sub item_pre {
    #my $self = shift;
    #my ($arg) = @_;
}

sub responses {
    my ($r) = @_;
    my $str = "";
    while (defined($r)) {
        $str .= "        $r->{_rc} $r->{_request}->{_uri}\n";
        $r = $r -> {_previous};
    }
    return $str;
}

sub bool { $_[0] ? "FALSE" : "TRUE " }

sub item_post {
    my ($self, $r, $arg) = @_;
    use Data::Dumper;
    $arg->{fail_str} ||= ''; # ??? should not need this statement!
    if (! ok(! $arg->{fail}, "$arg->{url}")) {
        my $str = <<EOF;
    Request:     $arg->{method} $arg->{url}
    Description: $arg->{description}
    Assertions: @{[ bool($arg->{fail}) ]}
EOF
        if (my $s = $arg->{fail_str}) {
            $s =~ s/^/        /gm;
            $str .= "$s\n";
        }
        diag($str . "    Responses:\n" . responses($r));
    }

}

sub global_end {
    my $self = shift;
}

1;

=head1 NAME

WWW::Webrobot::Print::Test - write response content according to L<Test::More>

=head1 DESCRIPTION

This module adapts to L<Test::Harness>.

=head1 METHODS

See L<WWW::Webrobot::pod::OutputListeners>.

=over

=item WWW::Webrobot::Print::Test -> new ();

=back
