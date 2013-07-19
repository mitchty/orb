#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
set -e

setUp() {
  if [[ $(pwd) == *sandbox ]]; then
    cd ..
  fi
  if [ -e sandbox ]; then
    rm -fr sandbox
  fi
  mkdir sandbox
  cd sandbox
  # copy .orb/cache if it exists and we're running under the sandbox tests
  user_orb_cache=${HOME}/.orb/cache
  [[ -d $user_orb_cache && "$copy_cache" == 'y' ]] && cp -R $user_orb_cache cache
  cp ../../*.sh .
  cp ../../*.pl .
  cp ../../*-install .
  cp ../*.rb .
  cp ../versions .
  cp ../versions.sh .
  eval $($(pwd)/versions.sh)
}

suite() {
  for test_name in $(grep '^it_' $0 | cut -d '(' -f 1); do
    suite_addTest $test_name
  done
}

mock_install() {
  input=$1
  file=$(basename "$input")
  dirs=$(dirname "$input")
  mkdir -p $dirs
  cat <<EOF > $dirs/$file
#!/bin/sh
echo $file
exit 0
EOF
  chmod 755 $dirs/$file
}

. shunit2/src/shunit2
