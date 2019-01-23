---
layout: post
title: "writing bash completion script with subcommands"
description: ""
date: 2019-01-19
tags: [bash, tutorial]
comments: true
published: false
---

Following along from my last post, I'm going to detail how 
to write bash completion scripts for deeply nested subcommands.
Most bash completion tutorials are not clear at all, and _none_ 
of them cover subcommands. I used the `brew` completion scripts 
to reverse engineer how bash subcommand completion should be 
written and I've detailed it here. Hopefully this is helpful to 
somebody!

## the application

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

## a regular bash completion script

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

## writing a subcommand completion script

### generic layout

Let's start with the 'generic' layout 

```bash
_main() {
  local i=1 cmd 

  # find the subcommand
  while [[ "$i" -lt "$COMP_CWORD" ]]
  do
    local s="${COMP_WORDS[i]}"
    case "$s" in
      -*) ;;
      *)
        cmd="$s"
        break
        ;;
    esac
    (( i++ ))
  done

  if [[ "$i" -eq "$COMP_CWORD" ]]
  then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "plain subcommand subcommand2 --class-opt -h help" -- "$cur"))
    return # return early if we're still completing the 'current' command
  fi

  # we've completed the 'current' command and now need to call the next completion function
  # subcommands have their own completion functions
  case "$cmd" in
    subcommand) _main_subcommand ;;
    *)          ;;
  esac
}

complete -F _main main
```

Wait a minute. This doesn't look anything like the first script. Ok yeah, 
the layout for a subcommand is gonna be entirely different. 

----------------

### returning completions

Let's shrink that down to understandable chunks and build upon it.

```bash
_main() {
  local cur="${COMP_WORDS[COMP_CWORD]}"  #|1|
  COMPREPLY=($(compgen -W "plain subcommand subcommand2 --class-opt -h help" -- "$cur")) #|2|
}
```

1. Set our `$cur` variable to the current word. In this case it will always be `main`.
2. Set the `COMPREPLY` variable to an array of `plain subcommand ... etc` _for the command $cur_

    This allows the completion engine to detect _when_ it can use the `COMPREPLY` completions list. 
    If you don't specify `$cur` at the end here, then your completions _will not work_. This was a 
    huge hanging point for me, because you need to set it to the correct `$cur` at all times. 

So far so good. We just check if we're on the `main` command and then return the list of completions.

**lesson: for all completions, return a list of words using `compgen`**

--------------

### exit early

Now let's check where we are in the array. If we've succeeded at completing a command we then need to do something with it. 

```bash
_main() {
  local i=1 #|1|

  if [[ "$i" -eq "$COMP_CWORD" ]] #|2|
  then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "plain subcommand subcommand2 --class-opt -h help" -- "$cur"))
    return #|3|
  fi

  #|4|
  case "${COMP_WORDS[COMP_CWORD]}" in
    *)          ;;
  esac
}

complete -F _main main
```

1. Set a variable to 1, the position of `main` _always_ in `COMP_WORDS`
2. Check if we are completing the first command `main`
3. If we are still completing `main` (but why would we still be completing main you might ask? wait and see) then just return early
4. If we aren't still completing `main`, then we must be on to a subcommand! Go ahead and do stuff here, like calling more completion functions. 

**lesson: exit early to avoid performing completions for subcommands**

--------------

### find your subcommand

**This isn't going to work though!** Why? Well what if you have flags or options on `main`? Then when you try to complete them `main --class-opt`, 
it's going to think you're now past the first subcommand and on to the second and it won't complete any of the other valid subcommands for this
layer, `plain subcommand subcommand2 help` or even the other option `-h`! For example, this will complete properly,


```bash
$ main <TAB><TAB>
--class-opt  -h           help         plain        subcommand   subcommand2
```

but this won't! 

```bash
$ main --class-opt <TAB><TAB>
# no completions 😭
```

**Solution**: Iterate over the current `COMP_WORDS` array until you find a subcommand. 

```bash
_main() {
  local i=1 cmd #|1||2|

  while [[ "$i" -lt "$COMP_CWORD" ]] #|3|
  do
    local s="${COMP_WORDS[i]}" #|4|
    case "$s" in
      -*) ;; #|5|
      *)
        cmd="$s" #|6|
        break
        ;;
    esac
    (( i++ ))  #|7|
  done

  if [[ "$i" -eq "$COMP_CWORD" ]]
  then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "plain subcommand subcommand2 --class-opt -h help" -- "$cur"))
    return 
  fi

  case "$cmd" in
    *)          ;;
  esac
}

complete -F _main main
```

