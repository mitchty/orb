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
use Env
  qw(HOME LDFLAGS CPPFLAGS TMPDIR orb_base orb_cache orb_logs orb_ruby_base orb_perl_base orb_python_base);
use POSIX qw(getcwd);
use File::Basename qw(dirname basename);
use File::Temp qw(tempdir);

# Defining say here only due to wanting to be able to be run on perls
# older than 5.10ish.

## no critic (CodeLayout::ProhibitParensWithBuiltins)
## no critic (Subroutines::RequireArgUnpacking)
## no critic (Subroutines::ProhibitBuiltinHomonyms)
unless ( defined say() ) {

  sub say {
    local $\ = "\n";
    foreach my $line (@_) { print $line; }
    return;
  }
}

my $script_language = 'unknown';
my $script_name     = basename($0);

if ( $script_name =~ /^(perl|python|ruby)[-]/mxsi ) {
  $script_language = $&;
  $script_language =~ s/[-]//msg;
}

my %lang_dir_map = (
                     'ruby'    => 'rubies',
                     'perl'    => 'perls',
                     'python'  => 'pythons',
                     'unknown' => 'unknowns',
                   );

# Globals, run away
my $base_prefix    = ( defined $orb_base ) ? $orb_base : "$HOME/.orb";
my $default_prefix = $base_prefix . q{/} . $lang_dir_map{$script_language};
my $install_prefix = $default_prefix;
my $cache_dir      = ( defined $orb_cache ) ? $orb_cache : "$base_prefix/cache";
my $log_dir        = ( defined $orb_logs ) ? $orb_logs : "$cache_dir\/logs";

# handle orb_{ruby|perl|python}_base env variables.
if ( $script_language eq 'ruby' ) {
  $install_prefix =
    ( defined $orb_ruby_base )
    ? $orb_ruby_base
    : $install_prefix;
} elsif ( $script_language eq 'perl' ) {
  $install_prefix =
    ( defined $orb_perl_base ) ? $orb_perl_base : $install_prefix;
} elsif ( $script_language eq 'python' ) {
  $install_prefix =
    ( defined $orb_python_base ) ? $orb_python_base : $install_prefix;
}

my $install_yaml  = 1;
my $install_ffi   = 1;
my $append_prefix = 1;
my $lang_vm       = 'default';
my $lang_version  = 'default';
my $rm_existing   = 0;
my $suffix        = undef;
my $debug_flag    = 1;
my $verbose_flag  = 1;
my $tmp_base      = ( defined $TMPDIR ) ? $TMPDIR : '/tmp';

# perl specific
my $perl_install_cpanm = 0;
my $perl_run_tests     = 1;

# language vm defaults
my %lang_defaults = (
                      'ruby'  => '2.0.0-p0',
                      'jruby' => '1.7.3',
                      'rbx'   => 'head',
                      'perl'  => '5.16.3',
                    );

my $help_message = 'default help message';

sub help {
  my $rc = shift || 1;
  say $help_message;
  exit $rc;
}

