---
title: I've run out of reasons not to blog more frequently
date: 2012-01-04 09:21:07
tags: [ Perl, blogging, Markdown ]
---

I spent most of last year not blogging even though there were occasions where I thought I had something useful to say. The reason? 

I need a path of very low resistance between me and the published word.

_In other words I want the blog to get out of the way so I can use tools that let me work fast and easy._

Here are my modest demands:

   1. Native Markdown support.
   2. I want to use my editor of choice (vim, since you ask).
   3. Posts should be as easy to edit as they are to create (I'm an inveterate polisher). 
   4. Sensible use of screen width (without me having to fiddle with complex templates)
   5. Not a dealbreaker, but [Perl](http:/www.perl.org) syntax highlighting would be awesome.

The two main contenders last year were [Tumblr](http://www.tumblr.com/) and [Posterous](http://posterous.com/) (or Posterous Spaces as they now insist on calling it).

Posterous looked promising despite the narrow viewport, but the API's markdown support was push only and a request to the devs to support retrieving posts as markdown went unacknowledged. The [CodeRay](http://coderay.rubychan.de/) syntax highlighting library Posterous use doesn't support Perl and I was told pretty firmly by its developer that it wasn't on the roadmap.

Tumblr's Markdown support is more complete, but using your own app requires jumping through a few hoops to get it approved - nothing too onerous but remember I said _low resistance_. Tumblr's default templates don't seem to lend themselves to code blocks and trying to adapt them to my needs was just an entry to a world of hurt - I want to write, not be a frontend developer. Syntax highlighting doesn't come out of the box either.

All of which brings me to [Calepin](http://calepin.co/), an elegant combination of simplicity and geek-friendliness. I'm not going to explain how it works, because [the docs](http://calepin.co/) explain that just fine, but the more observant among you will have noticed that this very post is published on Calepin. I will however mention that it does Perl syntax highlighting out of the box :-)

Give it a try!

_Since I originally wrote this article the creator of Calepin (not unreasonably since it was a labour of love) closed the site_
