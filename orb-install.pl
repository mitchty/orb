#!/usr/bin/env perl
#-*-mode: Perl; coding: utf-8;-*-
# RVM has pissed me off for the last time, all I need is to install a ruby
# on a few systems to my local home dir for testing. Nothing special.
#
# Basically, use curl to get yaml, install it to a prefix etc... and then
# configure to statically use that libyaml and install dir.
#
# Also get the latest libffi and install that just in case.
#
# Simple(ish). In perl since I can't depend on ruby everywhere and because
# shell sucks.
#
# Shut perlcritic up a skosh about things I abuse in the script.
## no critic (Variables::ProhibitPunctuationVars)
## no critic (Variables::ProhibitMatchVars)
## no critic (ValuesAndExpressions::RequireQuotedHeredocTerminator)
## no critic (Miscellanea::ProhibitUselessNoCritic)
## no critic (Subroutines::RequireFinalReturn)

use strict;
use warnings;

use Getopt::Long;
use Env qw(HOME LDFLAGS CPPFLAGS);
use File::Path qw(make_path);

# Globals, run away
my $base_prefix    = "$HOME"/.orb;
my $default_prefix = "$base_prefix/.rubies";
my $install_prefix = $default_prefix;
my $cache_dir      = "$base_prefix/.cache";
my $install_yaml   = 1;
my $install_ffi    = 1;
my $append_prefix  = 1;
my $ruby_vm        = 'default';
my $ruby_version   = 'default';
my $rm_existing    = 0;
my $suffix         = undef;

# ruby vm defaults
my $default_ruby  = '1.9.3-p327';
my $default_jruby = '1.7.0';
my $default_rbx   = 'head';

# Defining say here only due to wanting to be able to be run on perls
# older than 5.10ish.
unless ( defined say() ) { ## no critic (CodeLayout::ProhibitParensWithBuiltins)
  ## no critic (Subroutines::RequireArgUnpacking)
  sub say {                ## no critic (Subroutines::ProhibitBuiltinHomonyms)

    local $\ = "\n";
    foreach my $line (@_) { print $line; }
    return;
  }
}

GetOptions(
            'prefix=s'  => \$install_prefix,
            'no-yaml'   => sub { $install_yaml = 0; },
            'no-ffi'    => sub { $install_ffi = 0; },
            'ruby=s'    => \$ruby_vm,
            'version=s' => \$ruby_version,
            'cache=s'   => \$cache_dir,
            'no-append' => sub { $append_prefix = 0; },
            'append'    => sub { $append_prefix = 1; },
            'rm'        => sub { $rm_existing = 1; },
            'suffix=s'  => \$suffix,
            'help' => sub { help(1); },
            'h'    => sub { help(1); },
          ) or help(1);

sub help {
  my $rc = shift || 1;
  my $message = <<FIN;
usage:
$0 --prefix=$install_prefix
  --cache=$cache_dir
  --ruby=[ruby|jruby|rbx] --version=[head|vm_version]
  --no-yaml --no-ffi --rm

  Options:
    --ruby     What ruby to install, ruby/rbx/jruby.
      Default: ruby
    --version  What version of ruby to install, reference defaults.
      Note:    if you specify head on any you will get the latest master
      Default: ruby  = $default_ruby
               jruby = $default_jruby
               rbx   = $default_rbx (from git)
    --prefix   What directory to install to, need to have write perms.
      Default: $install_prefix
    --cache    Where to save what we download.
      Default: $cache_dir
    --no-yaml  Don't install libyaml, normally libyaml is installed so
               rubygems doesn't bitch about psych, all.. the... damntime.
      Note:    installs libyaml-0.1.4
    --no-ffi   Don't install libffi.
      Note:    installs libffi-git

    --rm       Remove the install to dir before installing.
      Note:    Only allowed if prefix isn't set.
    --append   Append a string to the install to allow tagging.
      Example: --append=foo with defaults results in ruby-versionpatch-append
      Default: nope
    --no-append  Append the ruby/version information to the prefix install?
      Default: Append. Say prefix is /tmp/foo, with this on you would
               Install to /tmp/foo/ruby-1.9.3-p0 for example.
FIN
  say $message;
  exit $rc;
}

sub rubyurl {
  my $version = shift;
  $version =~ /\d[.]\d+/sm;
  my $major   = $&;
  my $out_url = "http://ftp.ruby-lang.org/pub/ruby/$major/ruby-$version.tar.gz";
  return $out_url;
}

