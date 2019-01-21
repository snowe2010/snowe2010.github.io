#!bash


_main() {
  echo "" >> log
  echo "" >> log
  echo "" >> log

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
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    subcommand) _main_subcommand ;;
    *)          ;;
  esac
}

_e () {
  echo "$(date) : $1" >> log
}

_main_subcommand ()
{
    local i=1 cmd

    # find the subcommand
    _e "main subcommand"
    _e "comp words $COMP_WORDS"
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
        subcommand) 
          _e "subcommand"
          ;;
        *)
          _e "star"
            cmd="$s"
            break
            ;;
        esac
        (( i++ ))
    done

    if [[ $i -eq $COMP_CWORD ]]; then
      _e "equal"
      local cur="${COMP_WORDS[COMP_CWORD]}"
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
  _e "fetch"
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prv=$(__brew_caskcomp_prev)
  _e "cur $cur  previous $prv"
  case "$cur" in
  -*)
      __brew_caskcomp "--force"
      return
      ;;
  esac
  COMPREPLY=($(compgen -W "fetch_sub1 fetch_sub2" -- "$cur"))

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
  _e "caskcomp_pre comp_cword $COMP_CWORD"
  local idx=$((COMP_CWORD - 1))
  _e "idx $idx"
  local prv="${COMP_WORDS[idx]}"
  _e "previous $prv"
  while [[ $prv == -* ]]; do
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