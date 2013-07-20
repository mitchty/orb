#!/usr/bin/env perl
#-*-mode: Perl; coding: utf-8;-*-
use diagnostics;
use warnings;
use strict;
use Test::More qw(no_plan);

use test_helper;

use Orb::Install;

isnt(Orb::Install::latest_perl_from_web, 'unknown');
is(Orb::Install::latest_perl_from_web, '5.18.0');

isnt(Orb::Install::latest_ruby_from_web, 'unknown');
is(Orb::Install::latest_ruby_from_web, '2.0.0-p247');

isnt(Orb::Install::latest_jruby_from_web, 'unknown');
is(Orb::Install::latest_jruby_from_web, '1.7.4');