sub sanity_check {
  my $insane = 0;
  qx{ curl -V };
  $insane = $insane ^ $?;
  warn 'Oh snap! Didn\'t find a working curl install.' if $?;
  qx{git --version};
  $insane = $insane ^ $?;
  warn 'Oh snap! Didn\'t find a working git install.' if $?;

  unless ( -d $cache_dir ) {
    make_path $cache_dir or die "Cannot create $cache_dir!\n";
  }

  full_rubyversion();

  $append_prefix = 0 if ( $default_prefix ne $install_prefix );

  if ($append_prefix) {
    $install_prefix = "$install_prefix/$ruby_vm-$ruby_version";
    if ($suffix) {
      $install_prefix = "$install_prefix" . "\%$suffix";
    }
    if ( -d $install_prefix ) {
      say "Removing existing install $install_prefix";
      system "rm -fr $install_prefix";
    }
  }

  return $insane;
}

sub curl_get {
  my $url = shift;
  my $pwd = qx{pwd};
  chdir $cache_dir;
  system "curl -L -O '$url'";
  chdir $pwd;
  return $?;
}

sub url_filename {
  my $url  = shift;
  my $file = undef;
  if ( $url =~ /.*\/(.*)$/sm ) {
    $file = $1;
  }
  return $file;
}

sub fetch_url {
  my $url    = shift;
  my $exists = "$cache_dir/" . url_filename($url);
  my $ok     = 0;
  if ( -f $exists ) {
    say "Found $exists will not redownload.";
  } else {
    say "$exists not found\nTrying to download $url";

    my $rc = curl_get($url);
    warn "nonzero exit from curl $rc on url $url" if $rc;
    $ok = $ok ^ $rc;
  }
  return $ok;
}

sub full_rubyversion {
  my %vm_map =
    ( 'ruby', $default_ruby, 'rbx', $default_rbx, 'jruby' => $default_jruby );
  $ruby_vm = ( $ruby_vm eq 'default' ) ? 'ruby' : $ruby_vm;
  $ruby_version =
    ( $ruby_version eq 'default' ) ? $vm_map{$ruby_vm} : $ruby_version;
  say "Will try to build/install $ruby_vm at version $ruby_version";
  return;
}

sub extract_tgz {
  my $file = shift;
  my $pwd  = qx{pwd};
  say "gunzip -c $file | tar xf -";
  chdir $cache_dir;
  system "gunzip -c $file | tar xf -";
  die "Extract of $file failed.\n" if $?;
  chdir $pwd;
  return $?;
}

sub configure_dir {
  my $dir  = shift;
  my $args = shift;
  chdir $dir;
  system "./configure $args";
  die "Configure failed\n" if $?;
  return $?;
}

sub build_install {
  my $dir = shift;
  chdir $dir;
  system 'make && make install';
  die "make failed\n" if $?;
  return $?;
}

sub install_yaml {
  my $url      = 'http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz';
  my $dirname  = 'yaml-0.1.4';
  my $filename = "$cache_dir/" . url_filename($url);
  chdir $cache_dir;
  fetch_url($url);
  extract_tgz($filename);
  configure_dir( $dirname, "--prefix=$install_prefix" );
  build_install($dirname);
  return;
}

sub fetch_git {
  my $url      = shift;
  my $dirname  = shift;
  my $branch   = shift || 'master';
  my $full_dir = "$cache_dir\/$dirname";

  if ( -d $full_dir ) {
    chdir $full_dir;
    system 'git pull';
    die "git pull of $url failed\n" if $?;
    system 'git reset --hard HEAD';
    die "git reset hard failed\n" if $?;
  } else {
    my $cmd = "git clone $url $full_dir";
    $cmd = "git clone --branch $branch $url $full_dir"
      unless $branch eq 'master';
    system $cmd;
    die "git clone of $url failed\n" if $?;
  }
  return;
}

sub install_ffi {
  my $dirname = 'libffi-git';
  fetch_git( 'https://github.com/atgreen/libffi', $dirname );
  chdir "$cache_dir/$dirname";
  system 'make clean';
  configure_dir( $dirname, "--prefix=$install_prefix" );
  build_install($dirname);
  return;
}