# Hacky, but it'll do.
if ( $script_language eq 'ruby' ) {
  $help_message = <<FIN;
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
      Default: ruby  = $lang_defaults{'ruby'}
               jruby = $lang_defaults{'jruby'}
               rbx   = $lang_defaults{'rbx'} (from git)
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

  GetOptions(
              'prefix=s'  => \$install_prefix,
              'no-yaml'   => sub { $install_yaml = 0; },
              'no-ffi'    => sub { $install_ffi = 0; },
              'ruby=s'    => \$lang_vm,
              'version=s' => \$lang_version,
              'cache=s'   => \$cache_dir,
              'no-append' => sub { $append_prefix = 0; },
              'append'    => sub { $append_prefix = 1; },
              'rm'        => sub { $rm_existing = 1; },
              'suffix=s'  => \$suffix,
              'tmp=s'     => \$tmp_base,
              'debug'     => sub { $debug_flag = 0; },
              'd'         => sub { $debug_flag = 0; },
              'verbose'   => sub { $verbose_flag = 0; },
              'v'         => sub { $verbose_flag = 0; },
              'help' => sub { help(1); },
              'h'    => sub { help(1); },
            )
    or help(1);

} elsif ( $script_language eq 'perl' ) {
  $help_message = <<FIN;
usage:
$0 --prefix=$install_prefix
  --cache=$cache_dir
  --version=[head|vm_version]

  Options:
    --version  What version of perl to install, reference defaults.
      Note:    if you specify head on any you will get the latest master
      Default: perl = $lang_defaults{'perl'}
    --prefix   What directory to install to, need to have write perms.
      Default: $install_prefix
    --cache    Where to save what we download.
      Default: $cache_dir
    --rm       Remove the install to dir before installing.
      Note:    Only allowed if prefix isn't set.
    --append   Append a string to the install to allow tagging.
      Example: --append=foo with defaults results in perl-version
      Default: nope
    --no-append  Append the perl/version information to the prefix install?
      Default: Append. Say prefix is /tmp/foo, with this on you would
               Install to /tmp/foo/perl-5.16.2 for example.
FIN

  GetOptions(
    'prefix=s'  => \$install_prefix,
    'version=s' => \$lang_version,
    'cache=s'   => \$cache_dir,
    'no-append' => sub { $append_prefix = 0; },
    'append'    => sub { $append_prefix = 1; },
    'rm'        => sub { $rm_existing = 1; },
    'suffix=s'  => \$suffix,
    'no-cpanm'  => sub { $perl_install_cpanm = 1; },

    # yes this is wonky, its inverted for a later conditional
    # it makes the if test more readable... ish
    'no-test' => sub { $perl_run_tests = 0; },
    'debug'   => sub { $debug_flag     = 0; },
    'd'       => sub { $debug_flag     = 0; },
    'tmp=s'   => \$tmp_base,
    'verbose' => sub { $verbose_flag   = 0; },
    'v'       => sub { $verbose_flag   = 0; },
    'help' => sub { help(1); },
    'h'    => sub { help(1); },
            )
    or help(1);

} else {
  say $script_language;
  say "no idea what is being asked, was called as \"$script_name\"";
  exit 1;
}

# logs a commands output to:
# $log_dir/$lang_vm-$lang_version.log
sub log_cmd {
  my $cmd = shift;
  system("mkdir -p $log_dir") unless ( -d $log_dir );

  my $logfile = "$log_dir\/$lang_vm-$lang_version\.log";
  say $cmd;

  my $full_cmd = undef;
  if ( $debug_flag ^ $verbose_flag ) {
    $full_cmd = "$cmd 2>&1 | tee -a $logfile";
  } else {
    $full_cmd = "$cmd 1>$logfile 2>&1";
  }

  system $full_cmd;

  ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
  my $rc = $? >> 8;    # should deal with signal/coredumps a better way

  my $pwd = getcwd();

  ## no critic (InputOutput::RequireCheckedOpen)
  ## no critic (InputOutput::RequireCheckedClose)
  ## no critic (InputOutput::RequireCheckedSyscalls)
  ## no critic (InputOutput::RequireBracedFileHandleWithPrint)
  open( my $fh, '>>', $logfile );
  print $fh "$cmd return code was $rc\n";
  print $fh "cwd was $pwd\n";
  close $fh;

  return $rc;
}

sub rubyurl {
  my $version = shift;
  $version =~ /\d[.]\d+/sm;
  my $major   = $&;
  my $out_url = "http://ftp.ruby-lang.org/pub/ruby/$major/ruby-$version.tar.gz";
  return $out_url;
}

sub perlurl {
  my $version = shift;
  $version =~ /(\d)[.]\d+/sm;
  ## no critic (RegularExpressions::ProhibitCaptureWithoutTest)
  my $major =
    ($1)
    ? "$1\.0"
    : die "Can't determine perl version from input $version\n";
  my $out_url = "http://www.cpan.org/src/$major/perl-$version.tar.gz";
  return $out_url;
}

sub full_vm_version {
  my %vm_map = (
                 'ruby'  => $lang_defaults{'ruby'},
                 'rbx'   => $lang_defaults{'rbx'},
                 'jruby' => $lang_defaults{'jruby'},
                 'perl'  => $lang_defaults{'perl'},
               );

  my %vm_defaults = (
                      'ruby' => 'ruby',
                      'perl' => 'perl',
                    );

  $lang_vm = ( $lang_vm eq 'default' ) ? $script_language : $lang_vm;
  $lang_version =
    ( $lang_version eq 'default' ) ? $vm_map{$lang_vm} : $lang_version;

  say "Will try to build/install $lang_vm at version $lang_version";

  return;
}

