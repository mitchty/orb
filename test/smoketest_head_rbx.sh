#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

# So until rbx is back on a release cycle, just build head here
# and define what we expect in the test.
it_installs_head_rbx() {
  set +e
  engine=rbx
  engine_version=head
  engine_name=${engine}-${engine_version}
  orb_base=$(pwd)
  export orb_base

  source ./orb.sh

  orb install --ruby=${engine} --version=${engine_version} > /dev/null 2>&1
  orb use ${engine_name}

  sandbox_ruby=$orb_ruby_base/${engine_name}/bin/ruby
  ruby_ver_string=$(ruby -v | perl -pe 's/\s\(.*$//g')

  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals "rubinius 2.0.0.n202" "$ruby_ver_string"
  assertEquals $(orb which) "${engine_name}"
}

. ./helper.sh

orb implode
