function ls_path {
  for x in $(echo $PATH | sed -e 's/\:/ /g'); do
    [[ -d "$x" ]] && echo $x
  done
}

# Could probably do this all in one awk, but I was lazy.
# note the awk function strips out duplicate entries based on first
# appearance. Which is exactly what the shell does too so meh.
# Not going to "optimize" this as it runs all of maybe 10 times a day.
function to_path {
  cat /dev/stdin | awk '!a[$0]++' | tr -s '\n' ':' | sed -e 's/\:$//'
}

function shift_path {
  [[ -d "$1" ]] && echo $1
  ls_path
}

function rm_path {
  tmp=$(ls_path | grep -v $1 | to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

function add_path {
  tmp=$(shift_path "$1" | to_path)
  eval "PATH=$tmp"
  eval "export PATH"
}

function pickruby {
  tmp=$PS3
  PS3='ruby?: '
  select aruby in $(cd $HOME/.rubies && echo "system" && echo *)
  do
    if [[ -n $aruby ]]; then
      PS3=$tmp
      # zsh select on osx is acting pissy, this gets around it
      echo $aruby | grep 'system' > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo "Removing $HOME/.rubies from PATH"
        rm_path "$HOME/.rubies"
        break
      fi
      rm_path "$HOME/.rubies"
      echo "Adding $aruby to PATH"
      add_path "$HOME/.rubies/$aruby/bin"
      break
    else
      print "Invalid selection $aruby"
    fi
  done
}