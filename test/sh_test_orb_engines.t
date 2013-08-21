#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="Test general orb engine setup"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
guard_orb

source ./orb.sh

test_set_prereq HAVEPERL
test_set_prereq HAVERUBY
test_set_prereq HAVEPYTHON

test_expect_success HAVEPERL 'system has perl' "which perl > /dev/null 2>&1"
test_expect_success HAVERUBY 'system has ruby' "which ruby > /dev/null 2>&1"
test_expect_success HAVEPYTHON 'system has python' "which python > /dev/null 2>&1"

# Test that we use the system engines by default correctly
test_have_prereq HAVERUBY && test_expect_success "orb uses system ruby if present" "
  orb use system
  test 'system' == $(orb which)
"

test_have_prereq HAVEPERL && test_expect_success "opl uses system perl if present" "
  opl use system
  test 'system' == $(opl which)
"

test_have_prereq HAVEPYTHON && test_expect_success "opy uses system python if present" "
  opy use system
  test 'system' == $(opy which)
"

test_have_prereq HAVERUBY && test_expect_success "orb detects installs to orb_ruby_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_ruby_base/default/bin/ruby
  set +x
  orb ls
  set -x
  test 'system default' == $(orb ls)
"

test_have_prereq HAVEPERL && test_expect_success "opl detects installs to orb_perl_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_perl_base/default/bin/perl

  test $(opl ls) == 'system default'
"

test_have_prereq HAVEPYTHON && test_expect_success "opy detects installs to orb_python_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_python_base/default/bin/python
  test $(opy ls) == 'system default'
"

test_have_prereq HAVERUBY && test_expect_success "orb detects installs to orb_ruby_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_ruby_base/default/bin/ruby
  orb use default
  test $(orb which) == 'default'
"

test_have_prereq HAVEPERL && test_expect_success "opl detects installs to orb_perl_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_perl_base/default/bin/perl
  opl use default
  test $(opl which) == 'default'
"

test_have_prereq HAVEPYTHON && test_expect_success "opy detects installs to orb_python_base" "
  orb_base=$(pwd)
  export orb_base
  source ./orb.sh
  mock_install $orb_python_base/default/bin/python
  opy use default
  test $(opy which) == 'default'
"

test_done

#it_should_detect_ruby_installs_to_orb_ruby_base() {
#  set +e
#  orb_base=$(pwd)
#  export orb_base
#  . ./orb.sh
#  mock_ruby=$orb_ruby_base/default/bin/ruby
#  mock_install "$orb_ruby_base/default/ruby"
#  assertEquals "$(orb ls)" "system default"
#  assertEquals "system" $(orb which)
#  orb implode
#}

#it_should_use_ruby_installs_to_orb_ruby_base() {
#  set +e
#  orb_base=$(pwd)
#  . ./orb.sh
#  mock_ruby=$orb_ruby_base/default/bin/ruby
#  mock_install $mock_ruby
#  orb use default
#  assertEquals "${mock_ruby}" "$(which ruby)"
#  assertEquals "default" $(orb which)
#  orb implode
#}

#it_should_not_use_directories_in_orb_base_with_no_ruby_bin() {
#  set +e
#  orb_base=$(pwd)
#  system_ruby=$(which ruby)
#  . ./orb.sh
#  mkdir -p $orb_base/default/bin
#  touch $orb_base/default/bin/zomg
#  orb use default
#  assertEquals "${system_ruby}" "$(which ruby)"
#  assertEquals "system" $(orb which)
#  orb implode
#}

#it_should_not_use_nonexecutable_ruby_in_orb_base() {
#  set +e
#  orb_base=$(pwd)
#  system_ruby=$(which ruby)
#  . ./orb.sh
#  mkdir -p $orb_base/default/bin
#  touch $orb_base/default/bin/ruby
#  orb use default
#  assertEquals "${system_ruby}" "$(which ruby)"
#  assertEquals "system" $(orb which)
#  orb implode
#}
