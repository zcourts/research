---
layout: page
title: Distributed Graph Database
tagline: Thinking of tomorrow, today!
---
{% include JB/setup %}


# What?

What am I researching? Simply put, I'm trying to find a practical, scalable way to build a distributed graph database.

### Why, isn't there a lot of work being done on that front already?

Yes. In fact, the last 30 or so years has seen a significant amount of work being done in the graph field. However, we have yet to realize the full potential of these, almost ubiquitous structures. Graph traversals in particular remain an extremely difficult thing to do on very large data sets.

### Another Big Data project?

__No this isn't another "Big Data" blah blah.__ Recent strides in data warehousing/processing have had both a good and bad impact on the field. I'm of the opinion that it is actually unfortunate that Graph databases have been lobbed under the whole Big Data marketing hype. At the same time, the exposure has increased the amount of research in the area so I'm somewhat in two minds about that.

# Why

I'm a big fan of [Cassandra](http://cassandra.apache.org). I've been working with it since 2008, not long after it was open sourced by Facebook.

My fascination with Graphs started when I realized that a lot of the work I did, a lot of what I know other people use Cassandra for could actually be represented and queried more efficiently as Graphs.

I explored existing projects like [Titan](http://thinkaurelius.github.io/titan/) and went through related projects in the [TinkerPop Stack](http://www.tinkerpop.com/).
Twitter's [FlockDB](https://github.com/twitter/flockdb) and others, but they all fall short in one way or another.

# It's all about speed

Ultimately the big issue with distributed graph traversal comes down to speed. And that's all there is to it...sort of.

Actually the big problem is partitioning a dynamic, evolving distributed graph. The location of a vertex affects how fast it and it's edges can be traversed in a query (so speed).

# Premise, Current line of thinking

The cost of accessing vertices across servers (nodes) depends mainly on the speed of the network. If local operations can be optimized to be (potentially) orders of magnitude faster than network operations and local ops. are performed much more frequently than network ops. then the __amortized__ cost of a distributed traversal should be more than acceptable for most scenarios.  Ideally traversal over data up to 1TB should be no more than a few seconds, but to be hopeful a sub-second target is on hand.

# Amortization... you what now?

[Robert Tarjan's, Amortized Computational Complexity]( /papers/Amortized%20Computational%20Complexity.pdf ) formally introduced the idea of amortized computational costs. It's a simple but note worthy idea. My premise is in effect rested on this idea. That is, computational complexity isn't a simple matter of determining 'big O'. A system's purpose is to perform a given set of tasks, these tasks typically are broken down into smaller tasks. Each requiring a varying amount of computing resources/time. Amortization rests on the idea that some tasks are more "expensive" than others. If there are enough "cheap" tasks, each time they run the acrue "credit" that can eventually be spent performing the more expensive tasks. It follows that, if there are enough cheap tasks to consistently provide enough credit then the effects of performing more expensive tasks can effectively be thought of has being negligable...or there abouts.

Naturally I paraphrased that. And that is, at least in my mind a decent interpretation of amortized costs/complexity.

# Who?

Okay, okay, I got the idea. You're trying to do something that's been done 50 times already. Who are you anyway?

Well, my name is Courtney Robinson. On the web you can find me under the username "zcourts". If it matters, If I'm a member, I'll be registered under that username, unless the service doesn't allow me to...in which case that service probaly doesn't matter so I'm not registered :P.
I have a 1st class BEng, Hons Software Engineering degree from Greenwich University. I'm a proud born and largely raised Jamaican, naturalized Briton and your not so every day hacker. I'm in my early 20s building awesome stuff at [DataSift](http://datasift.com).

I started working on this project during my final year while I was attempting to build my own startup.

# What's it called?

It's a bit early to be naming "it", even though I've been building this for about a year, I'm not ready to release it yet. However, I have named it, I really wanted to call it "Tesseract", so much so that when all permutations of that domain name were unavailable, I tried all permutations of it's translation that still sounded cool, and that I could actually pronounce. Eventually came accross hiperkubo which is Esperanto for Tesseract. I didn't like the entire thing for a name but quite liked kubo. So I registered "[kubo.io](http://kubo.io)".

# What's it written in?

__Haskell__ (some C and C++ here and there)! At first my only reason for choosing Haskell was because I wanted to learn it. As it turned out, many ideas from the functional programming world are excellent for a database and I'm trying to take advantage of all of them. Saying that, I've also seen the problems Cassandra had in the early days where it was entirely reliant on the JVM for memory management. I wanted a memory managed environment away from the JVM that ideally compiled to C/assembly. [Chris Okasaki's, Purely Functional Data Structures]( /papers/okasaki.pdf ) is one key bit of reading that has helped influnce some of my design choices and solidified Haskell as the right language for the job.

# Is it open source?

It will be! I'm planning to release it under either a 3-clause BSD or the Apache v2 license. 

So why haven't I done that yet? A lot of what I've created in the last year (just over a year now I think) or so are pieces of the puzzle. Independent experiments that together will form a complete system, but the glue to get them together as one hasn't been written yet so it's not fully functional as a system. I have experiments in three areas, file systems, query engine and data caching. Effectly all the pieces are there but I won't bring them together until I'm satisfied with the performance/algorithms of each independently.

# Pages

<ul>
  {% assign pages_list = site.pages %}
  {% include JB/pages_list %}
</ul>

## Categories

<ul>
  {% assign categories_list = site.categories %}
  {% include JB/categories_list %}
</ul>

## Posts
<div>
{% assign posts_collate = site.tags.homepage %}
{% include JB/posts_collate %}
</div>

## Tags

<ul>
  {% assign tags_list = site.tags %}
  {% include JB/tags_list %}
</ul>

Built with <a href="http://jekyllbootstrap.com" target="_blank">Jekyll Bootstrap</a> and <a href="http://github.com/dhulihan/hooligan" target="_blank">The Hooligan Theme</a>