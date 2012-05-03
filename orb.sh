#!/bin/sh
#-*-mode: Shell-script; coding: utf-8;-*-
orb_ruby_base=${orb_ruby_base:=$HOME/.rubies}

function orb_ls_path {
  for x in $(echo $PATH | sed -e 's/\:/ /g'); do
    [[ -d "$x" ]] && echo $x
  done
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

function orbimplode {
  rm_path $orb_ruby_base
}

function orb_use_ruby {
  orbimplode
  new="$orb_ruby_base/$1/bin"
  [[ -d $new ]] && add_path $new
}

function orb {
  tmp=$PS3
  PS3='ruby?: '
  select aruby in $(cd $orb_ruby_base && echo "system" && echo *)
  do
    if [[ -n $aruby ]]; then
      PS3=$tmp
      # zsh select on osx is acting pissy, this gets around it
      echo $aruby | grep 'system' > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo "Removing $ruby_base from \$PATH"
        orbimplode
        break
      fi
      echo "Adding $aruby to \$PATH"
      orb_use_ruby $aruby
      break
    else
      echo "Invalid selection $aruby"
    fi
  done
}