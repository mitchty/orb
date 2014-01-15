#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

# Have a way to skip network tests.
if [[ ! -z $NETWORK  && $NETWORK != '' ]]; then
  echo "Skipping network version test."
  exit 0
fi

test_description="Ensure we can parse stupid html to learn of new crap"

cd ${dir}
. ${dir}/sharness_helper.sh
. ${dir}/sharness.sh

setup_sandbox
test_expect_success "compare latest interwebz versions to saved versions" "
  test \"$(./web-versions)\" = \"$(cat versions)\"
"

test_done
