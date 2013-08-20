#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

# TODO: figure out a way to test bash/zsh/ksh93ish at once...
# probably outside the scope of this test though.
test_description="Ensure orb works sanely..ish"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox

# TODO: I'm really thinking of moving the lot of the shell into perl proper
# after adding these tests...
test_expect_success "$SHELL -n orb.sh is fine with things" "
   $SHELL -n orb.sh
"

test_expect_success "orb.sh sources with $SHELL" "
  source ./orb.sh
"

test_expect_success "orb cleans up after itself like a good little doggy" "
  orb implode
"

test_expect_success "orb leaves no man, err variables behind after cleanup" "
  source ./orb.sh
  orb implode
  test $(set | egrep -c -a '^(orb|ORB)_') -eq 0
"

test_expect_success "orb leaves no functions behind either after cleanup" "
  source ./orb.sh
  orb implode
  test $(typeset -f | egrep -c '^orb_') -eq 0
"

# this test smells...
test_expect_success "orb munges PATH correctly" "
  set +e
  path_prior=$PATH
  if [[ -f \"$(which ruby)\" ]]; then
    system_ruby=$(which ruby)
    orb_base=$(pwd)
    export orb_base
    . ./orb.sh
    mock_ruby=$orb_ruby_base/default/bin/ruby
    mock_install $orb_ruby_base/default/ruby
    orb use default
    orb use system
    orb_ruby=$(which ruby)
    $path_prior == $PATH
    $system_ruby == $orb_ruby
    orb implode
  else
    echo Warning: no system ruby found.
    0 == 0
  fi
"

test_done
