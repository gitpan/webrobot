package WWW::Webrobot::UseXPath;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


use UNIVERSAL qw(isa);  # *isa = \&UNIVERSAL::isa;
use XML::XPath;
use XML::XPath::XMLParser;


=head1 NAME

WWW::Webrobot::UseXPath - Apply XPath expressions to an xml string

=head1 SYNOPSIS

 use WWW::Webrobot::UseXPath;
 WWW::Webrobot::UseXPath -> new($xml) -> extract($xpath_expression);

=head1 DESCRIPTION

Apply XPath expressions to an xml string.

=head1 METHODS

=over

=item WWW::Webrobot::UseXPath -> new ($xml)

Allocate an XPath object for the xml-string $xml

=cut

sub new {
    my ($proto, $xml) = @_;
    my $self = {
        _xml => $xml,
        _xpath => XML::XPath -> new(xml => $xml),
    };
    return bless ($self, ref($proto) || $proto);
}

=item $self -> extract ($expr)

Apply an xpath expression $expr for this object.
The result is of type string.

=cut

sub extract {
    my ($self, $expr) = @_;
    my $node = eval {
        $self -> {_xpath} -> find($expr);
    };
    die "ERROR in XPath expression='$expr': $@" if $@;
    #print "REF: ", ref($node), "\n";
    if ($node -> isa("XML::XPath::NodeSet")) {
        return join "\n", map { XML::XPath::XMLParser::as_string($_) } $node -> get_nodelist();
    }
    else {
        return $node -> value();
    }
}

=back

=cut

1;
