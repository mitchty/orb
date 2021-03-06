#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
time=$(perl -e 'print time() . "\n";')

setup_sandbox()
{
  user_orb_cache=${HOME}/.orb/cache
  if [[ -d $user_orb_cache && "$copy_cache" == 'y' ]]; then
    cp -R $user_orb_cache cache
  fi
  cp ../../*.sh .
  cp ../../*.pl .
  cp ../../*-install .
  cp ../../web-versions .
  cp -r ../../Orb .
  cp ../versions .
  cp ../versions.sh .
  eval $($(pwd)/versions.sh)
}

mock_install()
{
  input=$1
  file=$(basename "$input")
  dirs=$(dirname "$input")
  [[ ! -d ${dirs} ]] && mkdir -p $dirs
  cat <<EOF > $dirs/$file
#!/usr/bin/env sh
echo $file
exit 0
EOF
  chmod 755 $dirs/$file
}

guard_orb()
{
  # I want a good, clean, fight, I mean test run, whatever, just don't run
  # tests if we're in an already setup environment.
  if test $(set | egrep -c -a '^(orb|ORB)_') -ne 0 ; then
    say "Nooope, running in an environment with orb already setup, aborting"
    exit 1
  fi
}
