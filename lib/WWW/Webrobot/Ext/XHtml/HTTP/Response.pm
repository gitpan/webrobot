package WWW::Webrobot::Ext::XHtml::HTTP::Response;
use strict;
use warnings;


# extend LWPs HTTP::Response without subclassing
package HTTP::Response;
use strict;
use warnings;

use HTML::TreeBuilder;
use WWW::Webrobot::UseXPath;

sub content_xhtml {
    my ($self, $arg) = @_;
    return $self -> {_content_xhtml} ? 1 : 0 if $arg;
    if (! exists $self -> {_content_xhtml}) {
        my $tree = HTML::TreeBuilder -> new();

        # configure $tree
        $tree -> no_space_compacting(1);
        $tree -> ignore_ignorable_whitespace(0);
        $tree -> store_comments(1);

        # parse the document
        $tree -> parse($self -> content());
        my $xhtml = $tree -> as_XML();

        # rework the result
        $xhtml =~ s/(&#13;)?&#10;/\n/g;
        $xhtml =~ s/&#9;/\t/g;

        $self -> {_content_xhtml} = $xhtml;
        $tree = $tree -> delete;
    }
    return $self -> {_content_xhtml};
}


sub xpath {
    my ($self, $expr) = @_;
    if (! exists $self->{_xpath}) {
        $self->{_xpath} = WWW::Webrobot::UseXPath -> new($self->content_xhtml());
    }
    return $self -> {_xpath} -> extract($expr);
}

1;