sub sanity_check {
  qx{curl -V};
  warn "curl may not be installed, curl -V didn't return 0" if ($? >> 8);
  qx{git --version};
  warn "git may not be installed git --version didn't return 0" if ($? >> 8);

  unless ( -d $cache_dir ) {
    qx/mkdir -p $cache_dir/;
    warn "Cannot create $cache_dir\n" if ($? >> 8);
  }

  $File::Temp::DEBUG = !$debug_flag;

  full_vm_version();

  $append_prefix = 0 if ( $default_prefix ne $install_prefix );

  if ($append_prefix) {
    unless ( -d $install_prefix ){
      my $rc = log_cmd "mkdir -p $install_prefix";
      die "mkdir on $install_prefix failed\n" if ($? >> 8);
    }
    $install_prefix = "$install_prefix/$lang_vm-$lang_version";
    if ($suffix) {
      $install_prefix = "$install_prefix" . "\%$suffix";
    }
    if ( -d $install_prefix and $rm_existing ) {
      say "Removing existing install $install_prefix";
      log_cmd "rm -fr $install_prefix";
    }
  }

  say "Installing to $install_prefix";

  return 0;
}

sub curl_get {
  my $url = shift;
  my $pwd = getcwd();
  my $rc  = 0;
  chdir $cache_dir;

  $rc = log_cmd "curl --progress-bar --location --remote-name '$url'";
  die "curl failed to download $url\n" if $rc;

  chdir $pwd;
  return $rc;
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
  chdir $cache_dir;

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
  my %vm_map = (
                 'ruby'  => $lang_defaults{'ruby'},
                 'rbx'   => $lang_defaults{'rbx'},
                 'jruby' => $lang_defaults{'jruby'},
               );
  $lang_vm = ( $lang_vm eq 'default' ) ? 'ruby' : $lang_vm;
  $lang_version =
    ( $lang_version eq 'default' ) ? $vm_map{$lang_vm} : $lang_version;
  say "Will try to build/install $lang_vm at version $lang_version";
  return;
}

sub extract_tgz {
  my $file    = shift;
  my $tmp_dir = tempdir( DIR => $tmp_base, CLEANUP => 1 );
  my $rc      = 0;

  chdir $tmp_dir;

  $rc = log_cmd "gunzip -c $file | tar xf -";
  die "Extract of $file failed.\n" if $rc;
  return $tmp_dir;
}

sub configure_dir {
  my $dir  = shift;
  my $args = shift;
  my $rc   = 0;
  chdir $dir;

  $rc = log_cmd "./configure $args";
  die "Configure failed\n" if $rc;
  return;
}

sub build_with {
  my $tool = shift;
  my $dir  = shift;
  my @rest = @_;
  my $rc   = 0;
  chdir $dir;

  # default rake task includes testing, NOPE
  unless ( $lang_vm eq 'rbx' ) {
    $rc = log_cmd $tool;
    die "$tool failed $rc\n" if $rc;
  }

  for my $cmd (@rest) {
    my $make_cmd = "$tool $cmd";
    $rc = log_cmd $make_cmd;
    die "$make_cmd failed\n" if $rc;
  }
  return $rc;
}

sub install_yaml {
  say 'Installing libyaml.';
  my $yaml_version = '0.1.4';
  my $destdir      = "yaml-$yaml_version";
  my $url          = "http://pyyaml.org/download/libyaml/$destdir.tar.gz";
  my $filename     = url_filename($url);
  fetch_url($url);
  my $dir = extract_tgz("$cache_dir\/$filename") . q{/} . $destdir;
  configure_dir( $dir, "--prefix=$install_prefix" );
  build_with( 'make', $dir, 'install' );
  return;
}

