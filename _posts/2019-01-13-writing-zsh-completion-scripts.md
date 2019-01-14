---
layout: post
title: "writing zsh completion scripts"
description: ""
date: 2019-01-13
tags: [zsh, tutorial]
comments: true
---

Almost every tutorial I've found out there is woefully inadequate for
properly teaching how to write a zsh completion script. Now, I'm
going to be just as inadequate, but I'm going to detail a specific
type of completion script since I had trouble finding information
about how to write one like this. 

## subcommands

Imagine a CLI app with this help text:

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

so you can see we have some 'top-level' commands, and some subcommands with a command under them. 
Several commands have options that can be provided to them.  

Step one. Set up your main calling function

```zsh
#compdef _cli cli

function _cli {
    local line
    
    # completion area for subcommands
    function _commands {
        local -a commands
        commands=(
            #add subcommands here
        )
        _describe 'command' commands
    }

    # completion area for options/arguments
    _arguments -C \
        #put arguments here
        "1: :_commands" \
        "*::arg:->args"

    case $line[1] in
        # call completion functions for each nested subcommand here
}
```

Alright, so you've got this part complete. I've named our executable `cli`, to make things easier to read.
Let's take this in parts:

### _commands

The `_commands` function is used here to allow completion of all commands 
_at the current level_ with descriptions.

The syntax is `'command_name:command_description'`. Very easy. Let's fill out this section now.

```zsh
# completion area for subcommands
function _commands {
    'plain:This is a plain command'
    'subcommand:nested subcommand'
    'subcommand2:nested subcommand'
}
_describe 'command' commands
```

You can place any description you want here. The description will be shown to the right of the 
command when completing the functions. 

### _arguments

The `_arguments` function is, well you've probably got this by now. Args at the current level. 

The syntax here is `"--flag_name[description here]" \`. If you have multiple flags that do the same
thing, such as a short and long flag, you _must have matching descriptions_. 

Also note the following backslash. This is necessary since you are technically calling the `_arguments` 
function. We're splitting the function call across multiple lines. Let's fill out this section now:

```zsh
# completion area for options/arguments
_arguments -C \
    "--class-opt[a global option]" \
    "1: :_commands" \
    "*::arg:->args"
```

### case $line[1] in

This section is probably the easiest section to understand. You're just matching the value of `line[1]` 
to an option in a list. `line` is set by the `_arguments -C` call, which sets several other variables
as well, but we don't care about those right now. 

```zsh
case $line[1] in
    # call completion functions for each nested subcommand here
    plain)
        _cli_plain
    ;;
    subcommand)
        _cli_subcommand
    ;;
    subcommand2)
        _cli_subcommand2
    ;;
esac
```

Quite simple. We just match the things we want to match based off of the current context and then call
another function to continue the completions. Currently this only completes the _top level of completions_.

Now let's move down a level and define the next level of functions. Let's start with just the bodies and we'll
fill them in one at a time.


```zsh
function _cli_plain {
}
function _cli_subcommand {
}
function _cli_subcommand2 {
}
```

Starting with the `plain` command, we see that it takes no more nested subcommands. But it does take an option. 

To add an option we just use the same method from before. This time we don't need to set the context, so we 
don't need to use the `-C` flag. 

```zsh
function _cli_plain {
    _arguments \
        "-o[an option]" \
        "--opt1[an option]" \
        "1: :_commands" \
        "*::arg:->args"
}
```

Here you can see the use of the same description for both flags in order to group them together. 

For the nested subcommands, we get to go back to the same functions as before!

```zsh
function _cli_subcommand {
    function _commands {
        local -a commands
        commands=(
            'plain:a command under subcommand'
        )
        _describe 'command' commands
    }
    _arguments \
        "1: :_commands" \
        "*::arg:->args"
    case $line[1] in
        plain)
            _cli_subcommand_plain
        ;;
    esac
}
function _cli_subcommand2 {
    function _commands {
        local -a commands
        commands=(
            'plain:a command under subcommand2'
        )
        _describe 'command' commands
    }
    _arguments \
        "1: :_commands" \
        "*::arg:->args"
    case $line[1] in
        plain)
            _cli_subcommand2_plain
        ;;
    esac
}
```

I will leave it as an exercise to the reader to finish the last bit of code here. Simply continue on with the pattern
as we have been, and it makes zsh completions for subcommands relatively easy. 

zsh completions are obtuse, but the system that is set up enables extreme flexibility and power. I wish you the best
of luck writing your own completion scripts. 


