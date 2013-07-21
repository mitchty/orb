#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_perl() {
  set +e
  engine=perl
  engine_version=${perl_version}
  engine_name=${engine}-${engine_version}
  orb_base=$(pwd)
  export orb_base

  source ./orb.sh

  opl install --no-test --version=${engine_version} > /dev/null 2>&1
  opl use ${engine_name}

  sandbox_perl=$orb_perl_base/${engine_name}/bin/perl
  perl_ver_string=$(perl -v | perl -pe 's/\sbuilt\sfor\s.*//g;' | grep 'This is')

  set -e
  assertEquals "$sandbox_perl" "$(which perl)"
  assertEquals "${perl_verbose}" "$perl_ver_string"
  assertEquals $(opl which) "${engine_name}"
}

. ./helper.sh

orb implode
