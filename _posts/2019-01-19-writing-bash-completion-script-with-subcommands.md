---
layout: post
title: "writing bash completion script with subcommands"
description: ""
date: 2019-01-19
tags: [bash, tutorial]
comments: true
published: true
---

Following along from my last post, I'm going to detail how 
to write bash completion scripts for deeply nested subcommands.
Most bash completion tutorials are not clear at all, and _none_ 
of them cover subcommands. I used the `brew` completion scripts 
to reverse engineer how bash subcommand completion should be 
written and I've detailed it here. Hopefully this is helpful to 
somebody!

# The application

We're going to use the same application as last time. 


```
$ ruby .\main.rb -h
Commands:
  main.rb help [COMMAND]  # Describe available commands or one specific command
  main.rb plain           # This is a plain command
  main.rb subcommand      # nested subcommand
  main.rb subcommand2     # nested subcommand

Options:
  [--class-opt=CLASS_OPT]  # a global option

$ ruby .\main.rb help plain
Usage:
  main.rb plain

Options:
  o, [--opt1=OPT1]             # an option
      [--class-opt=CLASS_OPT]  # a global option

This is a plain command

$ ruby .\main.rb help subcommand
Commands:
  main.rb subcommand help [COMMAND]  # Describe subcommands or one specific s...
  main.rb subcommand plain           # command under subcommand

$ ruby .\main.rb subcommand2 -h
Commands:
  main.rb subcommand2 help [COMMAND]  # Describe subcommands or one specific ...
  main.rb subcommand2 plain           # command under subcommand2

$ ruby .\main.rb subcommand plain -h
Usage:
  main.rb subcommand plain

command under subcommand

$ ruby .\main.rb subcommand2 plain -h
Usage:
  main.rb subcommand2 plain

Options:
  [--opt1=OPT1]

command under subcommand2
```

# A regular bash completion script

Here is an example script from [tldp.org](https://www.tldp.org/LDP/abs/html/tabexpansion.html)

```bash
_UseGetOpt-2 () 
{ 
  local cur
  COMPREPLY=()   # Array variable storing the possible completions.
  cur=${COMP_WORDS[COMP_CWORD]}

  case "$cur" in
    -*)
    COMPREPLY=( $( compgen -W '-a -d -f -l -t -h --aoption --debug \
                               --file --log --test --help --' -- $cur ) );;

  esac

  return 0
}

complete -F _UseGetOpt-2 -o filenames ./UseGetOpt-2.sh
```

This script only performs completions at one level though. I'm going to assume you've 
looked into writing bash completion scripts and you understand the basic premise of 
populating the `COMPREPLY` array with a list of words using `compgen -W`. There 
are many different ways you can call `compgen`, but thankfully we should only need the `-W` flag.

# Writing a subcommand completion script

## Generic layout

Let's start with the 'generic' layout 

```bash

_main() {
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
    COMPREPLY=($(compgen -W "cask" -- "$cur"))
    return
  fi

  # subcommands have their own completion functions
  case "$cmd" in
    cask)                       _main_subcommand ;;
    *)                          ;;
  esac
}

complete -F _main main
```

Wait a minute. This doesn't look anything like the first script. Ok yeah, 
the layout for a subcommand is gonna be entirely different. 

##### Reply with subcommands: 

If no subcommand has been typed yet then you set the COMPREPLY array to your list of _current subcommands_ and immediately return. Since no subcommands have been typed yet, 
you only want the completion replying with the current subcommand list. 

That is this part:
```bash
if [[ "$i" -eq "$COMP_CWORD" ]]
then
    COMPREPLY=($(compgen -W "subcommand" -- "$cur"))
    return
fi
```

##### Parse current context and call corresponding functions: 

If a command has begun to be typed (that's the `while [[ "$i" -lt "$COMP_CWORD" ]]` part)
then check if it's a flag or a subcommand. If it's a subcommand then set the `cmd` variable
and continue to: 

```bash
  case "$cmd" in
    _subcommand) _main_subcommand ;;
    *)           ;;
  esac
```

Note that the original block `if [[ "$i" -eq "$COMP_CWORD" ]]` won't be hit since `$i` is 
currently _less than_ `COMP_CWORD`. 
{: .note }

If our completion word matches in this statement then the corresponding function will be called. 
Else the function will continue on (and end) and will repeat when the user presses `<TAB><TAB>` again.

##### Call into subcommand functions:







