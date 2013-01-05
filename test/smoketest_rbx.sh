#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export $copy_cache

it_installs_latest_rbx() {
  set +e
  engine=rbx
  engine_version=head
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install --ruby=${engine} --version=${engine_version} > /dev/null 2>&1
  orb use ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\s\(.*$//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'rubinius 2.0.0.rc1' "$ruby_ver_string"
}

. ./helper.sh

orb_implode
