package WWW::Webrobot::HttpErrcode;
use strict;
use warnings;

# Author: Stefan Trcek
# Copyright(c) 2004 ABAS Software AG


=head1 NAME

WWW::Webrobot::HttpErrcode - HTTP Error Codes

=head1 SYNOPSIS

 my $html = WWW::Webrobot::HttpErrcode::as_html;

=head1 DESCRIPTION

This module is for HTTP error codes.

=head1 METHODS

=over

=item WWW::Webrobot::Print::Util::as_html

Return a HTML string containing HTTP error codes.
It can be navigated by a webbrowser.
It contains marks to simply navigate by the code number.

=back

=head1 SEE ALSO

RFC 2616 L<http://www.faqs.org/rfcs/rfc2616.html>

=cut

sub as_html {
    return <<'EOF';
<html>
<head>
  <title>HTTP Error Codes</title>
</head>
<body>
This is an extract of <a href='http://www.faqs.org/rfcs/rfc2616.html'>RFC 2616</a>.
<p>

<h1>10 Status Code Definitions</h1>
<p>
   Each Status-Code is described below, including a description of which
   method(s) it can follow and any metainformation required in the
   response.
<p>

<h2><a name='1'><font color=maroon>10.1 Informational 1xx</font></a></h2>
<p>
   This class of status code indicates a provisional response,
   consisting only of the Status-Line and optional headers, and is
   terminated by an empty line. There are no required headers for this
   class of status code. Since HTTP/1.0 did not define any <a href='#1'>1xx</a> status
   codes, servers MUST NOT send a <a href='#1'>1xx</a> response to an HTTP/1.0 client
   except under experimental conditions.
<p>
   A client MUST be prepared to accept one or more <a href='#1'>1xx</a> status responses
   prior to a regular response, even if the client does not expect a <a href='#100'>100</a>
   (Continue) status message. Unexpected <a href='#1'>1xx</a> status responses MAY be
   ignored by a user agent.
<p>
   Proxies MUST forward <a href='#1'>1xx</a> responses, unless the connection between the
   proxy and its client has been closed, or unless the proxy itself
   requested the generation of the <a href='#1'>1xx</a> response. (For example, if a
   proxy adds a "Expect: <a href='#100'>100</a>-continue" field when it forwards a request,
   then it need not forward the corresponding <a href='#100'>100</a> (Continue)
   response(s).)
<p>

<h3><a name='100'><font color=purple>10.1.1 100 Continue</font></a></h3>
<p>
   The client SHOULD continue with its request. This interim response is
   used to inform the client that the initial part of the request has
   been received and has not yet been rejected by the server. The client
   SHOULD continue by sending the remainder of the request or, if the
   request has already been completed, ignore this response. The server
   MUST send a final response after the request has been completed. See
   section 8.2.3 for detailed discussion of the use and handling of this
   status code.
<p>

<h3><a name='101'><font color=purple>10.1.2 101 Switching Protocols</font></a></h3>
<p>
   The server understands and is willing to comply with the client's
   request, via the Upgrade message header field (section 14.42), for a
   change in the application protocol being used on this connection. The
   server will switch protocols to those defined by the response's
   Upgrade header field immediately after the empty line which
   terminates the <a href='#101'>101</a> response.
<p>
   The protocol SHOULD be switched only when it is advantageous to do
   so. For example, switching to a newer version of HTTP is advantageous
   over older versions, and switching to a real-time, synchronous
   protocol might be advantageous when delivering resources that use
   such features.
<p>

<h2><a name='2'><font color=maroon>10.2 Successful 2xx</font></a></h2>
<p>
   This class of status code indicates that the client's request was
   successfully received, understood, and accepted.
<p>

<h3><a name='200'><font color=purple>10.2.1 200 OK</font></a></h3>
<p>
   The request has succeeded. The information returned with the response
   is dependent on the method used in the request, for example:
<p>
   GET    an entity corresponding to the requested resource is sent in
          the response;
<p>
   HEAD   the entity-header fields corresponding to the requested
          resource are sent in the response without any message-body;
<p>
   POST   an entity describing or containing the result of the action;
<p>
   TRACE  an entity containing the request message as received by the
          end server.
<p>

<h3><a name='201'><font color=purple>10.2.2 201 Created</font></a></h3>
<p>
   The request has been fulfilled and resulted in a new resource being
   created. The newly created resource can be referenced by the URI(s)
   returned in the entity of the response, with the most specific URI
   for the resource given by a Location header field. The response
   SHOULD include an entity containing a list of resource
   characteristics and location(s) from which the user or user agent can
   choose the one most appropriate. The entity format is specified by
   the media type given in the Content-Type header field. The origin
   server MUST create the resource before returning the <a href='#201'>201</a> status code.
   If the action cannot be carried out immediately, the server SHOULD
   respond with <a href='#202'>202</a> (Accepted) response instead.
<p>
   A <a href='#201'>201</a> response MAY contain an ETag response header field indicating
   the current value of the entity tag for the requested variant just
   created, see section 14.19.
<p>

<h3><a name='202'><font color=purple>10.2.3 202 Accepted</font></a></h3>
<p>
   The request has been accepted for processing, but the processing has
   not been completed.  The request might or might not eventually be
   acted upon, as it might be disallowed when processing actually takes
   place. There is no facility for re-sending a status code from an
   asynchronous operation such as this.
<p>
   The <a href='#202'>202</a> response is intentionally non-committal. Its purpose is to
   allow a server to accept a request for some other process (perhaps a
   batch-oriented process that is only run once per day) without
   requiring that the user agent's connection to the server persist
   until the process is completed. The entity returned with this
   response SHOULD include an indication of the request's current status
   and either a pointer to a status monitor or some estimate of when the
   user can expect the request to be fulfilled.
<p>

<h3><a name='203'><font color=purple>10.2.4 203 Non-Authoritative Information</font></a></h3>
<p>
   The returned metainformation in the entity-header is not the
   definitive set as available from the origin server, but is gathered
   from a local or a third-party copy. The set presented MAY be a subset
   or superset of the original version. For example, including local
   annotation information about the resource might result in a superset
   of the metainformation known by the origin server. Use of this
   response code is not required and is only appropriate when the
   response would otherwise be <a href='#200'>200</a> (OK).
<p>

<h3><a name='204'><font color=purple>10.2.5 204 No Content</font></a></h3>
<p>
   The server has fulfilled the request but does not need to return an
   entity-body, and might want to return updated metainformation. The
   response MAY include new or updated metainformation in the form of
   entity-headers, which if present SHOULD be associated with the
   requested variant.
<p>
   If the client is a user agent, it SHOULD NOT change its document view
   from that which caused the request to be sent. This response is
   primarily intended to allow input for actions to take place without
   causing a change to the user agent's active document view, although
   any new or updated metainformation SHOULD be applied to the document
   currently in the user agent's active view.
<p>
   The <a href='#204'>204</a> response MUST NOT include a message-body, and thus is always
   terminated by the first empty line after the header fields.
<p>

<h3><a name='205'><font color=purple>10.2.6 205 Reset Content</font></a></h3>
<p>
   The server has fulfilled the request and the user agent SHOULD reset
   the document view which caused the request to be sent. This response
   is primarily intended to allow input for actions to take place via
   user input, followed by a clearing of the form in which the input is
   given so that the user can easily initiate another input action. The
   response MUST NOT include an entity.
<p>

<h3><a name='206'><font color=purple>10.2.7 206 Partial Content</font></a></h3>
<p>
   The server has fulfilled the partial GET request for the resource.
   The request MUST have included a Range header field (section 14.35)
   indicating the desired range, and MAY have included an If-Range
   header field (section 14.27) to make the request conditional.
<p>
   The response MUST include the following header fields:
<p>
<li> Either a Content-Range header field (section 14.16) indicating
        the range included with this response, or a multipart/byteranges
        Content-Type including Content-Range fields for each part. If a
        Content-Length header field is present in the response, its
        value MUST match the actual number of OCTETs transmitted in the
        message-body.
<p>
<li> Date
<p>
<li> ETag and/or Content-Location, if the header would have been sent
        in a <a href='#200'>200</a> response to the same request
<p>
<li> Expires, Cache-Control, and/or Vary, if the field-value might
        differ from that sent in any previous response for the same
        variant
<p>
   If the <a href='#206'>206</a> response is the result of an If-Range request that used a
   strong cache validator (see section 13.3.3), the response SHOULD NOT
   include other entity-headers. If the response is the result of an
   If-Range request that used a weak validator, the response MUST NOT
   include other entity-headers; this prevents inconsistencies between
   cached entity-bodies and updated headers. Otherwise, the response
   MUST include all of the entity-headers that would have been returned
   with a <a href='#200'>200</a> (OK) response to the same request.
<p>
   A cache MUST NOT combine a <a href='#206'>206</a> response with other previously cached
   content if the ETag or Last-Modified headers do not match exactly,
   see 13.5.4.
<p>
   A cache that does not support the Range and Content-Range headers
   MUST NOT cache <a href='#206'>206</a> (Partial) responses.
<p>

<h2><a name='3'><font color=maroon>10.3 Redirection 3xx</font></a></h2>
<p>
   This class of status code indicates that further action needs to be
   taken by the user agent in order to fulfill the request.  The action
   required MAY be carried out by the user agent without interaction
   with the user if and only if the method used in the second request is
   GET or HEAD. A client SHOULD detect infinite redirection loops, since
   such loops generate network traffic for each redirection.
<p>
<b>Note:</b> previous versions of this specification recommended a
      maximum of five redirections. Content developers should be aware
      that there might be clients that implement such a fixed
      limitation.
<p>

<h3><a name='300'><font color=purple>10.3.1 300 Multiple Choices</font></a></h3>
<p>
   The requested resource corresponds to any one of a set of
   representations, each with its own specific location, and agent-
   driven negotiation information (section 12) is being provided so that
   the user (or user agent) can select a preferred representation and
   redirect its request to that location.
<p>
   Unless it was a HEAD request, the response SHOULD include an entity
   containing a list of resource characteristics and location(s) from
   which the user or user agent can choose the one most appropriate. The
   entity format is specified by the media type given in the Content-
   Type header field. Depending upon the format and the capabilities of
<p>
   the user agent, selection of the most appropriate choice MAY be
   performed automatically. However, this specification does not define
   any standard for such automatic selection.
<p>
   If the server has a preferred choice of representation, it SHOULD
   include the specific URI for that representation in the Location
   field; user agents MAY use the Location field value for automatic
   redirection. This response is cacheable unless indicated otherwise.
<p>

<h3><a name='301'><font color=purple>10.3.2 301 Moved Permanently</font></a></h3>
<p>
   The requested resource has been assigned a new permanent URI and any
   future references to this resource SHOULD use one of the returned
   URIs.  Clients with link editing capabilities ought to automatically
   re-link references to the Request-URI to one or more of the new
   references returned by the server, where possible. This response is
   cacheable unless indicated otherwise.
<p>
   The new permanent URI SHOULD be given by the Location field in the
   response. Unless the request method was HEAD, the entity of the
   response SHOULD contain a short hypertext note with a hyperlink to
   the new URI(s).
<p>
   If the <a href='#301'>301</a> status code is received in response to a request other
   than GET or HEAD, the user agent MUST NOT automatically redirect the
   request unless it can be confirmed by the user, since this might
   change the conditions under which the request was issued.
<p>
<b>Note:</b> When automatically redirecting a POST request after
      receiving a <a href='#301'>301</a> status code, some existing HTTP/1.0 user agents
      will erroneously change it into a GET request.
<p>

<h3><a name='302'><font color=purple>10.3.3 302 Found</font></a></h3>
<p>
   The requested resource resides temporarily under a different URI.
   Since the redirection might be altered on occasion, the client SHOULD
   continue to use the Request-URI for future requests.  This response
   is only cacheable if indicated by a Cache-Control or Expires header
   field.
<p>
   The temporary URI SHOULD be given by the Location field in the
   response. Unless the request method was HEAD, the entity of the
   response SHOULD contain a short hypertext note with a hyperlink to
   the new URI(s).
<p>
   If the <a href='#302'>302</a> status code is received in response to a request other
   than GET or HEAD, the user agent MUST NOT automatically redirect the
   request unless it can be confirmed by the user, since this might
   change the conditions under which the request was issued.
<p>
<b>Note:</b> RFC 1945 and RFC 2068 specify that the client is not allowed
      to change the method on the redirected request.  However, most
      existing user agent implementations treat <a href='#302'>302</a> as if it were a <a href='#303'>303</a>
      response, performing a GET on the Location field-value regardless
      of the original request method. The status codes <a href='#303'>303</a> and <a href='#307'>307</a> have
      been added for servers that wish to make unambiguously clear which
      kind of reaction is expected of the client.
<p>

<h3><a name='303'><font color=purple>10.3.4 303 See Other</font></a></h3>
<p>
   The response to the request can be found under a different URI and
   SHOULD be retrieved using a GET method on that resource. This method
   exists primarily to allow the output of a POST-activated script to
   redirect the user agent to a selected resource. The new URI is not a
   substitute reference for the originally requested resource. The <a href='#303'>303</a>
   response MUST NOT be cached, but the response to the second
   (redirected) request might be cacheable.
<p>
   The different URI SHOULD be given by the Location field in the
   response. Unless the request method was HEAD, the entity of the
   response SHOULD contain a short hypertext note with a hyperlink to
   the new URI(s).
<p>
<b>Note:</b> Many pre-HTTP/1.1 user agents do not understand the <a href='#303'>303</a>
      status. When interoperability with such clients is a concern, the
      <a href='#302'>302</a> status code may be used instead, since most user agents react
      to a <a href='#302'>302</a> response as described here for <a href='#303'>303</a>.
<p>

<h3><a name='304'><font color=purple>10.3.5 304 Not Modified</font></a></h3>
<p>
   If the client has performed a conditional GET request and access is
   allowed, but the document has not been modified, the server SHOULD
   respond with this status code. The <a href='#304'>304</a> response MUST NOT contain a
   message-body, and thus is always terminated by the first empty line
   after the header fields.
<p>
   The response MUST include the following header fields:
<p>
<li> Date, unless its omission is required by section 14.18.1
<p>
   If a clockless origin server obeys these rules, and proxies and
   clients add their own Date to any response received without one (as
   already specified by [RFC 2068], section 14.19), caches will operate
   correctly.
<p>
<li> ETag and/or Content-Location, if the header would have been sent
        in a <a href='#200'>200</a> response to the same request
<p>
<li> Expires, Cache-Control, and/or Vary, if the field-value might
        differ from that sent in any previous response for the same
        variant
<p>
   If the conditional GET used a strong cache validator (see section
   13.3.3), the response SHOULD NOT include other entity-headers.
   Otherwise (i.e., the conditional GET used a weak validator), the
   response MUST NOT include other entity-headers; this prevents
   inconsistencies between cached entity-bodies and updated headers.
<p>
   If a <a href='#304'>304</a> response indicates an entity not currently cached, then the
   cache MUST disregard the response and repeat the request without the
   conditional.
<p>
   If a cache uses a received <a href='#304'>304</a> response to update a cache entry, the
   cache MUST update the entry to reflect any new field values given in
   the response.
<p>

<h3><a name='305'><font color=purple>10.3.6 305 Use Proxy</font></a></h3>
<p>
   The requested resource MUST be accessed through the proxy given by
   the Location field. The Location field gives the URI of the proxy.
   The recipient is expected to repeat this single request via the
   proxy. <a href='#305'>305</a> responses MUST only be generated by origin servers.
<p>
<b>Note:</b> RFC 2068 was not clear that <a href='#305'>305</a> was intended to redirect a
      single request, and to be generated by origin servers only.  Not
      observing these limitations has significant security consequences.
<p>

<h3><a name='306'><font color=purple>10.3.7 306 (Unused)</font></a></h3>
<p>
   The <a href='#306'>306</a> status code was used in a previous version of the
   specification, is no longer used, and the code is reserved.
<p>

<h3><a name='307'><font color=purple>10.3.8 307 Temporary Redirect</font></a></h3>
<p>
   The requested resource resides temporarily under a different URI.
   Since the redirection MAY be altered on occasion, the client SHOULD
   continue to use the Request-URI for future requests.  This response
   is only cacheable if indicated by a Cache-Control or Expires header
   field.
<p>
   The temporary URI SHOULD be given by the Location field in the
   response. Unless the request method was HEAD, the entity of the
   response SHOULD contain a short hypertext note with a hyperlink to
   the new URI(s) , since many pre-HTTP/1.1 user agents do not
   understand the <a href='#307'>307</a> status. Therefore, the note SHOULD contain the
   information necessary for a user to repeat the original request on
   the new URI.
<p>
   If the <a href='#307'>307</a> status code is received in response to a request other
   than GET or HEAD, the user agent MUST NOT automatically redirect the
   request unless it can be confirmed by the user, since this might
   change the conditions under which the request was issued.
<p>

<h2><a name='4'><font color=maroon>10.4 Client Error 4xx</font></a></h2>
<p>
   The <a href='#4'>4xx</a> class of status code is intended for cases in which the
   client seems to have erred. Except when responding to a HEAD request,
   the server SHOULD include an entity containing an explanation of the
   error situation, and whether it is a temporary or permanent
   condition. These status codes are applicable to any request method.
   User agents SHOULD display any included entity to the user.
<p>
   If the client is sending data, a server implementation using TCP
   SHOULD be careful to ensure that the client acknowledges receipt of
   the packet(s) containing the response, before the server closes the
   input connection. If the client continues sending data to the server
   after the close, the server's TCP stack will send a reset packet to
   the client, which may erase the client's unacknowledged input buffers
   before they can be read and interpreted by the HTTP application.
<p>

<h3><a name='400'><font color=purple>10.4.1 400 Bad Request</font></a></h3>
<p>
   The request could not be understood by the server due to malformed
   syntax. The client SHOULD NOT repeat the request without
   modifications.
<p>

<h3><a name='401'><font color=purple>10.4.2 401 Unauthorized</font></a></h3>
<p>
   The request requires user authentication. The response MUST include a
   WWW-Authenticate header field (section 14.47) containing a challenge
   applicable to the requested resource. The client MAY repeat the
   request with a suitable Authorization header field (section 14.8). If
   the request already included Authorization credentials, then the <a href='#401'>401</a>
   response indicates that authorization has been refused for those
   credentials. If the <a href='#401'>401</a> response contains the same challenge as the
   prior response, and the user agent has already attempted
   authentication at least once, then the user SHOULD be presented the
   entity that was given in the response, since that entity might
   include relevant diagnostic information. HTTP access authentication
   is explained in "HTTP Authentication: Basic and Digest Access
   Authentication" [43].
<p>

<h3><a name='402'><font color=purple>10.4.3 402 Payment Required</font></a></h3>
<p>
   This code is reserved for future use.
<p>

<h3><a name='403'><font color=purple>10.4.4 403 Forbidden</font></a></h3>
<p>
   The server understood the request, but is refusing to fulfill it.
   Authorization will not help and the request SHOULD NOT be repeated.
   If the request method was not HEAD and the server wishes to make
   public why the request has not been fulfilled, it SHOULD describe the
   reason for the refusal in the entity.  If the server does not wish to
   make this information available to the client, the status code <a href='#404'>404</a>
   (Not Found) can be used instead.
<p>

<h3><a name='404'><font color=purple>10.4.5 404 Not Found</font></a></h3>
<p>
   The server has not found anything matching the Request-URI. No
   indication is given of whether the condition is temporary or
   permanent. The <a href='#410'>410</a> (Gone) status code SHOULD be used if the server
   knows, through some internally configurable mechanism, that an old
   resource is permanently unavailable and has no forwarding address.
   This status code is commonly used when the server does not wish to
   reveal exactly why the request has been refused, or when no other
   response is applicable.
<p>

<h3><a name='405'><font color=purple>10.4.6 405 Method Not Allowed</font></a></h3>
<p>
   The method specified in the Request-Line is not allowed for the
   resource identified by the Request-URI. The response MUST include an
   Allow header containing a list of valid methods for the requested
   resource.
<p>

<h3><a name='406'><font color=purple>10.4.7 406 Not Acceptable</font></a></h3>
<p>
   The resource identified by the request is only capable of generating
   response entities which have content characteristics not acceptable
   according to the accept headers sent in the request.
<p>
   Unless it was a HEAD request, the response SHOULD include an entity
   containing a list of available entity characteristics and location(s)
   from which the user or user agent can choose the one most
   appropriate. The entity format is specified by the media type given
   in the Content-Type header field. Depending upon the format and the
   capabilities of the user agent, selection of the most appropriate
   choice MAY be performed automatically. However, this specification
   does not define any standard for such automatic selection.
<p>
<b>Note:</b> HTTP/1.1 servers are allowed to return responses which are
      not acceptable according to the accept headers sent in the
      request. In some cases, this may even be preferable to sending a
      <a href='#406'>406</a> response. User agents are encouraged to inspect the headers of
      an incoming response to determine if it is acceptable.
<p>
   If the response could be unacceptable, a user agent SHOULD
   temporarily stop receipt of more data and query the user for a
   decision on further actions.
<p>

<h3><a name='407'><font color=purple>10.4.8 407 Proxy Authentication Required</font></a></h3>
<p>
   This code is similar to <a href='#401'>401</a> (Unauthorized), but indicates that the
   client must first authenticate itself with the proxy. The proxy MUST
   return a Proxy-Authenticate header field (section 14.33) containing a
   challenge applicable to the proxy for the requested resource. The
   client MAY repeat the request with a suitable Proxy-Authorization
   header field (section 14.34). HTTP access authentication is explained
   in "HTTP Authentication: Basic and Digest Access Authentication"
   [43].
<p>

<h3><a name='408'><font color=purple>10.4.9 408 Request Timeout</font></a></h3>
<p>
   The client did not produce a request within the time that the server
   was prepared to wait. The client MAY repeat the request without
   modifications at any later time.
<p>

<h3><a name='409'><font color=purple>10.4.10 409 Conflict</font></a></h3>
<p>
   The request could not be completed due to a conflict with the current
   state of the resource. This code is only allowed in situations where
   it is expected that the user might be able to resolve the conflict
   and resubmit the request. The response body SHOULD include enough
   information for the user to recognize the source of the conflict.
   Ideally, the response entity would include enough information for the
   user or user agent to fix the problem; however, that might not be
   possible and is not required.
<p>
   Conflicts are most likely to occur in response to a PUT request. For
   example, if versioning were being used and the entity being PUT
   included changes to a resource which conflict with those made by an
   earlier (third-party) request, the server might use the <a href='#409'>409</a> response
   to indicate that it can't complete the request. In this case, the
   response entity would likely contain a list of the differences
   between the two versions in a format defined by the response
   Content-Type.
<p>

<h3><a name='410'><font color=purple>10.4.11 410 Gone</font></a></h3>
<p>
   The requested resource is no longer available at the server and no
   forwarding address is known. This condition is expected to be
   considered permanent. Clients with link editing capabilities SHOULD
   delete references to the Request-URI after user approval. If the
   server does not know, or has no facility to determine, whether or not
   the condition is permanent, the status code <a href='#404'>404</a> (Not Found) SHOULD be
   used instead. This response is cacheable unless indicated otherwise.
<p>
   The <a href='#410'>410</a> response is primarily intended to assist the task of web
   maintenance by notifying the recipient that the resource is
   intentionally unavailable and that the server owners desire that
   remote links to that resource be removed. Such an event is common for
   limited-time, promotional services and for resources belonging to
   individuals no longer working at the server's site. It is not
   necessary to mark all permanently unavailable resources as "gone" or
   to keep the mark for any length of time -- that is left to the
   discretion of the server owner.
<p>

<h3><a name='411'><font color=purple>10.4.12 411 Length Required</font></a></h3>
<p>
   The server refuses to accept the request without a defined Content-
   Length. The client MAY repeat the request if it adds a valid
   Content-Length header field containing the length of the message-body
   in the request message.
<p>

<h3><a name='412'><font color=purple>10.4.13 412 Precondition Failed</font></a></h3>
<p>
   The precondition given in one or more of the request-header fields
   evaluated to false when it was tested on the server. This response
   code allows the client to place preconditions on the current resource
   metainformation (header field data) and thus prevent the requested
   method from being applied to a resource other than the one intended.
<p>

<h3><a name='413'><font color=purple>10.4.14 413 Request Entity Too Large</font></a></h3>
<p>
   The server is refusing to process a request because the request
   entity is larger than the server is willing or able to process. The
   server MAY close the connection to prevent the client from continuing
   the request.
<p>
   If the condition is temporary, the server SHOULD include a Retry-
   After header field to indicate that it is temporary and after what
   time the client MAY try again.
<p>

<h3><a name='414'><font color=purple>10.4.15 414 Request-URI Too Long</font></a></h3>
<p>
   The server is refusing to service the request because the Request-URI
   is longer than the server is willing to interpret. This rare
   condition is only likely to occur when a client has improperly
   converted a POST request to a GET request with long query
   information, when the client has descended into a URI "black hole" of
   redirection (e.g., a redirected URI prefix that points to a suffix of
   itself), or when the server is under attack by a client attempting to
   exploit security holes present in some servers using fixed-length
   buffers for reading or manipulating the Request-URI.
<p>

<h3><a name='415'><font color=purple>10.4.16 415 Unsupported Media Type</font></a></h3>
<p>
   The server is refusing to service the request because the entity of
   the request is in a format not supported by the requested resource
   for the requested method.
<p>

<h3><a name='416'><font color=purple>10.4.17 416 Requested Range Not Satisfiable</font></a></h3>
<p>
   A server SHOULD return a response with this status code if a request
   included a Range request-header field (section 14.35), and none of
   the range-specifier values in this field overlap the current extent
   of the selected resource, and the request did not include an If-Range
   request-header field. (For byte-ranges, this means that the first-
   byte-pos of all of the byte-range-spec values were greater than the
   current length of the selected resource.)
<p>
   When this status code is returned for a byte-range request, the
   response SHOULD include a Content-Range entity-header field
   specifying the current length of the selected resource (see section
   14.16). This response MUST NOT use the multipart/byteranges content-
   type.
<p>

<h3><a name='417'><font color=purple>10.4.18 417 Expectation Failed</font></a></h3>
<p>
   The expectation given in an Expect request-header field (see section
   14.20) could not be met by this server, or, if the server is a proxy,
   the server has unambiguous evidence that the request could not be met
   by the next-hop server.
<p>

<h2><a name='5'><font color=maroon>10.5 Server Error 5xx</font></a></h2>
<p>
   Response status codes beginning with the digit "5" indicate cases in
   which the server is aware that it has erred or is incapable of
   performing the request. Except when responding to a HEAD request, the
   server SHOULD include an entity containing an explanation of the
   error situation, and whether it is a temporary or permanent
   condition. User agents SHOULD display any included entity to the
   user. These response codes are applicable to any request method.
<p>

<h3><a name='500'><font color=purple>10.5.1 500 Internal Server Error</font></a></h3>
<p>
   The server encountered an unexpected condition which prevented it
   from fulfilling the request.
<p>

<h3><a name='501'><font color=purple>10.5.2 501 Not Implemented</font></a></h3>
<p>
   The server does not support the functionality required to fulfill the
   request. This is the appropriate response when the server does not
   recognize the request method and is not capable of supporting it for
   any resource.
<p>

<h3><a name='502'><font color=purple>10.5.3 502 Bad Gateway</font></a></h3>
<p>
   The server, while acting as a gateway or proxy, received an invalid
   response from the upstream server it accessed in attempting to
   fulfill the request.
<p>

<h3><a name='503'><font color=purple>10.5.4 503 Service Unavailable</font></a></h3>
<p>
   The server is currently unable to handle the request due to a
   temporary overloading or maintenance of the server. The implication
   is that this is a temporary condition which will be alleviated after
   some delay. If known, the length of the delay MAY be indicated in a
   Retry-After header. If no Retry-After is given, the client SHOULD
   handle the response as it would for a <a href='#500'>500</a> response.
<p>
<b>Note:</b> The existence of the <a href='#503'>503</a> status code does not imply that a
      server must use it when becoming overloaded. Some servers may wish
      to simply refuse the connection.
<p>

<h3><a name='504'><font color=purple>10.5.5 504 Gateway Timeout</font></a></h3>
<p>
   The server, while acting as a gateway or proxy, did not receive a
   timely response from the upstream server specified by the URI (e.g.
   HTTP, FTP, LDAP) or some other auxiliary server (e.g. DNS) it needed
   to access in attempting to complete the request.
<p>
<b>Note:</b> Note to implementors: some deployed proxies are known to
      return <a href='#400'>400</a> or <a href='#500'>500</a> when DNS lookups time out.
<p>

<h3><a name='505'><font color=purple>10.5.6 505 HTTP Version Not Supported</font></a></h3>
<p>
   The server does not support, or refuses to support, the HTTP protocol
   version that was used in the request message. The server is
   indicating that it is unable or unwilling to complete the request
   using the same major version as the client, as described in section
   3.1, other than with this error message. The response SHOULD contain
   an entity describing why that version is not supported and what other
   protocols are supported by that server.
</body></html>
EOF

}

1;