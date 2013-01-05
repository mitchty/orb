#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-

./test_all.sh

copy_cache=y
export $copy_cache

for smoke in $(ls -d smoketest_*.sh | grep -v all); do
  (./$smoke)
done
