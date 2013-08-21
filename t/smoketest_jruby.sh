#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_jruby() {
  set +e
  engine=jruby
  engine_version=${jruby_version}
  engine_name=${engine}-${engine_version}
  orb_base=$(pwd)
  export orb_base

  source ./orb.sh

  orb install --ruby=${engine} > /dev/null 2>&1
  orb use ${engine_name}

  sandbox_ruby=$orb_ruby_base/${engine_name}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\son.*//g;')

  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals "${engine} ${engine_version} ${jruby_verbose}" "$ruby_ver_string"
  assertEquals $(orb which) "${engine_name}"
}

. ./helper.sh

orb implode
