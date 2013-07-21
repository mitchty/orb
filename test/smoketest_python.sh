#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
echo "Running $(basename $0)"

copy_cache=y
export copy_cache

it_installs_latest_python() {
  set +e
  engine=python
  engine_version=${python_version}
  engine_name=${engine}-${engine_version}
  orb_base=$(pwd)
  export orb_base

  source ./orb.sh

  opy install --version=${engine_version} > /dev/null 2>&1
  opy use ${engine_name}

  sandbox_python=$orb_python_base/${engine_name}/bin/python
  python_ver_string=$(python -V 2>&1) # printing on stderr, really? wtf python

  set -e
  assertEquals "$sandbox_python" "$(which python)"
  assertEquals "${python_verbose}" "$python_ver_string"
  assertEquals $(opy which) "${engine_name}"
}

. ./helper.sh

orb implode
