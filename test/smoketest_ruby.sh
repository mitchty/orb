#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_installs_latest_ruby() {
  set +e
  engine=ruby
  engine_version=1.9.3-p362
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install > /dev/null 2>&1
  orb_use_ruby ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\s\[.*$//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'ruby 1.9.3p362 (2012-12-25 revision 38607)' "$ruby_ver_string"
}

. ./helper.sh

orb_implode
