---
title: 'Setting up Ruhoh'
date: '2013-10-10'
description:
tags: []
---

Ruhoh is an awesome Universal Static Website Framework for creating static websites. 
It's 10000x better than Jekyll and it's what runs this website here.

This is a tutorial about how to get Ruhoh up and running without reading thousands of pages of documentation (there's only like 10, really). 

## Step 1. Install it ##

```brush:rb
require 'sass'

# this is a fake class showing the use of code blocks
module HelpClass
  class Model < SuperClass
    include APage
    attr_accessor :help, :me
  
    A_CONSTANT = :idk

    def initialize params
      puts "I hope this works, because this is highlighted blue and #{this should be highlighted something else}"
      puts @help
      @@me
      $write.each do |test|
        test.each
      end
    end

    def test_another(callsomething = 0, something = true, somt = nil, som = false)
      something.init (true)
      chain.of.methods
      numbers = [1,2,3,4,5,6]
    end
  end
end
```

Prerequisites: Ruby 1.9

The first step is to create the directory where you want your website to be stored. 
I'm going to be using a terminal/command prompt to do most of this tutorial. 
I'm also going to call my site ruhoh-site and I would suggest you do the same. 
You can always change it later, but it will make it easier to follow along for right now.
Also I will specify where directions might differ between operating systems.

```brush:bash
cd C:\Users\tyler.thrailkill\Dropbox
mkdir ruhoh-site
cd ruhoh-site
```

As you can see I've changed directories to my Dropbox, made the ruhoh-site directory, and then changed directories into ```C:\Users\tyler.thrailkill\Dropbox\ruhoh-site```
    
Now we need to create a file called Gemfile. 
The Gemfile allows you to use the gem ```bundler``` in order to keep your gems up to date. 
We want two lines in this file so we'll accomplish that all with these commands

```brush:bash
echo "source 'https://rubygems.org'" > Gemfile 
echo "gem 'ruhoh'" > Gemfile 
```

Next we need to install the bundler gem and then run a command to install the ruhoh gem

```brush:ruby
gem install bundler
bundle install
```

The first command might take a while, but when it finishes go ahead and run the second. This will install all gems in your Gemfile. 

At last we have installed ruhoh. On to Step 2!

## Step 2. Create a website ##

So now that you've got it running, go ahead and 