#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-

for shtest in $(ls -d test_*.sh | grep -v all); do
  (./$shtest)
done
