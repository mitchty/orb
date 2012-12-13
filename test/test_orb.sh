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
  orb_implode
}

it_really_leaves_no_variables_behind() {
  source ./orb.sh
  orb_implode
  var_count=$(set | egrep -a "^(orb|ORB)_" | wc -l)
  assertEquals 0 $var_count
}

it_really_leaves_no_functions_behind() {
  source ./orb.sh
  orb_implode
  func_count=$(typeset -f | egrep "^orb_" | wc -l)
  assertEquals 0 $func_count
}

. ./helper.sh
