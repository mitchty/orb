#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_installs_latest_jruby() {
  set +e
  engine=jruby
  engine_version=1.7.1
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install --ruby=${engine} --version=${engine_version} > /dev/null 2>&1
  orb_use_ruby ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\son.*//g;')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'jruby 1.7.1 (1.9.3p327) 2012-12-03 30a153b' "$ruby_ver_string"
}

. ./helper.sh

orb_implode
