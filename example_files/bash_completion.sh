#!bash

_main() {
  _e "starting completion"

  local i=1 cmd

  # find the subcommand
  while [[ "$i" -lt "$COMP_CWORD" ]]
  do
    local s="${COMP_WORDS[i]}"
    case "$s" in
      --*)
        cmd="$s"
        break
        ;;
      -*)
        ;;
      *)
        cmd="$s"
        break
        ;;
    esac
    (( i++ ))
  done

  if [[ "$i" -eq "$COMP_CWORD" ]]
  then
    COMPREPLY=($(compgen -W "subcommand" -- "$cur"))
    return # return early if we're still completing the 'current' command
  fi

  # we've completed the 'current' command and now need to call the next completion function
  # subcommands have their own completion functions
  case "$cmd" in
    subcommand) _main_subcommand ;;
    *)          ;;
  esac
}

_e () { 
  echo "$1" >> log 
}

_main_subcommand ()
{
  _e "main subcommand"
  local i=1 cmd

  # find the subcommand
  while [[ $i -lt $COMP_CWORD ]]; do
    local s="${COMP_WORDS[i]}"
    case "$s" in
    --*)
      cmd="$s"
      break
      ;;
    -*) 
      ;;
    subcommand)
      # do nothing because it's still the current command?  
      ;;
    *)
      cmd="$s"
      break
      ;;
    esac
    (( i++ ))
  done

  if [[ $i -eq $COMP_CWORD ]]; then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _e "current completion candidate $cur"
    COMPREPLY=($(compgen -W "create doctor fetch info install list --version" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    fetch)                  _main_subcommand_fetch ;;
      *)                      ;;
  esac
}

_main_subcommand_fetch ()
{
  _e "main subcommand"
  local i=1 cmd

  # find the subcommand
  _e "comp cword $COMP_CWORD"
  while [[ $i -lt $COMP_CWORD ]]; do
    local s="${COMP_WORDS[i]}"
    case "$s" in
    --*)
      _e "--"
      cmd="$s"
      break
      ;;
    -*) 
      _e "-"
      ;;
    subcommand|fetch)
      _e "fetchdddddd"
      # do nothing because it's still the current command?  
      ;;
    *)
      _e "star, which means we skipped counting.... "
      cmd="$s"
      break
      ;;
    esac
    (( i++ ))
  done

  if [[ $i -eq $COMP_CWORD ]]; then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _e "current completion candidate $cur"
    COMPREPLY=($(compgen -W "fetch_sub" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    fetch_sub) ;;
      *)       ;;
  esac
}

__brew_caskcomp_words_include ()
{
    local i=1
    while [[ $i -lt $COMP_CWORD ]]; do
      _e "COMP_WORDS[i] ${COMP_WORDS[i]} || $1"
        if [[ "${COMP_WORDS[i]}" = "$1" ]]; then
            return 0
        fi
        (( i++ ))
    done
    return 1
}

# Find the previous non-switch word
__brew_caskcomp_prev ()
{
  local idx=$((COMP_CWORD - 1))
  local prv="${COMP_WORDS[idx]}"
  while [[ $prv == -* ]]; do
      _e "i should not enter here with regular testing"
      (( idx-- ))
      prv="${COMP_WORDS[idx]}"
  done
  echo "$prv"
}

__brew_caskcomp ()
{
    # break $1 on space, tab, and newline characters,
    # and turn it into a newline separated list of words
    local list s sep=$'\n' IFS=$' \t\n'
    local cur="${COMP_WORDS[COMP_CWORD]}"

    for s in $1; do
        _e "here s= $s   1= $1 "
        __brew_caskcomp_words_include "$s" && continue
        list="$list$s$sep"
        _e "current list $list"
    done

    IFS="$sep"
    COMPREPLY=($(compgen -W "$list" -- "$cur"))
}


complete -F _main main