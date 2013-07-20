#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_jruby() {
  set +e
  engine=jruby
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install --ruby=${engine} > /dev/null 2>&1
  engine_version=${jruby_version}
  orb use ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\son.*//g;')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals "${engine} ${engine_version} ${jruby_verbose}" "$ruby_ver_string"
}

. ./helper.sh

orb_implode
