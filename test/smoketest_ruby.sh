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
  ruby_ver_string=$(ruby -v | sed -e 's/\son.*//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'jruby 1.7.1 (1.9.3p327) 2012-12-03 30a153b' "$ruby_ver_string"
}

it_installs_latest_ruby() {
  set +e
  engine=ruby
  engine_version=1.9.3-p327
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install > /dev/null 2>&1
  orb_use_ruby ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | sed -e 's/\s\[.*//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'ruby 1.9.3p327 (2012-11-10 revision 37606)' "$ruby_ver_string"
}

it_installs_latest_rbx() {
  set +e
  engine=rbx
  engine_version=head
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  ./ruby-install --ruby=${engine} --version=${engine_version} > /dev/null 2>&1
  orb_use_ruby ${engine}-${engine_version}
  sandbox_ruby=$orb_ruby_base/${engine}-${engine_version}/bin/ruby
  ruby_ver_string=$(ruby -v | sed -e 's/1.9.3.*//g' -e 's/\s.$//g')
  set -e
  assertEquals "$sandbox_ruby" "$(which ruby)"
  assertEquals 'rubinius 2.0.0rc1' "$ruby_ver_string"
}

. ./helper.sh

orb_implode