sub install_ruby {
  $LDFLAGS = ( defined($LDFLAGS) ? $LDFLAGS : q{} ) . " -L$install_prefix/lib";
  $CPPFLAGS =
    ( defined($CPPFLAGS) ? $CPPFLAGS : q{} ) . " -L$install_prefix/include";

  install_ffi  if $install_ffi;
  install_yaml if $install_yaml;

  my $dirname = q{};
  my $configure =
"--prefix=$install_prefix --disable-tk --disable-tcl --disable-install-doc --enable-pthread --with-opt-dir=$install_prefix --with-static-linked-ext --disable-tcltk";
  if ( $ruby_version ne 'head' ) {
    my $url  = rubyurl("$ruby_version");
    my $file = url_filename($url);
    $dirname = "$cache_dir/$file";
    $dirname =~ s/[.]tar[.]gz//sm;
    my $filename = "$cache_dir/$file";
    fetch_url($url);
    extract_tgz($filename);
    chdir "$cache_dir\/$dirname";
    configure_dir( $dirname, $configure );
  } else {
    $dirname = 'ruby-git';
    fetch_git( 'https://github.com/ruby/ruby', $dirname );
    chdir "$cache_dir\/$dirname";
    system 'make clean';
    system 'autoconf';
    if ( $^O eq 'darwin' ) {
      $configure = "CC=clang $configure";
    }
    configure_dir( $dirname, "$configure" );
  }
  build_install($dirname);
  return;
}

sub install_rbx {
  $LDFLAGS = ( defined($LDFLAGS) ? $LDFLAGS : q{} ) . " -L$install_prefix/lib";
  $CPPFLAGS =
    ( defined($CPPFLAGS) ? $CPPFLAGS : q{} ) . " -L$install_prefix/include";

  install_yaml if $install_yaml;

  chdir $cache_dir;
  my $dirname = 'rbx-git';
  my $fulldir = "$cache_dir\/$dirname";
  my $configure =
"--prefix=$install_prefix --default-version=19 --with-include-dir=$install_prefix/include --with-lib-dir=$install_prefix/lib";
  fetch_git( 'https://github.com/rubinius/rubinius', $dirname );
  chdir $fulldir;
  system 'rake clean';
  configure_dir( $dirname, $configure );
  system 'rake install';
  return;
}

sub install_jruby {
  chdir $cache_dir;
  my $dirname = q{};
  if ( $ruby_version ne 'head' ) {
    my $url =
"http://jruby.org.s3.amazonaws.com/downloads/$ruby_version/jruby-bin-$ruby_version.tar.gz";
    my $file = url_filename($url);
    $dirname = $file;
    $dirname =~ s/[.]tar[.]gz//sm;
    $dirname =~ s/bin[-]//sm;

    my $extract_dir = $dirname;
    $extract_dir =~ s/[-]bin//sm;
    my $filename = "$cache_dir/$file";
    fetch_url($url);
    extract_tgz($filename);

    say 'Removing windows stuffs.';
    my $cmd =
"rm -f $extract_dir/bin/*.exe $extract_dir/bin/*.dll $extract_dir/bin/*.bat $extract_dir/bin/jruby.sh";
    say $cmd;
    system $cmd;
    system "mv $extract_dir $install_prefix";
    chdir "$install_prefix\/bin";
    system 'ln -s jruby ruby';
  } else {
    $dirname = 'jruby-git';
    fetch_git( 'https://github.com/jruby/jruby', $dirname );
    chdir "$cache_dir\/$dirname";
    chdir 'jruby';
    system 'ant clean';
    system 'ant';
    system 'ant dist';
    chdir 'dist';
    my $dir = qx(pwd);
    chomp($dir);
    my $distfile = <jruby-bin*tar.gz>;
    my $distfile_full = "$dir/" . $distfile;

    if ( -f $distfile ) {
      extract_tgz($distfile_full);
      my $extract_dir = $distfile;
      $extract_dir =~ s/[.]tar[.]gz//sm;
      $extract_dir =~ s/[-]bin//sm;
      say $extract_dir;
      system "mv $extract_dir $install_prefix";
      jruby_finalize($install_prefix);
    }else {
      say "zomg";
    }
  }
  return;
}

sub jruby_finalize {
  my $pwd = qx(pwd);
  my $dir = shift;
  say 'Removing windows stuffs.';
  my $cmd =
"rm -f $dir/bin/*.exe $dir/bin/*.dll $dir/bin/*.bat $dir/bin/jruby.sh";
  say $cmd;
  system $cmd;
  chdir "$dir\/bin";
  system 'ln -s jruby ruby';
  chdir $pwd;
  return;
}

my %install_switch = (
                       'ruby',  sub { install_ruby(); },
                       'rbx',   sub { install_rbx(); },
                       'jruby', sub { install_jruby(); },
                     );

if ( sanity_check() ) {
  say 'Cannot continue without a sane installation of above junk.';
} else {
  $install_switch{$ruby_vm}();
}
