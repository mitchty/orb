#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_should_use_system_ruby_by_default_if_present() {
  set +e
  if [[ -f "$(which ruby)" ]]; then
    system_ruby=$(which ruby)
    . ./orb.sh
    orb use system
    orb_ruby=$(which ruby)
    assertEquals "${system_ruby}" "${orb_ruby}"
    assertEquals "system" $(orb which)
    orb implode
  else
    echo "Warning: no system ruby found."
    assertEquals 0 0
  fi
}

it_should_detect_ruby_installs_to_orb_ruby_base() {
  set +e
  orb_base=$(pwd)
  export orb_base
  . ./orb.sh
  mock_ruby=$orb_ruby_base/default/bin/ruby
  mock_install "$orb_ruby_base/default/ruby"
  assertEquals "$(orb ls)" "system default"
  assertEquals "system" $(orb which)
  orb implode
}

it_should_use_ruby_installs_to_orb_ruby_base() {
  set +e
  orb_base=$(pwd)
  . ./orb.sh
  mock_ruby=$orb_ruby_base/default/bin/ruby
  mock_install $mock_ruby
  orb use default
  assertEquals "${mock_ruby}" "$(which ruby)"
  assertEquals "default" $(orb which)
  orb implode
}

it_should_not_use_directories_in_orb_base_with_no_ruby_bin() {
  set +e
  orb_base=$(pwd)
  system_ruby=$(which ruby)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/zomg
  orb use default
  assertEquals "${system_ruby}" "$(which ruby)"
  assertEquals "system" $(orb which)
  orb implode
}

it_should_not_use_nonexecutable_ruby_in_orb_base() {
  set +e
  orb_base=$(pwd)
  system_ruby=$(which ruby)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/ruby
  orb use default
  assertEquals "${system_ruby}" "$(which ruby)"
  assertEquals "system" $(orb which)
  orb implode
}

. ./helper.sh
