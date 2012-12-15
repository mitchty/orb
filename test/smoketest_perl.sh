#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_installs_latest_perl() {
  set +e
  engine=perl
  engine_version=5.16.2
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./perl-install --no-test --version=${engine_version} > /dev/null 2>&1
  orb_use_perl ${engine}-${engine_version}
  sandbox_perl=$orb_perl_base/${engine}-${engine_version}/bin/perl
  perl_ver_string=$(perl -v | perl -pe 's/\sbuilt\sfor\s.*//g;')
  set -e
  basic_version_out=$(cat <<EOF

This is perl 5, version 16, subversion 2 (v5.16.2)

Copyright 1987-2012, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

EOF
)
  assertEquals "$sandbox_perl" "$(which perl)"
  assertEquals "$basic_version_out" "$perl_ver_string"
}

. ./helper.sh

orb_implode