sub fetch_git {
  my $url      = shift;
  my $dirname  = shift;
  my $branch   = shift || 'master';
  my $full_dir = "$cache_dir\/$dirname";

  my $rc = 0;
  if ( -d $full_dir ) {
    chdir $full_dir;
    $rc = log_cmd 'git pull';
    die "git pull of $url failed\n" if $rc;
    $rc = log_cmd 'git reset --hard HEAD';
    die "git reset hard failed\n" if $rc;
  } else {
    my $cmd = "git clone $url $full_dir";
    $cmd = "git clone --branch $branch $url $full_dir"
      unless $branch eq 'master';
    $rc = log_cmd $cmd;
    die "git clone of $url failed\n" if $rc;
  }

  # k so now shallow clone to a temporary directory
  my $tmp_dir = tempdir( DIR => $tmp_base, CLEANUP => 1 );
  my $cmd = "git clone --depth 1 file://$full_dir $tmp_dir";
  $rc = log_cmd $cmd;
  die "git shallow clone failed\n" if $rc;
  return $tmp_dir;
}

sub install_ffi {
  say 'Installing ffi.';
  my $dirname = 'libffi-git';
  my $dir = fetch_git( 'https://github.com/atgreen/libffi', $dirname );
  configure_dir( $dir, "--prefix=$install_prefix" );
  build_with( 'make', $dir, 'install' );
  return;
}

sub install_ruby {
  if ( $install_ffi or $install_yaml ) {
    if ( defined($LDFLAGS) ) {
      $LDFLAGS = "$LDFLAGS -L$install_prefix/lib";
    }

    if ( defined($CPPFLAGS) ) {
      $CPPFLAGS = "$CPPFLAGS -L$install_prefix/include";
    }

    install_ffi()  if $install_ffi;
    install_yaml() if $install_yaml;
    tmp_cleanup();
  }

  my $dir = q{};
  my $configure =
"--prefix=$install_prefix --with-opt-dir=$install_prefix --with-out-ext=tcl --with-out-ext=tk";

  if ( $lang_version ne 'head' ) {
    my $url  = rubyurl("$lang_version");
    my $file = url_filename($url);

    $dir = $file;
    $dir =~ s/[.]tar[.]gz//sm;

    my $filename = "$cache_dir/$file";

    fetch_url($url);

    $dir = extract_tgz($filename) . q{/} . $dir;
  } else {
    $dir = 'ruby-git';
    $dir = fetch_git( 'https://github.com/ruby/ruby', $dir );

    chdir $dir;
    log_cmd 'autoconf';
  }

  configure_dir( $dir, "$configure" );

  build_with( 'make', $dir, 'install' );

  return;
}

sub install_rbx {
  if ($install_yaml) {
    if ( defined($LDFLAGS) ) {
      $LDFLAGS = "$LDFLAGS -L$install_prefix/lib";
    }

    if ( defined($CPPFLAGS) ) {
      $CPPFLAGS = "$CPPFLAGS -L$install_prefix/include";
    }

    install_yaml();
    tmp_cleanup();
  }

  chdir $cache_dir;

  my $dirname = 'rbx-git';
  my $fulldir = "$cache_dir\/$dirname";
  my $configure =
"--prefix=$install_prefix --default-version=19 --with-include-dir=$install_prefix/include --with-lib-dir=$install_prefix/lib";

  my $dir = fetch_git( 'https://github.com/rubinius/rubinius', $dirname );
  my $prebuilt_dir = "$fulldir\/vendor\/prebuilt";

  if ( -d $prebuilt_dir ) {
    say 'Copying cache prebuilt llvm files to the temporary git clone.';
    chdir "$fulldir\/vendor";
    log_cmd "find ./prebuilt -print -depth | cpio -pdmv $dir\/vendor";
  }

  chdir $dir;

  configure_dir( $dir, $configure );
  build_with( 'rake', $dir, 'install' );

  # Be kind bandwidth wise, copy whatevers in the temp prebuilt dir
  # back to the cache prebuilt dir for later use.
  $prebuilt_dir = "$dir\/vendor\/prebuilt";
  if ( -d $prebuilt_dir ) {
    say 'Copying temporary prebuilt llvm files back to caches.';
    chdir "$dir\/vendor";
    log_cmd "find ./prebuilt -print -depth | cpio -pdmv $fulldir\/vendor";
  }
  return;
}

