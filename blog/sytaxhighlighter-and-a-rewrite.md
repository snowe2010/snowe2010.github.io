---
title: 'Rewriting Sytax Highlighter'
date: '2013-10-13'
description:
tags: [sytaxhighlighter, ruby, javascript]
---

I started the tutorials section by trying to write a post about how to get Ruhoh up and running nice and quick. I used code sections to make things easier, and for that I had to find a good syntax highlighter. I didn't like the way that Google's PrettyPrint worked and I couldn't get SyntaxHighlighter to work (which I later discovered was just because I didn't understand javascript very well) so I went through a ton of different syntax highlighters until I finally learned enough JS from those that I realized I was an idiot when trying to use SyntaxHighlighter.

As a result of all this, I've learned very well how to use Chrome's javascript debugging and breakpoints. The better lesson is, I learned that syntax highlighting is more difficult than it looks :| I'll try to cover some of these difficulties below.

It started when I began to try and make SyntaxHighlighter highlight more things (for Ruby it doesn't highlight the method name or the parameters). I thought this would be easy, because in the brushes you can just define a regex to highlight what you want. Yay, so all I need to do is check for def followed by a name up to a space or a parens. This can be done with something along the lines of this regex:

```
/(?<=def\s)(\w+\b)\??/g
```

Essentially all this does is find the word following def. 

Nope. Not that easy. Javascript doesn't support positive or negative lookbehind. Hmm what can I do? Ok I can write a regex to just not capture the def! That can be done like this

```
/(?:def\s)(\w+\b)\??/g
```

Nope. No it can't because even though javascript won't capture that group, it will still match the whole thing :|, while returning a second match of just the captured group. This would work fine if I could somehow figure out how to return just the second match. Well here's the code, maybe you can see the problem.

```brush:js
function getMatches(code, regexInfo)
{
  function defaultAdd(match, regexInfo)
  {
    return match[0];
  };

  var index = 0,
    match = null,
    matches = [],
    func = regexInfo.func ? regexInfo.func : defaultAdd
    pos = 0
    ;

  while((match = XRegExp.exec(code, regexInfo.regex, pos)) != null)
  {
    var resultMatch = func(match, regexInfo);

    if (typeof(resultMatch) == 'string')
      resultMatch = [new sh.Match(resultMatch, match.index, regexInfo.css)];

    matches = matches.concat(resultMatch);
    pos = match.index + match[0].length;
  }

  return matches;
};
```


As you can see, we always return the first match, oh but wait, it looks like we can give it a function to return a different match! Sweet, let's do that.

Well this appeared to work for a few seconds, then I noticed that now even though stuff was highlighted properly, the word "def" was missing from every single definition. It was now replaced by the method name, and then part of the method name would repeat for no reason. What was going on. 

It turns out that the original writer of the plugin would pull out things that matched multiple times, instead of coding it in a way that didn't require that. As it is, I'm stuck and my code blocks aren't going to look very good for a while. 

Shoot. 
