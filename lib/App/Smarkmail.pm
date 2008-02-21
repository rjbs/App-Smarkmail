use strict;
use warnings;
package App::Smarkmail;

use Email::MIME;
use Email::MIME::Creator;
use Email::MIME::Modifier;
use Text::Markdown;

sub markdown_email {
  my ($self, $msg, $arg) = @_;

  my $to_send = eval { ref $msg and $msg->isa('Email::MIME') }
              ? $msg
              : Email::MIME->new($msg);

  if ($to_send->content_type =~ m{^text/plain}) {
    my ($text, $html) = $self->_parts_from_text($to_send);

    $to_send->content_type_set('multipart/alternative');
    $to_send->parts_set([ $html, $text ]);
  } elsif ($to_send->content_type =~ m{^multipart/(?:related|mixed)}) {
    my @parts = $to_send->subparts;
    if ($parts[0]->content_type =~ m{^text/plain}) {
      my ($text, $html) = $self->_parts_from_text(shift @parts);

      my $alt = Email::MIME->create(
        attributes => { content_type => 'multipart/alternative' },
        parts      => [ $html, $text ],
      );

      $to_send->parts_set([ $alt, @parts ]);
    }
  }

  return $to_send;
}

sub _parts_from_text {
  my ($self, $email) = @_;

  my $text = $email->body;
  my $html = Text::Markdown::markdown($text, { tab_width => 2 });

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
