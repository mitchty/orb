#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_ruby() {
  set +e
  engine=ruby
  engine_version=$ruby_version
  # ruby -v omits the -
  engine_version_short=$(echo $engine_version | sed -e 's/\-//g')
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install > /dev/null 2>&1
  orb use ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\s\[.*$//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals "${engine} ${engine_version_short} ${ruby_verbose}" "$ruby_ver_string"
}

. ./helper.sh

orb implode
