#!/usr/bin/env perl
#-*-mode: Perl; coding: utf-8;-*-
use diagnostics;
use warnings;
use strict;
use Test::More qw(no_plan);

BEGIN {
  use_ok('test_helper');
  use_ok('Orb::Install');
  use_ok('Orb::Test');
}

isnt(Orb::Install::latest_perl_from_web, 'unknown',
     'We can parse the latest perl release.');

ok(Orb::Install::latest_perl_from_web eq $Orb::Test::test_perl_version,
   "Latest perl version expected ($Orb::Test::test_perl_version).");

ok(Orb::Install::latest_perl_from_web ne '5.18.0',
     '5.18.0 isn\'t the latest perl');

isnt(Orb::Install::latest_ruby_from_web, 'unknown',
     'We can parse the latest ruby release.');

ok(Orb::Install::latest_ruby_from_web eq $Orb::Test::test_ruby_version,
    "Latest version of ruby expected ($Orb::Test::test_ruby_version).");

isnt(Orb::Install::latest_jruby_from_web, 'unknown',
     'We can parse the latest jruby release.');

ok(Orb::Install::latest_jruby_from_web eq $Orb::Test::test_jruby_version,
    "Latest version of ruby expected ($Orb::Test::test_jruby_version).");

ok(Orb::Install::python_download_url('1.2.3') eq
  'http://python.org/ftp/python/1.2.3/Python-1.2.3.tgz',
   'python_download_url');

isnt(Orb::Install::latest_python_from_web, 'unknown',
     'We can parse the latest python3 release.');

ok(Orb::Install::latest_python_from_web eq $Orb::Test::test_python_version,
   "Latest version of python 3.0 expected ($Orb::Test::test_python_version).");
