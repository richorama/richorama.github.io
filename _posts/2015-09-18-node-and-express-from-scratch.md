---
layout:     post
title:      Setting up Node and Express
date:       2015-09-18 14:51:00
summary:    I've been talking to a few people lately about how I build web applications. There's no single right-way of doing it, but here's my workflow, split into small blog posts you can follow. 
---

I've been talking to a few people lately about how I build web applications. There's no single right-way of doing it, but here's my workflow, split into small blog posts you can follow. 

First of all, let's create a web server using node.js.

## Setting Up

As a prerequisite, install node.js. You can download the latest version [here](https://nodejs.org/en/download/).

You'll also need somewhere on your computer to save the files you're going to create. Using your console, navigate to the correct place, and create a directory:

{% highlight %}
> mkdir my-app
> cd my-app
{% endhighlight %}

> If you're planning on using git, you can also create a `.gitignore` file. Just add `node_modules` to the ignore list.

## Installing Express

[Express](http://expressjs.com/) is a framework which makes it easy to write web servers in node.

All the files you need are stored in the [npm repository](https://www.npmjs.com/). This is database of packages for node.js. You'll find express [here](https://www.npmjs.com/package/express).

To install express, you just need to type:

{% highlight %}
> npm install express
{% endhighlight %}

You'll notice that a `node_modules` directory is created, with an `express` sub-directory. This contains all the express code, as well as its dependencies.

## Hello World

Now let's create a basic web server and start listening on port 8080 for web requests.

You need to create a JavaScript file, you can use your favourite text editor. Let's call it `server.js`:

{% highlight JavaScript %}
// load the express package
var express = require('express');

// create an express application 
var app = express();

// handle GET requests at /
app.get('/', function(req, res){

	// respond with plain text
	res.send('hello world');
});

// start listening on port 8080
app.listen(8080);
{% endhighlight %}

Somethings to note about what we've written:

1. The express package can be used to create multiple web servers listening on different ports, which is why we need to call `express()` to create an instance of an application.
1. We all `app.get(...)` to register a route that listens to GET requests that match the supplied path. You can also call `app.post()`, `app.put()` etc... or `app.all()`.
1. When registering a route, you supply a function which get called every time a request is received which matches it. The function should have `req` and `res` arguments, which represent the request and response data respectively.
1. You must tell the application which port to listen on to start the web server.

Let's fire up the application, and make sure it works. To do this, call node, passing our script file as the first argument:

{% highlight %}
node server.js
{% endhighlight %}

No point your browser to `http://localhost:8080/` and you should see `hello world`.

## Package.json

It's a good idea to create a `package.json` file. Its not necessary, but its useful for keeping track of the packages your application uses.

To create one, run:

{% highlight %}
> npm init
{% endhighlight %}

You can just go with all the default options, or set the values if you want.

> You can run `npm init` at any point, it'll figure out what packages you've already included.

This will create a `package.json` file.

When adding further packages, if you add the `--save` option, npm updates the `package.json` file so it keeps it up to date.

When you want to run your app on another machine, you can just copy over your JavaScript and your `package.json` file (without copying all the packages in `node_modules`). You can then run `npm install` to restore all the modules on one go.