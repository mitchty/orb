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

isnt(Orb::Install::latest_perl_from_web, 'unknown',
     'We can parse the latest perl release.');

ok(Orb::Install::latest_perl_from_web eq '5.18.1',
   "Latest perl version expected.");

ok(Orb::Install::latest_perl_from_web ne '5.18.0',
     '5.18.0 isn\'t the latest perl');

isnt(Orb::Install::latest_ruby_from_web, 'unknown',
     'We can parse the latest ruby release.');

ok(Orb::Install::latest_ruby_from_web eq '2.0.0-p353',
    'Latest version of ruby expected.');

isnt(Orb::Install::latest_jruby_from_web, 'unknown',
     'We can parse the latest jruby release.');

ok(Orb::Install::latest_jruby_from_web eq '1.7.9',
    'Latest version of ruby expected.');

ok(Orb::Install::python_download_url('1.2.3') eq
  'http://python.org/ftp/python/1.2.3/Python-1.2.3.tgz',
   'python_download_url');

isnt(Orb::Install::latest_python_from_web, 'unknown',
     'We can parse the latest python3 release.');

ok(Orb::Install::latest_python_from_web eq '3.3.3',
   'Latest version of python 3.0 expected');