sub install_jruby {
  my $dir = q{};

  if ( $lang_version ne 'head' ) {
    my $url =
"http://jruby.org.s3.amazonaws.com/downloads/$lang_version/jruby-bin-$lang_version.tar.gz";
    my $file = url_filename($url);
    $dir = $file;
    $dir =~ s/[.]tar[.]gz//sm;
    $dir =~ s/bin[-]//sm;

    my $extract_dir = $dir;
    $extract_dir =~ s/[-]bin//sm;
    my $filename = "$cache_dir/$file";
    fetch_url($url);
    $dir = extract_tgz($filename);

    log_cmd "mv $extract_dir $install_prefix";
  } else {
    $dir = 'jruby-git';
    $dir = fetch_git( 'https://github.com/jruby/jruby', $dir );
    build_with( 'ant', $dir, 'dist' );
    chdir "$dir\/dist";

    my $distfile      = defined(glob('jruby-bin*tar.gz')) or die "No distfile found\n";
    my $distfile_full = "$dir/dist/" . $distfile;

    if ( -f $distfile ) {
      $dir = extract_tgz($distfile_full);
      my $extract_dir = $distfile;
      $extract_dir =~ s/[.]tar[.]gz//sm;
      $extract_dir =~ s/[-]bin//sm;

      log_cmd "mv $extract_dir $install_prefix";
    } else {
      say 'Jruby build failed for some reason or another.';
    }
  }
  jruby_finalize($install_prefix);
  return;
}

sub jruby_finalize {
  my $dir = shift;

  say 'Removing windows specific files.';

  my $cmd =
    "rm -f $dir/bin/*.exe $dir/bin/*.dll $dir/bin/*.bat $dir/bin/jruby.sh";

  log_cmd $cmd;
  my $ruby_link = "$dir\/bin/ruby";
  chdir "$dir\/bin";
  log_cmd 'ln -s jruby ruby' unless ( -f $ruby_link );

  return;
}

sub perl_finalize {
  my $perl_install = shift;
  my $perl_bin     = "$perl_install\/bin/perl";

  if ( -f $perl_bin ) {
    say $perl_bin;
    unless ($perl_install_cpanm) {
      say "Setting up cpanm for $perl_install";
      my $cpanm_install_cmd =
        "curl --silent --location http://cpanmin.us | $perl_bin - App::cpanminus";
      log_cmd $cpanm_install_cmd;
    }
  }
}

sub install_perl {
  my $dirname = q{};
  my $configure =
"sh Configure -ds -e -Dprefix=$install_prefix -Dvendorprefix=$install_prefix -D optimize='-Os -Wall -g -pipe' -U use5005threads -D usethreads -D usemultiplicity -D uselargefiles -D use64bitint -D useshrplib";

  if ( $^O eq 'linux' ) {
    $configure = $configure . ' -Dnoextensions=ODBM_File';
  }

  if ( $lang_version ne 'head' ) {
    my $url  = perlurl($lang_version);
    my $file = url_filename($url);
    $dirname = $file;
    $dirname =~ s/[.]tar[.]gz//sm;
    my $filename = "$cache_dir/$file";
    fetch_url($url);
    my $dir = extract_tgz($filename) . q{/} . $dirname;

    chdir $dir;
    log_cmd $configure;

    if ($perl_run_tests) {
      build_with( 'make', $dir, 'test', 'install' );
    } else {
      build_with( 'make', $dir, 'install' );
    }
  }

  perl_finalize($install_prefix);
  return;
}

sub tmp_cleanup {
  chdir q{/};
  File::Temp::cleanup();
}

my %install_switch = (
                       'ruby'    => sub { install_ruby(); },
                       'rbx'     => sub { install_rbx(); },
                       'jruby'   => sub { install_jruby(); },
                       'perl'    => sub { install_perl(); },
                       'default' => sub { die "bug!\n"; },
                     );

if ( sanity_check() ) {
  say 'Cannot continue without a sane installation of above junk.';
} else {
  $install_switch{$lang_vm}();
}

local $SIG{'INT'} = sub { tmp_cleanup(); };

END { tmp_cleanup(); }
