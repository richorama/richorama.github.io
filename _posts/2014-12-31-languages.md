---
layout:     post
title:      Languages
date:       2014-12-31 10:08:00
summary:    In the office we have a healthy, ongoing discussion about language choice. We generally discuss some hypothetical long term (10, 25, 100 year?) software project, and what language would be the most suitable.
categories: blog
---

> Disclaimer, this post is opinionated, poorly researched, and really just the thoughts in my head.

In the office we have a healthy, ongoing discussion about language choice. We generally discuss some hypothetical long term (10, 25, 100 year?) software project, and which language would be the most suitable. With no real requirements it's more of a fun debate than a serious design exercise, but you can assume that the system will probably be distributed, talk over HTTP, and have a fair amount of 'business logic'.

I don't think systems need to be written in _one_ language. Programming languages are just a tool, and many successful software project combine a mixture of languages to solve different aspect of the problem. However, we're failing to pick just one great candidate given the current choice of languages, and the industry churn. Remember, this is a longterm software project, so bit rot and maintainability are important factors.

If I've missed something, been unfair, unkind or wrong, please let me know and I might adjust the article.

## .NET (C# or F#)

We're a Microsoft shop, and most of our software is written in C#.

I'm currently doing some updates to a 10 year old .NET project (I accept this is anecdotal evidence) and I can't build the data layer on my machine because some now defunct, closed source, 3rd party component requires MDAC 2.7, which is now obsolete. I have to use a VM of an old dev machine to get that bit of the project done. I can't open the main project solution, and when ASP.NET vNext comes along I doubt it will work at all.

For some reason bit rot in .NET seems to set in very quickly. I like C#, and I'm quite productive in it, and it produces stable software. However the average .NET project seems to draw in lots of packages and controls which don't upgrade nicely. 

I know the future might be looking bright for .NET given that it's open source, and ASP.NET vNext seems to be going in the right direction, but I've been burnt too many times before.

`not viable`

## Node.js

We use node for spiking out software and building proof of concepts. I'm very productive in node, thanks to npm and the 1st class nature of JSON.

I see quite a few posts on hacker news telling me that the JavaScript world moves too fast, and it's all about fashion, and too many package dependencies will kill me. I call this innovation. You don't have to pull any packages in from npm if you don't want to. The ability to maintain 3rd party packages is possible, whereas in .NET it's not always so easy (in my experience).

Node isn't great at everything. Networking and I/O are it's domain (that's what a web application does?) but it's not the ideal choice for number crunching. Also, with limited compile-time safety (you can lint and unit test), it makes long-term maintainability over a large codebase challenging. Although this can be mitigated by not creating a large codebase!

I put node down as a maybe. 

`possible candidate`

## Julia

I've played around with Julia, and was immediately impressed by the ease of use and the pleasant syntax. The community is very responsive, and the language is moving in a sensible and responsible way. But Julia is very young (2 years old) and lacks the features for building the kind of system I'm thinking of (i.e. there's no 'express' / 'rails' / 'MVC' for Julia).

Definitely a language to keep an eye on.

`not currently viable`

## Java

I haven't done much Java, and I'd like to keep it that way. My impression of the language is that too much time is spent doing the boiler plate, and not adding features. It's been slow to catch C# up on language features, and Object orientation doesn't seem to be the right approach anyway.

`not viable`

## Clojure

I have played around with Clojure a bit and I like it. However, it seems like a language of compromises, the biggest of which is sitting on the JVM. Is this a stepping-stone language, or a long term viable option? It's hard for me to say.

I'll put it down as a maybe.

`maybe`

## Scala

Scala also suffers the JVM problem, but has less appeal (to me) than Clojure. Perhaps I should spend more time looking at it, but it doesn't get me very excited.

`not interested`

## Ruby

We have a product written in Ruby, and the language itself is good. However, the impression I get is that people are leaving Ruby, and fleeing to Go, Node and Elixir. Am I right, or is it just hype? 

Ruby lacks performance, and (from an outsiders perspective) seems to have version problems similar to python. 

I don't think it has a great long-term future - sorry!

`not viable`

## Common Lisp

Rob is a keen lisper, and has built many successful software projects in the past using c-lisp. However, the community seems to be small and not particularly embracing/outgoing/interested? It looks all but dead to me - which is a shame.

`not viable`

## Go

Go seems to be all the rage at the moment. I don't have enough experience to form an opinion, so perhaps I should spend some time with it.

`unknown`

## Python

I like python, but it seems to be suffering under 2.7 / 3.x version problems. It doesn't _feel_ like the right choice for a long term, large software project, but I don't have enough data to back that up.

`maybe`

## Haskell

I'm not clever enough to program in Haskell. 

`not viable`

## Erlang

There are some great benefits in sitting on the Erlang Virtual Machine, but the Erlang syntax itself is a bit odd. This would be a maybe if it wasn't for Elixir.

`not viable`

## Elixir

Get the benefits of the Erlang VM, but with a modern language. This looks like an interesting possibility. I must learn Elixir and find out more.

`maybe`

## PHP

Just no.

`not viable`

## C

You could bet your bottom dollar that your program will compile in 1000 years time, but C doesn't seem to be the right choice for building a modern system. Neither would assembly language.

`not viable`

## C++

C++ is a complicated mess.

`not viable`

## Rust

An interesting language, but rather than taking an opinion about how software should be built, rust just seems to throw everything at you. You can be functional, object-orientated or procedural. As a result it feels like a large and complicated language. It also doesn't feel finished.

`not viable`

# Conclusion

I'm going to spend more time with Go, Clojure and Elixir. They look like interesting candidates for the next language. 

In the meantime I'm just going to build stuff in node.