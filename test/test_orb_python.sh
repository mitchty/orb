#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_should_use_system_python_by_default_if_present() {
  set +e
  if [[ -f "$(which python)" ]]; then
    system_python=$(which python)
    . ./orb.sh
    orb_use_python system
    orb_python=$(which python)
    assertEquals "${system_python}" "${orb_python}"
    orb_implode
  else
    echo "Warning: no system python found."
    assertEquals 0 0
  fi
}

it_should_detect_python_installs_to_orb_python_base() {
  set +e
  orb_base=$(pwd)
  export orb_base
  . ./orb.sh
  mock_python=$orb_python_base/default/bin/python
  mock_install "$orb_python_base/default/python"
  assertEquals "$(opy ls)" "system default"
  orb_implode
}

it_should_use_python_installs_to_orb_python_base() {
  set +e
  orb_base=$(pwd)
  . ./orb.sh
  mock_python=$orb_python_base/default/bin/python
  mock_install $mock_python
  orb_use_python default
  assertEquals "${mock_python}" "$(which python)"
  orb_implode
}

it_should_not_use_directories_in_orb_base_with_no_python_bin() {
  set +e
  orb_base=$(pwd)
  system_python=$(which python)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/zomg
  orb_use_python default
  assertEquals "${system_python}" "$(which python)"
  orb_implode
}

it_should_not_use_nonexecutable_python_in_orb_base() {
  set +e
  orb_base=$(pwd)
  system_python=$(which python)
  . ./orb.sh
  mkdir -p $orb_base/default/bin
  touch $orb_base/default/bin/python
  orb_use_python default
  assertEquals "${system_python}" "$(which python)"
  orb_implode
}

. ./helper.sh