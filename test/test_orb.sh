#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

# Try and make sure what we've written functions sanely.
it_passes_ksh_shell_checks_ok() {
  if [[ -f "$(which ksh > /dev/null 2>&1)" ]]; then
    ksh -n orb.sh
    assertEquals 0 $?
  fi
}

it_passes_ksh93_shell_checks_ok() {
  if [[ -f "$(which ksh93 > /dev/null 2>&1)" ]]; then
    ksh93 -n orb.sh
    assertEquals 0 $?
  fi
}

it_passes_bash_shell_checks_ok() {
  if [[ -f "$(which bash > /dev/null 2>&1)" ]]; then
    bash -n orb.sh
    assertEquals 0 $?
  fi
}

it_passes_zsh_shell_checks_ok() {
  if [[ -f "$(which zsh > /dev/null 2>&1)" ]]; then
    zsh -n orb.sh
    assertEquals 0 $?
  fi
}

it_sources_ok() {
  source ./orb.sh
}

it_removes_itself_ok() {
  orb implode
}

it_really_leaves_no_variables_behind() {
  source ./orb.sh
  orb implode
  var_count=$(set | egrep -a "^(orb|ORB)_" | wc -l)
  assertEquals 0 $var_count
}

it_really_leaves_no_functions_behind() {
  source ./orb.sh
  orb implode
  func_count=$(typeset -f | egrep "^orb_" | wc -l)
  assertEquals 0 $func_count
}

it_modifies_path_properly() {
  set +e
  path_prior=$PATH
  if [[ -f "$(which ruby)" ]]; then
    system_ruby=$(which ruby)
    orb_base=$(pwd)
    export orb_base
    . ./orb.sh
    mock_ruby=$orb_ruby_base/default/bin/ruby
    mock_install "$orb_ruby_base/default/ruby"
    orb use default
    orb use system
    orb_ruby=$(which ruby)
    assertEquals $path_prior $PATH
    assertEquals $system_ruby $orb_ruby
    orb implode
  else
    echo "Warning: no system ruby found."
    assertEquals 0 0
  fi
}

. ./helper.sh
