package WWW::Webrobot::SendMail;
use strict;
use warnings;


sub send_mail {
    my ($mail, $exit) = @_;
    if (defined $mail and (my $c = $mail -> {condition} || "fail") ne "never") {
        require MIME::Lite;
        if ($c eq "ever" || $exit && $c eq "fail" || !$exit && $c eq "success") {
            my $server = $mail -> {server} or die "No mail server given";
            my $timeout = $mail -> {timeout} || 60;
            my %parm = ( %$mail );
            delete @parm{qw(condition server timeout)};
            my $msg = MIME::Lite -> new(%parm);
            my $msg_to = $msg->get("to");
            my $msg_cc = $msg->get("cc");
            my $msg_bcc = $msg->get("bcc");
            print "Sending mail",
                $msg_to  ? " to: $msg_to" : "",
                $msg_cc  ? " cc: $msg_cc" : "",
                $msg_bcc ? " bcc: $msg_bcc" : "", "\n";
            #print "ELEM: $_=$parm{$_}\n" foreach (keys %parm);
            MIME::Lite -> send('smtp', $server, Timeout=>$timeout);
            eval {
                $msg -> send();
            };
            $@ ? return $@ : return 0;
        }
    }
}

1;


=head1 NAME

WWW::Webrobot::SendMail - simple wrapper for sending mail

=head1 SYNOPSIS

 WWW::Webrobot::SendMail::send_mail($mailconfig, $exit);

=head1 DESCRIPTION

Function to send mail.
Uses L<MIME::Lite>.


=head1 METHODS

=over

=item send_mail

Function to send mail

 my $mail = {
        condition => 'never', # 'fail' (default), 'success', 'never', 'ever'
        server    => "sgate.s3.abas.de", # mandatory
        timeout   => 60, # default=60

        # fields for MIME::Lite, ignores case on left hand side
        'Return-Path' => 'from@domain.de', # defaults to 'From' attribute
        From          => 'webrobot',
        'Reply-To'    => 'reply@domain.de',
        To            => 'to@domain.de',
        Cc            => 'some@other.com, some@more.com',
        Bcc           => 'blind@domain.de',
        Subject       => 'Subject for mail',
        Type          => 'text/plain',
        Encoding      => 'quoted-printable', # 'quoted-printable', 'base64'
        #Path          => 'hellonurse.gif'
        Data          => <<'EOF',
 Thats the body of the
 mail you want to send.
 EOF

C<$exit> acts as an error state thats compared to $mail->{condition}

=back

=cut
