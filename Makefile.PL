
use strict;
use warnings;

use inc::Module::Install;

name          ('App-Smarkmail');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
all_from      ('lib/App/Smarkmail.pm');

install_script('bin/smarkmail');

requires('Email::MIME'               => 0.000); # minimum unknown
requires('Email::MIME::Creator'      => 0.000); # minimum unknown
requires('Email::MIME::Modifier'     => 0.000); # minimum unknown
requires('Email::Sender::Sendmail'   => 0.000); # requires any release
requires('Text::Markdown'            => 0.000); # minimum unknown
requires('HTML::Entities'            => 0.000); # minimum unknown

WriteAll();
