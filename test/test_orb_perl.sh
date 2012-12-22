#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_should_use_system_perl_by_default_if_present() {
  set +e
  if [[ -f "$(which perl)" ]]; then
    system_perl=$(which perl)
    . ./orb.sh
    opl use system
    orb_perl=$(which perl)
    assertEquals "${system_perl}" "${orb_perl}"
    orb_implode
  else
    echo "Warning: no system perl found."
    assertEquals 0 0
  fi
}

it_should_detect_perl_installs_to_orb_perl_base() {
  set +e
  orb_base=$(pwd)
  export orb_base
  . ./orb.sh
  mock_perl=$orb_perl_base/default/bin/perl
  mock_install "$orb_perl_base/default/perl"
  assertEquals "$(opl ls)" "system default"
  orb_implode
}

it_should_use_perl_installs_to_orb_perl_base() {
  set +e
  orb_base=$(pwd)
  . ./orb.sh
  mock_perl=$orb_perl_base/default/bin/perl
  mock_install $mock_perl
  opl use default
  assertEquals "${mock_perl}" "$(which perl)"
  orb_implode
}

it_should_not_use_directories_in_orb_base_with_no_perl_bin() {
  set +e
  orb_base=$(pwd)
  system_perl=$(which perl)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/zomg
  opl use default
  assertEquals "${system_perl}" "$(which perl)"
  orb_implode
}

it_should_not_use_nonexecutable_perl_in_orb_base() {
  set +e
  orb_base=$(pwd)
  system_perl=$(which perl)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/perl
  opl use default
  assertEquals "${system_perl}" "$(which perl)"
  orb_implode
}

. ./helper.sh
