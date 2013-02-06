#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-

./test_all.sh

for smoke in $(ls -d smoketest_head_*.sh); do
  (./$smoke)
done
