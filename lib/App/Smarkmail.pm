use strict;
use warnings;
package App::Smarkmail;

use Email::MIME;
use Email::MIME::Creator;
use Email::MIME::Modifier;
use HTML::Entities ();
use Text::Markdown;

sub markdown_email {
  my ($self, $msg, $arg) = @_;

  my $to_send = eval { ref $msg and $msg->isa('Email::MIME') }
              ? $msg
              : Email::MIME->new($msg);

  if ($to_send->content_type =~ m{^text/plain}) {
    my ($text, $html) = $self->_parts_from_text($to_send);

    $to_send->content_type_set('multipart/alternative');
    $to_send->parts_set([ $text, $html ]);
  } elsif ($to_send->content_type =~ m{^multipart/(?:related|mixed)}) {
    my @parts = $to_send->subparts;
    if ($parts[0]->content_type =~ m{^text/plain}) {
      my ($text, $html) = $self->_parts_from_text(shift @parts);

      my $alt = Email::MIME->create(
        attributes => { content_type => 'multipart/alternative' },
        parts      => [ $text, $html ],
      );

      $to_send->parts_set([ $alt, @parts ]);
    }
  }

  return $to_send;
}

sub _parts_from_text {
  my ($self, $email) = @_;

  my $text = $email->body;
  my ($body, $sig) = split /^-- $/m, $text, 2;

  if (($sig =~ tr/\n/\n/) > 5) {
    $body = $text;
    $sig  = '';
  }

  my $html = Text::Markdown::markdown($body, { tab_width => 2 });

  if ($sig) {
    $html .= sprintf "<pre><code>-- %s</code></pre>",
             HTML::Entities::encode_entities($sig);
  }

  my $html_part = Email::MIME->create(
    attributes => { content_type => 'text/html', },
    body       => $html,
  );

  my $text_part = Email::MIME->create(
    attributes => { content_type => 'text/plain', },
    body       => $text,
  );

  return ($text_part, $html_part);
}

1;
