#-*-mode: Perl; coding: utf-8;-*-
package Orb::Test;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use POSIX qw(getcwd);

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw($test_perl_version $test_ruby_version $test_jruby_version $test_python_version)],
);

our $test_perl_version = '5.18.2';
our $test_ruby_version = '2.1.0';
our $test_jruby_version = '1.7.10';
our $test_python_version = '3.3.3';

1;
