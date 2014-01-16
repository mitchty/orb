#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="Test sandboxed python install"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
guard_orb

test_expect_success "opy env doesn't exist" "
  test $(set | egrep -c -a '^(orb|ORB|opy|opl)_') -eq 0
"

test_set_prereq HAVEPYTHON

test_expect_success HAVEPYTHON 'system has python' "which python > /dev/null 2>&1"

orb_base=$(pwd)
export orb_base

[[ -d ${HOME}/.orb/cache ]] && rsync -az ${HOME}/.orb/cache/ $(pwd)/cache

source ./orb.sh
eval $(./versions.sh)

test_expect_success "opy install succeeds" "
  opy install > /dev/null 2>&1
"

test_expect_success "opy ls shows only system and python install" "
  test \"system python-${python_version}\" == \"$(opy ls)\"
"

opy use python-$python_version

test_expect_success "opy which returns the installed python" "
  test \"python-${python_version}\" == $(opy which)
"

test_expect_success "which python returns the full path to the sandboxed python install" "
  test $orb_python_base/python-${python_version}/bin/python == $(which python)
"

opy rm python-$python_version

test_expect_success "opy rm removes the python install" "
  test \"system\" == \"$(opy ls)\"
"

test_done