1. `$i` is now a counter variable starting at 1. 

    That's what the `COMP_CWORD` counter will start at, so if we have typed `main<space>` 
    then the counter will be `1`. And if we have typed `main subcommand` then the counter will be `2`

2. Create a `cmd` variable to hold the currently completed subcommand. 
3. Check the index against the `COMP_CWORD` variable and only find a subcommand if we're currently completing a subcommand.

    This is the key to checking for subcommands. This code will only run when you have initiated a completion after the `main` command. 
    `main<TAB><TAB>` will result in `while [[ "1" -lt "1" ]]` whereas `main <TAB><TAB>` will result in `while [[ "1" -lt "2" ]]` at this spot

4. We grab the 'currently iterated word' from the array and set it to a var
5. If our 'current' word _starts with `-`_ **then it is not a subcommand**
6. If it doesn't start with a `-` then we know we are completing a subcommand. We just set `cmd` to the current spot in `COMP_WORDS` and break out of the loop. 
7. If we're not to the current subcommand then we iterate and continue.  

**lesson: iterate over `COMP_WORDS` array to check and set the current subcommand**

-------------

### adding in nested subcommands

After all that, we're finally getting to the _nested_ part of it. Sheesh, this is a lot of work to read nested subcommands. 

Let's take the bottom part here. Nothing is currently happening here, so let's update it. 

```bash
  case "$cmd" in
    plain) _main_plain ;;
    subcommand) _main_subcommand ;;
    subcommand2) _main_subcommand2 ;;
    *)           ;;
  esac
```
Easy enough. Call functions for the 3 main subcommands, and don't call anything for anything else. 
`--class-opt` doesn't accept files or anything like that, so we don't need to add file completion in,
but if we did need that then you would need to find a way to either: 

1. perform the completion in the `while` block, when hitting `-*)` cases, or
2. mark `-*)` as subcommands, and perform the logic in this `case` block, making sure that you still allow completing the other top level commands. 

**lesson: call subcommand functions from `case` statement _after_ completing top level commands**

-------------

### subcommand functions

Let's add in those subcommand functions now. 

We'll start with the `plain` subcommand, as that's the easiest. 

```bash
_main_plain ()
{  
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "--opt1 --class-opt" -- "$cur")) #|1|
}
```

1. Let's start by returning just the completions, with no other logic. 
  `$cur` will always be the current word at this point (do you see the issue yet?)

```
$ main plain --<TAB><TAB>
--class-opt  --opt1
```

Cool, this subcommand completion works. 

```
$ main plain --class-opt --<TAB><TAB>
--class-opt  --opt1
```

Hm. seems that since we are 'dead-ending' at this function every time, we will always get
these completions. This is the first step to understanding why subcommands are so hard. 

**lesson: _always_ keep track of the current and previous subcommand.**

--------------

### keeping track of current and previous words 

```bash
_main_plain ()
{  
  #|1|
  local i=1

  while [[ $i -lt $COMP_CWORD ]]; do
    local s="${COMP_WORDS[i]}"
    case "$s" in
      -*) ;;
      plain) ;; #|2|
      *)
        # cmd="$s" #|3|
        break
        ;;
    esac
    (( i++ ))
  done

  if [[ $i -eq $COMP_CWORD ]]; then
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "--opt1 --class-opt" -- "$cur")) #|4|
    return
  fi
}
```

I've done the entire function in once since we've covered most of this already. 

1. Using the same structure as before
2. We need to skip all completion commands up until our 'current' one, i.e. the one we are actually completing right now.

    This involves skipping all `COMP_WORDS` up to our subcommand, and then once we've gotten to the proper subcommand we can continue. 
    Notice that `-*)` and `plain)` are the first things in the `case` statement. We don't want anything else being hit first, as we're just searching for 
    the current subcommand. 

    This of course will not work for subcommands like this `main plain plain`, because you'll never make it to the second `plain`. I have
    no reason to solve this problem right now though, so I'll leave it to the reader. 

3. We no longer need subcommands (in this function) so no need for the `cmd` variable
4. Complete your options normally! Note that you _must_ use this `if` statement, else you'll encounter the problem above! The if statement only
    continues completions if we're one spot after `plain`, instead of two or three spots later

**lesson: only complete after reaching your current subcommand**

----------------

### subcommand with nested functions

Applying all that we've learned above we should now be able to make the last two subcommand functions pretty easily. 

