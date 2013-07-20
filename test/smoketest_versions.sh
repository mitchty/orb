#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

it_validates_latest_versions_equal_saved() {
  web=$(./web-versions)
  expected=$(cat versions)
  assertEquals "$expected" "$web"
}

. ./helper.sh
