use inc::Module::Install;

all_from      ('lib/App/Smarkmail.pm');

install_script('bin/smarkmail');

requires('Email::MIME'           => 0.000); # minimum unknown
requires('Email::MIME::Creator'  => 0.000); # minimum unknown
requires('Email::MIME::Modifier' => 0.000); # minimum unknown
requires('Email::Sender'         => 0.000); # requires any release
requires('HTML::Entities'        => 0.000); # minimum unknown
requires('Text::Markdown'        => 0.000); # minimum unknown

repository('http://github.com/rjbs/app-smarkmail');

author_tests('xt');
auto_manifest;

WriteAll();
