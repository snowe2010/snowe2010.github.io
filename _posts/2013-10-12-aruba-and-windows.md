---
layout: post
title:  "Aruba and Windows"
date:   2017-10-21 12:20:11 -0600
categories: aruba windows
excerpt_separator: <!-- more -->
---

This is the story of a man who just wanted to write a nice CLI using GLI based on the nice tutorials in Build Awesome Command-Line Applications in Ruby 2 Control Your Computer, Simplify Your Life by David Copeland I wish he had written the book for Windows users and not Mac and Linux, but I'm just going to have to get over that.

I actually made it a significant way through the book with minimal problems. At one point I did have to open a gem called groff and change some stuff, but I won't know if my changes worked until I do a little more tinkering. My major problem came when I encountered the chapter on Cucumber testing. Oh boy! Something I am extremely experienced in! Oh Aruba? I've heard of that before. Ah it's for command-line testing of applications using Cucumber? Ah ok, that sounds really usefull. He says it doesn't work very well on Windows? Nonsense, Googling leads me to believe that no one has problems with it ever!

<!-- more -->

WRONG!

Oh boy was I wrong. I figured out why Googling didn't lead me to anything. No one wants to try to get it to work with Windows. It's too nasty. But I really wanted to get this working, so I dug deep. Let's begin.

I began by creating the structure of my app. It's called rdt and it's short for Recondo Developer Tools.

gli init rtt setup build
This creates two commands for the CLI called setup and build. At this point all I'm looking for is to get some failing tests going and only worry about what my app will do, and not what it currently is doing. I'm following along with David's instructions which is mostly stuff I know. Thankfully, his GLI gem automatically creates a Feature file and one step for us to get started with.

rdt.feature
```bash
Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself
 
  Scenario: App just runs
    When I get help for 'rtt'
    Then the exit status should be 0
```

rdt_steps.rb
```
When /^I get help for '([^"]*)'$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end
```

David states

If you're running this locally, you'll notice that the output is green.

This is where my trouble started.

This is what my output looked like (ignoring color, pretend that the Scenario line is black, From When to Then is red, and Then is blue)

```
Scenario: App just runs            # features\rdt.feature:6
  When I get help for 'rdt'        # features/step_definitions/rdt_steps.rb:1
    The system cannot find the file specified. (2) (Aruba::LaunchError)
    ./features/step_definitions/rdt_steps.rb:3:in `/^I get help for '([^"]*)'$/'
    features\rdt.feature:7:in `When I get help for 'rtt''
  Then the exit status should be 0 # aruba-0.5.4/lib/aruba/cucumber.rb:188
```

"Welp that's an unhelpful error", I thought to myself as I now tried furiously to figure out what could have gone wrong. At first I thought it was Aruba's fault. They did implement these Gherkin steps. First stop:

C:/Ruby193/lib/ruby/gems/1.9.1/gems/aruba-0.5.4/lib/aruba/cucumber.rb
1
2
3
When /^I run `([^`]*)`$/ do |cmd|
  run_simple(unescape(cmd), false)
end
which lead me on a long windy path to here:

C:/Ruby193/lib/ruby/gems/1.9.1/gems/aruba-0.5.4/lib/aruba/spawn_process.rb
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
def run!(&block)
  @process = ChildProcess.build(*shellwords(@cmd))
  @out = Tempfile.new("aruba-out")
  @err = Tempfile.new("aruba-err")
  @process.io.stdout = @out
  @process.io.stderr = @err
  @process.duplex = true
  @exit_code = nil
  begin
    @process.start
  rescue ChildProcess::LaunchError => e
    raise LaunchError.new(e.message)
  end
  yield self if block_given?
end
Turns out Aruba doesn't even run the process sanely with `` (I don't really understand what ChildProcess does different than system or %x tbh.) So this nice error turns out to actually be coming from Windows itself according to Jari Bakken, dev on Selenium-Webdriver, Watir-Webdriver, and tons of other useful gems.

I still couldn't understand how this was Window's fault so I had to dig even deeper. I got into FFI and C code at the root of Ruby and still couldn't figure out what was going on. I backed out and tried executing many different commands in the cucumber script like:

1
2
3
4
5
step %(I run `bundle exec ruby bin/#{app_name} help`)
 
step %(I run `bundle exec ruby ./bin/#{app_name} help`)
 
step %(I run `rdt help`)
and more.

I debugged to the point where I realized that Aruba was not adding the bin folder to my path. So I then tried step %(I run `ruby ../../bin/#{app_name} help`) and what do you know!? That worked! But because it's a GLI app, you can't just run from the bin folder without running it through bundler. So I tried step %(I run `bundle exec ruby ../../bin/#{app_name} help`) and of course this did not work. Back to the drawing board.

With a little more searching I finally stumbled upon this little thread stating that bundle/rdt need to be executable to be able to be created by ChildProcess which in turn uses CreateProcess in C.

The final solution:

1
step %(I run `bundle.bat exec ruby ../../bin/#{app_name} help`)
Though of course, this is not a long term solution. I'm going to have to dig and see how Aruba creates its load path and figure out what I can do from there to get this working.