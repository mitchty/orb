#!/usr/bin/env perl
#-*-mode: Perl; coding: utf-8;-*-
use File::Basename qw(fileparse dirname);
use Cwd qw(abs_path);

my (undef, $dir, undef) = fileparse($0);
$dir = abs_path(dirname($dir) . '/..');

push(@INC, $dir) if (grep(@INC, $dir));
