---
title: Problems with Fig Newton, RSpec, and Cheezy's Cucumber & Cheese
date: '2013-06-01'
description:
tags: [fignewton, ruby, rspec, watir-webdriver, watir, page-object, cheezy]
---

I use Watir-webdriver, PageObject, and several other gems (at the instruction of Jeff "Cheezy" Morgan), for my job. Currently I've been writing tests to perform some functions that business people have no care or need to know about. Because there is no need to have business rules for these tests, I'm using RSpec instead of Cucumber. I have Cucumber tests to run all of the business rules that the BA's need to know about and RSpec tests for those side scripts or non-business side of things. I've also read up extensively on Jeff's Cucumber & Cheese book, though I had forgotten several key points. 

For these tests I was trying to load Default Data for different environments, and therefore I was using Jeff's FigNewton gem. FigNewton allows the use of different configuration files based on the environment the script is being run from. For this you need to place require 'fig_newton' in the correct place and also call FigNewton.load('local.yml') with whatever file you want to load. If you don't want to use a specific file you can leave out the line and it will first look for an ENV variable called FIG_NEWTON_FILE, then if that is not found it will look for a file named after the hostname of the computer, and then finally if even that is not found it will look for a file called 'default.yml'. 

I was getting errors telling me that it could not find the 'default.yml' file even though I had specified the correct file in the env.rb.

1. There is a spec_helper.rb file for RSpec that does the same job as the env.rb file for Cucumber. For some reason I believed that RSpec was using the env.rb file, which caused a lot of problems. 
2. I am also using a gem specified by Jeff called require_all. This gem requires all files in a directory you specify, and it was in the line directly above my FigNewton call. This was causing the FigNewton line to never get called. I'm fuzzy on the details right now about why, so I'll update this post at a later time when I've figured it out.  

After moving the line "FigNewton.load('local.yml')" above the "require_all 'lib'" line, and also placing it in the spec_helper.rb file, I was finally able to use default data. 

