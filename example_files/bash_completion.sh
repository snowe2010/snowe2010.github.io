#!bash

_main() {
  _e "starting completion"

  local i=1 cmd

  _e "i:$i cword=[$COMP_CWORD] comp_words=[${COMP_WORDS[*]}]"
  
  # find the subcommand
  while [[ "$i" -lt "$COMP_CWORD" ]]
  do
    local s="${COMP_WORDS[i]}"
    _e "s is $s"
    case "$s" in
      -*) ;;
      *)
        _e "else"
        cmd="$s"
        break
        ;;
    esac
    (( i++ ))
  done

  if [[ "$i" -eq "$COMP_CWORD" ]]
  then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _e "crrr $cur"
    COMPREPLY=($(compgen -W "plain subcommand subcommand2 --class-opt -h help" -- "$cur"))
    return # return early if we're still completing the 'current' command
  fi

  # we've completed the 'current' command and now need to call the next completion function
  # subcommands have their own completion functions
  case "$cmd" in
    plain) _main_plain ;;
    subcommand) _main_subcommand ;;
    subcommand2) _main_subcommand2 ;;
    *)          ;;
  esac
}

_e () { 
  echo "$1" >> log 
}

_main_plain ()
{  
  local cur="${COMP_WORDS[COMP_CWORD]}"
  case "$cur" in
    -*) 
      COMPREPLY=($(compgen -W "--opt1 --class-opt" -- "$cur"))
      return 
      ;;
  esac
  COMPREPLY=""
}


_main_subcommand ()
{
  _e "main subcommand"
  local i=1 cmd

  # find the subcommand
  while [[ $i -lt $COMP_CWORD ]]; do
    local s="${COMP_WORDS[i]}"
    case "$s" in
    -*) ;;
    subcommand) ;;
    *)
      _e "cmd is $s"
      cmd="$s"
      break
      ;;
    esac
    (( i++ ))
  done

  if [[ $i -eq $COMP_CWORD ]]; then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    _e "current completion candidate $cur"
    COMPREPLY=($(compgen -W "plain help" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    plain) _main_subcommand_plain ;;
        *) ;;
  esac
}

_main_subcommand_plain ()
{
  local cur="${COMP_WORDS[COMP_CWORD]}"
  case "$cur" in
    -*) 
      COMPREPLY=($(compgen -W "-h --help help" -- "$cur"))
      return 
      ;;
  esac
  COMPREPLY=""
}

_main_subcommand2 ()
{
  _e "main subcommand2"
  local i=1 cmd

  # find the subcommand
  while [[ $i -lt $COMP_CWORD ]]; do
    local s="${COMP_WORDS[i]}"
    case "$s" in
    # -*) ;;
    subcommand2) ;;
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
    COMPREPLY=($(compgen -W "plain help --testing" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    plain) _main_subcommand2_plain ;;
        *) COMPREPLY="";;
  esac
}

_main_subcommand2_plain ()
{
  local cur="${COMP_WORDS[COMP_CWORD]}"
  case "$cur" in
    -*) 
      COMPREPLY=($(compgen -W "--opt1 -h --help help" -- "$cur"))
      return 
      ;;
  esac
  COMPREPLY=""
}

# complete -F _main main.rb
complete -o bashdefault -o default -F _main main.rb
