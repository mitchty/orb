#!/bin/sh
#-*-mode: Shell-script; coding: utf-8;-*-
orb_base=${orb_base:=$HOME/.orb}
orb_ruby_base=${orb_ruby_base:=$orb_base/rubies}
orb_perl_base=${orb_perl_base:=$orb_base/perls}
orb_python_base=${orb_python_base:=$orb_base/pythons}

ORB_VERBOSE=${ORB_VERBOSE:=N}

function orb_ls_path {
  echo $PATH | sed -e 's/\:/ /g' | fmt -1
}

function orb_to_path {
  cat /dev/stdin | awk '!a[$0]++' | tr -s '\n' ':' | sed -e 's/\:$//'
}

function orb_shift_path {
  [[ -d "$1" ]] && echo $1
  orb_ls_path
}

function orb_rm_path {
  tmp=$(orb_ls_path | grep -v $1 | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

function orb_add_path {
  tmp=$(orb_shift_path "$1" | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

function orb_implode {
  orb_implode_ruby
  orb_implode_perl
  orb_implode_python
  orb_implode_all
}

# unset everything we've done
function orb_implode_all {
  unset orb_ls_path
  unset orb_to_path
  unset orb_shift_path
  unset orb_rm_path
  unset orb_add_path
  unset orb_add_bin
  unset orb_use_ruby
  unset orb_use_perl
  unset orb_use_python
  unset orb_echo
  unset orb_pick
  unset orb_implode_ruby
  unset orb_implode_perl
  unset orb_implode_python
  unset orb
  unset opl
  unset opy
  unset orb_implode
  unset ORB_VERBOSE
  unset orb_base
  unset orb_ruby_base
  unset orb_perl_base
  unset orb_python_base
  unset orb_implode_all
}

function orb_implode_ruby {
  orb_rm_path $orb_ruby_base
}

function orb_implode_perl {
  orb_rm_path $orb_perl_base
}

function orb_implode_python {
  orb_rm_path $orb_python_base
}

function orb_add_bin {
  has_bin="$1/bin"
  if [[ -d $has_bin ]]; then
    orb_add_path $has_bin
  else
    orb_echo "$has_bin not found!"
    return 1
  fi
}

function orb_use_ruby {
  orb_implode_ruby
  orb_add_bin "$orb_ruby_base/$1"
}

function orb_use_perl {
  orb_implode_perl
  orb_add_bin "$orb_perl_base/$1"
}

function orb_use_python {
  orb_implode_python
  orb_add_bin "$orb_python_base/$1"
}

function orb_echo {
  [[ ${ORB_VERBOSE} != 'N' ]] && echo $*
}

function orb_pick {
  lang=$1
  tmp=$PS3
  PS3="$lang?: "
  base="orb_${lang}_base"
  cd_dir=$(eval "echo \$$base")
  select option in $(cd $cd_dir && echo "system " * | fmt -1 | grep -v '^\.' | fmt -1000); do
    if [[ -n $option ]]; then
      PS3=$tmp
      # workaround for osx zsh select
      echo $option | grep 'system' > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        orb_echo "Removing $cd_dir from \$PATH"
        eval "orb_implode_${lang}"
        break
      fi
      orb_echo "Adding ${cd_dir}/$option/bin to \$PATH"
      eval "orb_use_${lang} $option"
      break
    else
      echo "Invalid selection $option"
    fi
  done
}

function orb {
  orb_pick 'ruby'
}

function opl {
  orb_pick 'perl'
}

function opy {
  orb_pick 'python'
}
