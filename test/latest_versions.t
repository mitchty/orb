#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

test_description="Ensure we can parse stupid html to learn of new crap"

. ./sharness_helper.sh
. ./sharness.sh

setup_sandbox
test_expect_success "compare latest interwebz versions to saved versions" "
  test \"$(./web-versions)\" = \"$(cat versions)\"
"

test_done
