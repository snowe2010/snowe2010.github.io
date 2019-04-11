---
layout: post
title: "‘PT’: OUR TOOL OF TOOLS"
description: "creating the standardized tools and process to ensure consistent deliveries"
date: 2019-04-11
tags: ["ruby", "devops", "tools", "thor"]
comments: true
---

## creating the standardized tools and process to ensure consistent deliveries

As start-ups grow, they face new challenges and need to evaluate the various tools available to streamline and standardize their processes. At PromonTech, our path wasn’t much different. As a result we needed to complete a thorough audit of our dev tools and practices. Our goal, as always, was to prioritize increased developer efficiency. We identified our top three problems and determined the best strategy and technology to solve for each of them. We then merged these three solutions to create a comprehensive tool addressing the full problem-set: the ‘pt’ tool. 

This article outlines the solutions we elected and what our overall process looked like. 

### the audit

Every startup encounters similar challenges when setting up development environments: 

* different workflows
* different teams
* different tools
* different configurations

Managing multiple agile teams with hundreds of tickets creates code deployment complexity.  Every team member needs a solution for running the full stack in a “release” fashion.  Front-end needs to run the back-end team’s code in “release” fashion, but their own front-end code locally. The opposite is true for back-end. UX engineers need to run everything in “release” fashion. As a result, our teams had different approaches and tools for their build processes and branch management. 

As PromonTech grew, teams branched in different directions. We needed to create broad solutions standardizing and simplifying our day-to-day processes. This included understanding and rationalizing our tool-sets to ensure the consistent application of frameworks.  Having multiple tools wasn’t ideal.
At a high level, we needed a uniform approach to: 

* Start up consistent DEV, UX, and QA environments
* Consolidate cross-company scripts into a single location
* Easily apply developer updates 

### the requirements

Initially, the list of tool requirements was small; we talked to the sprint teams and they described needs relating to the following:

* Running all microservices, databases, and front-end services locally
* Running individual microservices on specific branches
* Making updates and distribution easy and seamless 
* Allowing for other tools to be added later

### problem 1: consistent environments

The most difficult thing was getting consistent environments between developers. If front-end developers tried to run the code locally, a number of things might go wrong. They might not have Java; they might not have maven; they might have the wrong version of Java; and so on. If you want to just run a `jar` file then the dev wouldn't be able to start the code on a co-worker's branch. If you want to start up the front-end services you might need to set up /etc/hosts routes. You need to compile the code. The list goes on and on. We needed to define and apply a  consistent and repeatable process.  

### solution: docker

Docker fixes all these issues, and it works for development – very, very well. 

Docker allows you to create small self-contained servers that run each application or microservice in isolation. We generate these Docker containers every time we push code to GitHub. By leveraging the containers we were already generating, we could standardize the operating system across every developer’s device.

Working with our dev teams, we ensured everyone was on board with the efficiency of this new process. Our teams recognized we can start any branch of any microservice without needing to build the code locally. With Docker, we achieved instant startup times and resolved all of the above problems. 

### problem 2: cross-platform effectiveness 

At PromonTech we have dedicated expertise in each tech discipline – front-end, back-end, data and DevOps. As a result, each team identifies and manages unique tools. Tracking, managing and ensuring the cross-platform effectiveness of these tools is a challenge. We needed to run a wide variety of tools and to aggregate these different tools without making developers learn a specific language. We also needed a good command-line interface (“CLI”), sane defaults, and an easy-to-use structure. 

### solution: ruby

Specifically, RubyGems – the Ruby community’s gem hosting service. More specifically, a Ruby gem with the Thor framework. Ruby, because it's extremely easy to read, easy to learn, and highly powerful. Thor, because it provides an extensible subcommand framework enabling the building of a deep CLI with abundant  features. 

### problem 3: easy distributing and updating

We needed to distribute and allow for easy updates to the tool set. The tool shouldn't auto-update, but it should be auto-updateable, if necessary. The tool should not be exposed to the outside world. And, it should provide native support and be easy to install. 

### solution: homebrew

Homebrew is a free, open-source software package management system that’s easy to use, easy to create new formulas for, and easy to distribute a CLI tool with ... sort of. While the documentation isn’t ideal, getting it set up is simple if you’re well-versed in Ruby.  It can be set up so formulas depend on each other –  enabling individuals to write their own CLIs and tie them into the 'pt' tool with no additional work. 

## the system: the ‘pt’ tool

After vetting our solutions, we ended up with a comprehensive system affectionately called: the ‘pt’ tool. The 'pt' tool is a tool of tools. It handles all of the CLI portion of the program, along with anything that hasn't been delegated to other tools from other teams. It handles internal PromonTech Docker containers, connecting to remote servers, release processes, Consul queries, database connections, and more. For other things like generating HashiCorp Vault credentials and connecting to remote servers, it calls out to other Homebrew Formula. 

'pt' is complemented by other Homebrew Formula, like the above mentioned vault credential generator. 'pt' can shell out to any tool a team comes up with, so it's easy to distribute CLIs from other teams using Homebrew and then call out to them from the main CLI. 

## the result

Success! The flexibility of this system has allowed individual teams to create tools that work for them; and to distribute those tools to the rest of the company in a simple, easy to use, easy to extend CLI. 

Solving for each problem individually – then working to build a unique system addressing each issue – gave us the efficient, consistent processes we so desperately needed. 

_This article was posted in conjuction with my [LinkedIn article](https://www.linkedin.com/pulse/pt-our-tool-tools-tyler-thrailkill/)_