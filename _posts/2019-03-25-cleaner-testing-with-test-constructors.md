---
layout: post
title: "cleaner testing with 'test constructors'"
description: "a superior testing strategy for nested data systems"
date: 2019-03-25
tags: [objectmother, kotlin, testing, lessons]
comments: true
published: false
---

Dealing with nested data in tests is a hard problem. 
For systems with deep object graphs (in our case, mortgages), 
the problems are exacerbated by orders of magnitude. 

This blog post has been 3 years in the making, but 
[due to a recent post](https://www.jworks.io/easy-testing-with-objectmothers-and-easyrandom/) 
on [reddit](https://www.reddit.com/r/programming/comments/b59km1/using_objectmothers_to_manage_your_test_data/)
I've been prompted to actually sit down and write it once and for all. 

For the rest of the article we're going to use an example 
object to show how difficult it can be to deal with nested data.

wip: b3debd7cb439bb9208c06ca29bd6193dc421530f

# traditional

Let's start by talking about the traditional way of doing things.
Usually if you need a lot of test data you can do one of two things. 

1. Create new test data everywhere you need it. 
2. Use a factory to create the test data. 

Now with Java, these really are the two only ways of doing it. 
You need a factory, or you need to create the test data inline. 
(or you can use that EasyRandom class that is mentioned in the above
articles, but that is only a solution for one case as I'll talk about later)

## problems

### create test data in each test

The problem with the first solution is obvious, using the object above, to 
test anything you not only need to come up with data for each test, but you 
must instantiate every single nested item as well. And you might need to do
this hundreds or thousands of times, depending on the size of your test suite. 

The problem with the second solution is not so obvious. We started out using 
test factories PromonTech and within a year were in agony over the absolute
terribleness of the solution. 

* They are not flexible. If you need to pass different data for a specific 
test, well, too bad. 
* They cascade test failures through an entire system when changes are made 
to test data.
* They cascade compile failures through the entire system, _even if unrelated
refactors are made_. 

That last one is one of the biggest problems. No matter how well you write 
your test factories. If you make a change to a nested class, and that class is
used in a test factory, then that change will cascade through every single 
test factory that uses that object in any way. This is completely unsustainable
for large systems.  