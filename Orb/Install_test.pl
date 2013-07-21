#!/usr/bin/env perl
#-*-mode: Perl; coding: utf-8;-*-
use diagnostics;
use warnings;
use strict;
use Test::More qw(no_plan);

BEGIN {
  use_ok('test_helper');
  use_ok('Orb::Install');
}

isnt(Orb::Install::latest_perl_from_web, 'unknown', 'We can parse the latest perl release.');
ok(Orb::Install::latest_perl_from_web, '5.18.0');

isnt(Orb::Install::latest_ruby_from_web, 'unknown', 'We can parse the latest ruby release.');
ok(Orb::Install::latest_ruby_from_web, '2.0.0-p247');

isnt(Orb::Install::latest_jruby_from_web, 'unknown', 'We can parse the latest jruby release.');
ok(Orb::Install::latest_jruby_from_web, '1.7.4');

isnt(Orb::Install::latest_python_from_web, 'unknown', 'We can parse the latest python3 release.');
ok(Orb::Install::latest_python_from_web, '3.3.2');

ok(Orb::Install::python_download_url('1.2.3') eq
  'http://python.org/ftp/python/1.2.3/Python-1.2.3.tgz', 'python_download_url');
