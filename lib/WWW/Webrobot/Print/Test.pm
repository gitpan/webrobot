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
    while (defined $r) {
        $str .= " "x8 . "$r->{_rc} $r->{_request}->{_uri}\n";
        $r = $r -> {_previous};
    }
    return $str;
}

sub bool_assert { $_[0] ? "FALSE" : "TRUE " }
sub bool { $_[0] ? "TRUE " : "FALSE" }

sub item_post {
    my ($self, $r, $arg) = @_;
    my $data = $arg->{data};
    my $out_ok = "$arg->{method} $arg->{url}";
    $out_ok .= " '$_'=>'$data->{$_}'" foreach (keys %$data);
    my $tmp = $arg->{fail_str};
    my $fail_str = (ref $tmp eq 'ARRAY') ? join("\n", @$tmp) : $tmp || "";
    if (! ok(! $arg->{fail}, $out_ok)) {
        diag(" "x4 . "Request:     $arg->{method} $arg->{url}");
        diag(" "x4 . "Description: $arg->{description}");
        if ($data && scalar keys %$data) {
            diag(" "x4 . "Data:");
            diag(" "x8 . "'$_' => '$data->{$_}'") foreach (keys %$data);
        }
        diag(" "x4 . "Assertions:  " . bool_assert($arg->{fail}));
        if (my $s = $fail_str) {
            $s =~ s/^(.)/ bool($1) /gme;
            $s =~ s/^/        /gm;
            diag($s);
        }
        diag(" "x4 . "Responses:\n" . responses($r));
        if ($arg->{new_properties}) {
            diag(" "x4 . "New properties:\n");
            diag("property '$_->[0]' => '$_->[1]'\n") foreach (@{$arg->{new_properties}});
        }
        if ($r && (my $c = $r->content)) {
            my $line = substr($c, 0, 60);
            $line =~ s/\\/\\\\/gs;
            $line =~ s/([\x00-\x1F\x7F\x80-\x9F\xFF])/ sprintf("\\%03d", ord($1)) /gse;
            diag(" "x4 . "Content: [$line]");
        }
    }

}

sub global_end {
    #my $self = shift;
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
