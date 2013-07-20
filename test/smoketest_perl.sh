#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_perl() {
  set +e
  engine=perl
  engine_version=${perl_version}
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./perl-install --no-test --version=${engine_version} > /dev/null 2>&1
  opl use ${engine}-${engine_version}
  sandbox_perl=$orb_perl_base/${engine}-${engine_version}/bin/perl
  perl_ver_string=$(perl -v | perl -pe 's/\sbuilt\sfor\s.*//g;' | grep 'This is')
  set -e
  assertEquals "$sandbox_perl" "$(which perl)"
  assertEquals "${perl_verbose}" "$perl_ver_string"
}

. ./helper.sh

orb implode
