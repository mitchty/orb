#!/bin/sh
#-*-mode: Shell-script; coding: utf-8;-*-

# Default locations for things.
orb_base=${orb_base:=$HOME/.orb}
orb_cache=${orb_cache:=$orb_base/cache}
orb_logs=${orb_logs:=$orb_cache/logs}
orb_ruby_base=${orb_ruby_base:=$orb_base/rubies}
orb_perl_base=${orb_perl_base:=$orb_base/perls}
orb_python_base=${orb_python_base:=$orb_base/pythons}

ORB_VERBOSE=${ORB_VERBOSE:=N}

# NOTE: the K&R brace style is DELIBERATE
# ksh93 and below (well bash 3.whatever as well) think:
# function_name() {
# blah
# }
# is a syntax error. This is the reason shell programming is like trying to
# fight in a boxing match with both arms chopped off. Just a flesh wound.or
orb_ls_path()
{
  echo $PATH | sed -e 's/\:/ /g' | fmt -1
}

orb_to_path()
{
  cat /dev/stdin | awk '!a[$0]++' | tr -s '\n' ':' | sed -e 's/\:$//'
}

orb_shift_path()
{
  [[ -d "$1" ]] && echo $1; orb_ls_path
}

orb_rm_path()
{
  tmp=$(orb_ls_path | grep -v $1 | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

orb_add_path()
{
  tmp=$(orb_shift_path "$1" | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

orb_implode()
{
  orb_implode_ruby; orb_implode_perl; orb_implode_python
  unset orb; unset opl; unset opy
  for var in $(set | egrep -a "^(orb|ORB)_" | awk -F= '{print $1}'); do
    unset $var
  done
  for func in $(typeset -f | egrep '^orb_'| tr '(){' ' ' | awk -F= '{print $1}'); do
    unset -f $func
  done
}

orb_implode_ruby()
{
  orb_rm_path $orb_ruby_base
}

orb_implode_perl()
{
  orb_rm_path $orb_perl_base
}

orb_implode_python()
{
  orb_rm_path $orb_python_base
}

orb_add_bin()
{
  dir=$1; shift; lang=$1

  bin="$dir/bin/$lang"
  if [[ -f $bin ]]; then
    orb_add_path "$dir/bin"
    return 0
  else
    orb_echo "$bin not found!"
    return 1
  fi
}

orb_rm_vm()
{
  name=$1; shift; lang=$1
  echo $name | grep 'system' > /dev/null 2>&1
  if (( $? == 0 )); then
    echo "I can't remove the system ${lang} install, sorry"
    return
  fi
  dir=$(eval "orb_${lang}_basedir")
  bin="$dir/$name/bin/$lang"
  [[ -f $bin ]] && rm -fr "$dir/$name"
}

orb_use_internal()
{
  lang=$1; shift; name=$1
  echo $name | grep 'system' > /dev/null 2>&1
  if (( $? == 0 )); then
    eval "orb_implode_$lang"
  else
    eval "orb_implode_$lang"
    base=$(eval "orb_${lang}_basedir")
    orb_add_bin $base/$name $lang
  fi
}

orb_use_ruby()
{
  orb_use_internal 'ruby' $1
}

orb_use_perl()
{
  orb_use_internal 'perl' $1
}

orb_use_python()
{
  orb_use_internal 'python' $1
}

orb_echo()
{
  [[ ${ORB_VERBOSE} != 'N' ]] && echo $*
}

# conveniences for eval
orb_ruby_basedir()
{
  echo $orb_ruby_base
}

orb_perl_basedir()
{
  echo $orb_perl_base
}

orb_python_basedir()
{
  echo $orb_python_base
}

orb_ls_internal()
{
  lang=$1
  echo $(cd $(eval "orb_${lang}_basedir") &&
         echo "system" $(ls -d *) | fmt -1 | grep -v '^\.' | fmt -1000)
}

orb_pick()
{
  lang=$1
  tmp=$PS3
  PS3="$lang?: "
  base=$(eval eval echo "\$orb_${lang}_base")
  IFS=" "
  select option in $(orb_ls_internal $lang); do
    if [[ -n $option ]]; then
      orb_use_internal 'ruby' $option
      break
    else
      echo "Invalid selection $option"
    fi
  done
  PS3=$tmp
}

orb_pick_private()
{
  lang=$1; shift
  action=unknown
  do_index=0
  use_all=1

  for param in $*; do
    [[ $param == 'all' ]] && use_all=0
    if [[ $param == 'do' || $param == 'ls' || $param == 'rm' || $param == 'use' ]]; then
      action=$param; break
    fi
    (( do_index=do_index+1 ))
  done

  if [[ $action == 'do' ]]; then
    if [ $use_all -eq 0 ]; then
      shift; shift
      for a in $(orb_ls_internal $lang); do
        orb_use_internal $lang $a
        orb_echo $(which $lang)
        eval $*
      done
    else
      index=0
      typeset -a vm
      until [ $index -eq $do_index ]; do
        (( index=index+1 ))
        vm[$index]=$1
        shift
      done
      shift
      for a in ${vm[@]}; do
        orb_use_internal $lang $a
        orb_echo $(which $lang)
        eval $*
      done
    fi
  elif [[ $action == 'rm' ]]; then
    index=0
    until [ $index -eq $do_index ]; do
      (( index=index+1 )); shift
    done; shift
    for a in $*; do
      orb_rm_vm $a $lang
    done
  elif [[ $action == 'use' ]]; then
    index=0
    until [ $index -eq $do_index ]; do
      (( index=index+1 )); shift
    done; shift
    orb_use_internal $lang $*
  elif [[ $action == 'ls' ]]; then
    orb_ls_internal $lang
  else
    orb_pick $lang
  fi
}

orb()
{
  orb_pick_private 'ruby' $*
}

opl()
{
  orb_pick_private 'perl' $*
}

opy()
{
  orb_pick_private 'python' $*
}
