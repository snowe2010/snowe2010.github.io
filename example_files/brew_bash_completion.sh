#!bash


_test() {
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
    # Do not auto-complete "*instal" or "*uninstal" aliases for "*install" commands.
    # Prefix newline to prevent not checking the first command.
    # local cmds=$'\n'"$(brew commands --quiet --include-aliases | \grep -v instal$)"
    # __brewcomp "$cmds"
    __brewcomp "cask"
    
  # COMPREPLY=($(compgen -W "cask" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    bottle)                     _brew_bottle ;;
    cask)                       _brew_cask ;;
    tap-pin)                    __brew_complete_tapped ;;
    test)                       __brew_complete_installed ;;
    unpin)                      __brew_complete_formulae ;;
    *)                          ;;
  esac
}

_e () {
  echo "$(date) : $1" >> log
}

_brew_cask ()
{
  echo "" >> log
  echo "" >> log
  echo "" >> log

    local i=1 cmd

    # find the subcommand
    _e "comp words $COMP_WORDS"
    while [[ $i -lt $COMP_CWORD ]]; do
        local s="${COMP_WORDS[i]}"
        case "$s" in
        --*)
            _e "break out with double dash... this is weird"
            cmd="$s"
            break
            ;;
        -*)
            _e "do nothing for single dash"
            ;;
        cask)
            _e "do nothing maybe, why though??? "
            ;;
        *)
            _e "break out $s"
            cmd="$s"
            break
            ;;
        esac
        (( i++ ))
    done

    if [[ $i -eq $COMP_CWORD ]]; then
        _e "$i i equaled comp_cword $COMP_CWORD"
        __brew_caskcomp "create doctor fetch info install list --version"
        return
    fi

    # subcommands have their own completion functions
    case "$cmd" in
      --version)              __brewcomp_null ;;
      create)                 ;;
      doctor)                 __brewcomp_null ;;
      fetch)                  _brew_cask_fetch ;;
      info|abv)               __brew_cask_complete_formulae ;;
      install|instal)         _brew_cask_install ;;
      list|ls)                _brew_cask_list ;;
      outdated)               _brew_cask_outdated ;;
      reinstall)              __brew_cask_complete_installed ;;
      style)                  _brew_cask_style ;;
      uninstall|remove|rm)    _brew_cask_uninstall ;;
      upgrade)                _brew_cask_upgrade ;;
      zap)                    __brew_cask_complete_caskroom ;;
      *)                      ;;
    esac
}

_brew_cask_fetch ()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prv=$(__brew_caskcomp_prev)
    _e "cur $cur  previous $prv"
    case "$cur" in
    -*)
        __brew_caskcomp "--force"
        return
        ;;
    esac
    __brew_cask_complete_formulae
}

__brewcomp() {
  # break $1 on space, tab, and newline characters,
  # and turn it into a newline separated list of words
  local list s sep=$'\n' IFS=$' \t\n'
  local cur="${COMP_WORDS[COMP_CWORD]}"

  for s in $1
  do
    __brewcomp_words_include "$s" && continue
    list="$list$s$sep"
  done

  IFS="$sep"
  COMPREPLY=($(compgen -W "$list" -- "$cur"))
}

__brewcomp_words_include() {
  local i=1
  while [[ "$i" -lt "$COMP_CWORD" ]]
  do
    if [[ "${COMP_WORDS[i]}" = "$1" ]]
    then
      return 0
    fi
    (( i++ ))
  done
  return 1
}


_brew_cask_uninstall ()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    case "$cur" in
    -*)
        __brew_caskcomp "--force"
        return
        ;;
    esac
    __brew_cask_complete_installed
}


__brew_caskcomp_words_include ()
{
    local i=1
    while [[ $i -lt $COMP_CWORD ]]; do
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
        __brew_caskcomp_words_include "$s" && continue
        list="$list$s$sep"
    done

    IFS="$sep"
    COMPREPLY=($(compgen -W "$list" -- "$cur"))
}


complete -F _test test