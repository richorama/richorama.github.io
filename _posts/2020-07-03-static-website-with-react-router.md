---
layout: post
title: Hosting static websites with React Router
date: 2020-07-03 09:00:00
summary: !!!.
---

Both the Microsoft Azure Storage and Amazon S3 storage services allow you to host static websites.
They both make for excellent storage hosts, as they're low cost, easy to update and support high
traffic volumes.

[React Router](https://reactrouter.com/web/guides/quick-start) is a popular library for providing
client-side routing of React Single Page Applications. The advantage with this approach to client
routing is that the router adjusts the URL in the browser, so it appears you're navigating to different
pages on the server, but you're in fact just staying on the same HTML page and changing the content of the page.

This is great, right up to the point when the user presses `F5`, or deep links into your application.
The storage system then attempts to load a page that doesn't actually exist, and you get a 404.

This doesn't happen during the development process because webpack's web server will return your
index page instead of a 404 page.
