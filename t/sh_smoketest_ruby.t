#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="Test sandboxed jruby/ruby install"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
guard_orb

test_expect_success "orb env doesn't exist" "
  test $(set | egrep -c -a '^(orb|ORB|opl|opy)_') -eq 0
"

test_set_prereq HAVERUBY
test_set_prereq HAVEJAVA

test_expect_success HAVERUBY 'system has ruby' "which ruby > /dev/null 2>&1"
test_expect_success HAVEJAVA 'system has java' "which java > /dev/null 2>&1"

orb_base=$(pwd)
export orb_base

[[ -d ${HOME}/.orb/cache ]] && rsync -az ${HOME}/.orb/cache/ ${orb_base}/cache

source ./orb.sh
eval $(./versions.sh)

# Test that we use the system engines by default correctly
test_have_prereq HAVERUBY && test_expect_success "orb uses system ruby if present" "
  test 'system' == $(orb which)
"
test_have_prereq HAVEJAVA && test_expect_success "orb install --ruby=jruby succeeds" "
  orb install --ruby=jruby > /dev/null 2>&1
"

test_have_prereq HAVEJAVA && test_expect_success "orb ls shows only system and jruby install" "
  test \"system jruby-${jruby_version}\" == \"$(orb ls)\"
"

# sharness and subshells/function execs are... inconsistent and don't always behave
test_have_prereq HAVEJAVA && orb use jruby-$jruby_version

test_have_prereq HAVEJAVA && test_expect_success "orb which returns the installed jruby" "
  test \"jruby-${jruby_version}\" == $(orb which)
"

test_have_prereq HAVEJAVA && test_expect_success "which ruby returns the full path to the sandboxed jruby install" "
  test $orb_ruby_base/jruby-${jruby_version}/bin/ruby == $(which ruby)
"

test_have_prereq HAVEJAVA && orb rm jruby-$jruby_version

test_have_prereq HAVEJAVA && test_expect_success "orb rm removes the jruby install" "
  test \"system\" == \"$(orb ls)\"
"

# MRI
test_expect_success "orb install succeeds" "
  orb install > /dev/null 2>&1
"

test_expect_success "orb ls shows only system and ruby install" "
  test \"system ruby-${ruby_version}\" == \"$(orb ls)\"
"

orb use ruby-$ruby_version

test_expect_success "orb which returns the installed ruby" "
  test \"ruby-${ruby_version}\" == $(orb which)
"

test_expect_success "which ruby returns the full path to the sandboxed ruby install" "
  test $orb_ruby_base/ruby-${ruby_version}/bin/ruby == $(which ruby)
"

orb rm ruby-$ruby_version

test_expect_success "orb rm removes the ruby install" "
  test \"system\" == \"$(orb ls)\"
"

test_done
