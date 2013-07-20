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
# fight in a boxing match with both arms chopped off. Just a flesh wound.

# ls_path treats PATH as if it were a newline delimited file
#
# Its more "shelly" (jelly? whatever) to just use sed/awk/tr/fmt on things.
orb_ls_path()
{
  echo $PATH | sed -e 's/\:/ /g' | fmt -1
}

# (ab)use awk to take whatever path (^ls_path output really) and convert
# to a : delimited string.
#
# Note one side effect of that hokey awk-ism there, is that duplicate
# lines are ignored, first one wins always. So this isn't perfect, but
# it is deliberate. This is exactly how the shell would treat things.
#
# Though it is questionable/arguable I shouldn't be doing the deduplication
# at all. Maybe I'll change it, honestly I don't care about removing duplicate
# paths that much.
orb_to_path()
{
  cat /dev/stdin | awk '!a[$0]++' | tr -s '\n' ':' | sed -e 's/\:$//'
}

# shift a path directory onto the path "stack" if you will.
# nop if not a directory
orb_shift_path()
{
  [[ -d "$1" ]] && echo $1; orb_ls_path
}

# Remove a path line from the path "stack"
orb_rm_path()
{
  tmp=$(orb_ls_path | grep -v $1 | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

# Update add to $PATH, maybe call rehash when in zsh here?
orb_add_path()
{
  tmp=$(orb_shift_path "$1" | orb_to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

# Cleanup after ourselves for whatever reason, remove ruby/perl/python
# then cleanup env/variables.
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

# nuke ruby paths
orb_implode_ruby()
{
  orb_rm_path $orb_ruby_base
}

# ditto perl
orb_implode_perl()
{
  orb_rm_path $orb_perl_base
}

# ditto python
orb_implode_python()
{
  orb_rm_path $orb_python_base
}

# For being lazy, add the /bin dir for a prefix if it exists for $lang
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

# Remove an orb/opl/opy managed install.
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

# Nuke any orb/opl/opy $lang directory from $PATH
# then add in the requested named $lang intepreter
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

# lazy wrapper for using a ruby interpreter
orb_use_ruby()
{
  orb_use_internal 'ruby' $1
}

# ditto perl
orb_use_perl()
{
  orb_use_internal 'perl' $1
}

# ditto python
orb_use_python()
{
  orb_use_internal 'python' $1
}

# Be verbose when $ORB_VERBOSE is set, otherwise ne'er a squeek
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

# similar to ls, which tells us which interpreter we're using, if not at all
# returns system
#
# if there isn't ANY intepreter, returns 1
orb_which()
{
  lang=$1
  dir=$(which $lang)
  if [[ $? == 1 ]]; then
    return 1;
  fi

  lang_base=$(eval "orb_${lang}_basedir")
  # meh, this is lame but it'll do for now.
  echo $dir | grep $lang_base > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo $(echo $dir | sed -e "s|$lang_base/||g" -e "s|/bin/$lang||g")
  else
    echo 'system'
  fi
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
    if [[ $param == 'do' || $param == 'ls' || $param == 'rm' ||\
          $param == 'use' || $param == 'implode' || $param == 'which' ]]; then
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
  elif [[ $action == 'implode' ]]; then
    orb_implode
  elif [[ $action == 'which' ]]; then
    orb_which $lang
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
