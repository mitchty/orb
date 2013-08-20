#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="descriptions are good"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
test_expect_success "tests are better" "
  test 0 -eq 0
"

test_done
