#-*-mode: Perl; coding: utf-8;-*-
package Orb::Install;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use POSIX qw(getcwd);
use LWP 5.64;

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw(&push_cwd &pop_cwd &get_url &get_url_content &latest_perl_from_web &latest_ruby_from_web &latest_jruby_from_web &latest_python_from_web &python_download_url)],
);

our @DIRSTACK = ();

sub push_cwd() { return push(@DIRSTACK, getcwd()); }
sub pop_cwd() { return pop(@DIRSTACK); }

our $DEFAULT_DL_METHOD = 'lwp';
our $download_method = $DEFAULT_DL_METHOD;

our $CACHE_DIR = '/tmp';

sub dl_method {
  my %dl_switch = (
    'lwp' => \&get_url_content_lwp,
    'curl' => \&get_url_content_curl,
  );
  return $dl_switch{$download_method}(shift);
}

sub get_url_content { dl_method(shift); }

sub get_url_content_curl {
  my $url = shift;
  my $content = qx/curl --silent -HIO $url/;
  my $rc = $? >> 8;
  return ($rc) ? $rc : $content;
}

sub get_url_content_lwp {
  my $url = shift;

  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;
  $ua->default_headers;
  $ua->agent('curl/7.24.0');
  my $response = $ua->get( $url);
  return ($response->is_success) ? $response->content : 1;
}

sub get_url {
  my $url = shift;
  my $save_filename = shift;
  my $save_to_dir = shift || $ORB::Install::CACHE_DIR;
  $save_filename = "$save_to_dir\/$save_filename";

  my $content = get_url_content($url);

  if ($content){
    open (my $fh, '>', $save_filename) or return 0;
    print $fh $content;
    close $fh;
    return $save_filename;
  }else{
    return 1;
  }
};

sub latest_perl_from_web {
  my $url = 'http://www.perl.org';
  my $page = get_url_content($url);
  my $perl_version = 'unknown';
  if ($page =~ m/Perl\s\K\d[.]\d+[.]\d+/){
    $perl_version = $&;
  }
  return $perl_version;
};

sub latest_ruby_from_web {
  my $url = 'http://www.ruby-lang.org/en/downloads/';
  my $page = get_url_content($url);
  my $ruby_version = 'unknown';
  if ($page =~ m/stable\sversion\sis\s\K\d+[.]\d+[.]\d+[-]p\d+/){
    $ruby_version = $&;
  }
  return $ruby_version;
};

sub latest_jruby_from_web {
  my $url = 'http://www.jruby.org';
  my $page = get_url_content($url);
  my $jruby_version = 'unknown';
  if ($page =~ m/JRuby\s\K\d[.]\d+[.]\d+/){
    $jruby_version = $&;
  }
  return $jruby_version;
};

# python is python3 new hotness, python2 is the old and busted
sub latest_python_from_web {
  my $url = 'http://python.org/download/';
  my $page = get_url_content($url);
  my $python_version = 'unknown';
  if ($page =~ m/Python\s\K3[.]\d+[.]\d+/){
    $python_version = $&;
  }
  return $python_version;
};

sub python_download_url {
  my $version = shift || latest_python_from_web();
  my $url = sprintf('http://python.org/ftp/python/%s/Python-%s.tgz', $version, $version);
  return $url;
};

1;
