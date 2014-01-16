#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="Test sandboxed perl install"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
guard_orb

test_expect_success "opl env doesn't exist" "
  test $(set | egrep -c -a '^(orb|ORB|opy|opl)_') -eq 0
"

test_set_prereq HAVEPERL

test_expect_success HAVEPERL 'system has perl' "which perl > /dev/null 2>&1"

orb_base=$(pwd)
export orb_base

[[ -d ${HOME}/.orb/cache ]] && rsync -az ${HOME}/.orb/cache/ ${orb_base}/cache

source ./orb.sh
eval $(./versions.sh)

test_expect_success "opl install succeeds" "
  opl install --no-test > /dev/null 2>&1
"

test_expect_success "opl ls shows only system and perl install" "
  test \"system perl-${perl_version}\" == \"$(opl ls)\"
"

opl use perl-$perl_version

test_expect_success "opl which returns the installed perl" "
  test \"perl-${perl_version}\" == $(opl which)
"

test_expect_success "which perl returns the full path to the sandboxed perl install" "
  test $orb_perl_base/perl-${perl_version}/bin/perl == $(which perl)
"

opl rm perl-$perl_version

test_expect_success "opl rm removes the perl install" "
  test \"system\" == \"$(opl ls)\"
"

test_done
