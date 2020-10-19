---
layout: post
title: Keeping it Simple
date: 2020-10-19 09:00:00
summary: I recently worked on an internal project with a team of grads and inexperienced developers. Five of us in total. It was a short project - a line-of-business application to convert spreadsheets into software. It was a lot of fun.
---

I recently worked on an internal project with a team of grads and inexperienced developers.
Five of us in total. It was a short project - a line-of-business application to convert spreadsheets
into software. It was a lot of fun.

The challenge for me was how to get four people as productive as possible in a short timescale,
given the extraordinarily high concept count of modern software development projects.

When I say high concept count, these are the concepts you need to learn for a typical project
(your mileage may vary):

* HTTP
* HTML
* CSS
* React
* Typescript
* Redux (maybe)
* JSON/REST
* Node/npm
* C#
* ASP.NET core
* Entity Framework (or dapper)
* SQL
* SQL Server
* Git
* Bitbucket
* Azure Pipelines
* JIRA
* VSCode

To a seasoned developer, this is just a normal shopping list, but to someone with little or no
experience (i.e. not even knowing what some of these things are!), there is a lot to learn.

I feel for the junior develop of today. When I started programming there was just Turbo Pascal.
There was nothing else. No source control, I didn't have a database, it came with an editor.
There was no internet available, so you were left with just the manual -
but once you read that you were away. I'm sure my code would look terrible now.

So I decided to simplify this project as much as possible, mainly by removing all JavaScript from the
browser, and using server-rendered (asp.net core) pages, consolidating on Bitbucket (or this could
have just as easily been GitHub) for all source code, builds and ticket management, and using Azure
Table Storage (thus removing SQL and all it's subtlety).

This gives us a much shorter list:

* HTTP
* HTML
* Razor views
* CSS
* C#
* ASP.NET core
* Azure Table Storage
* Git
* Bitbucket (source control, pipelines & issues)
* VSCode

Building an application without a browser-based front end seems crazy in this day and age,
but the UI was fast, responsive and I don't think any user really noticed.

Ok, you can't easily add maps, and interactive controls. But not every application needs these things.

We were left with just a single programming language, a simplified toolchain, and no API to create/consume.

It was interesting to stand back and watch how the team progressed. Everyone contributed and demonstrated
that they understood how the application worked. It was interesting to observe that the hardest
paradigm to understand was the MVC pattern. Knowing the precise role of models, views and controllers
was not as intuitive as I had thought. It took a little while for team to really get it.

This project taught me the pleasure of simplifying architecture. I think this goes against
the mindset of a lot of people. I often see a mentality of wanting to use every latest technology
available, resulting in very complicated architectures which are hard to develop, maintain and operate.

But I have found that less really is more.