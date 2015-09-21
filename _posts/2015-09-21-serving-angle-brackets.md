---
layout:     post
title:      Serving Angle Brackets
date:       2015-09-21 14:51:00
summary:    In this series of blog posts, we're looking at how to set up a simple web app in node. In this post we're going to put the plumbing in for serving html, both static and dynamic pages.
---

In this series of blog posts, we're looking at how to set up a simple web app in node.

In the [previous installment](http://richorama.github.io/2015/09/18/node-and-express-from-scratch/) we got the basic set up running. In this post we're going to put the plumbing in for serving html, both static and dynamic pages.

## Serving static files

We could serve static files using express to match on a given path like this `app.get('/filename', ...)` and returning the file in the response. However, this gets quite tedious. A much easier approach is to set up some middleware to handle static files.

Hold on, what's middleware?

When express processes an incoming HTTP request, you can register your own code to run as part of this pipeline. Middleware is the opportunity to hook into all incoming requests, or just requests to a specific path. For example, you could register some middleware to ensure that requests are authenticated, or to decode specific content types.

We'll register some middleware which will intercept requests matching the name of a static file and serve it for us.

To do this, add this line to `server.js`:

{% highlight JavaScript %}
var path = require('path');
app.use(express.static(path.join(__dirname, 'public')));
{% endhighlight %}

Let's unpack this line of code:

1. `require('path')` will load a module for working with directory names. It's a module that comes with node, so you don't need to use npm to install it.
1. `__dirname` is a variable in node, giving us the name of the directory which contains the script file.
1. `path.join` will append file system paths together. So here we're appending 'public' to the current directory.
1. `express.static` is the middleware which serves static files.
`. `app.use` registers middleware for every request.

So this line instructs the express app to serve static files from the 'public' directory. 

Express is sensitive to the order of middleware being registered, you need to add it above any of your routes, but after the app is created. 

Your `server.js` should now look like this:

{% highlight JavaScript %}
// load the path package
var path = require('path');
// load the express package
var express = require('express');

// create an express application 
var app = express();

// register middleware to serve static pages
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', function(req, res){
	res.send('hello world');
});

// start listening on port 8080
app.listen(8080);
{% endhighlight %}

Now, lets create a `public` folder:

{% highlight text %}
> mkdir public
{% endhighlight  %}

You can add a file in there, perhaps a favicon (`favicon.ico`).

You'll have to restart your node process, but you should see you file is now being served.

This allows you to serve static assets from your node app, without your application code needing to be concerned about what the files are. Any request that comes in and matches a filename will be automatically served for you.

## Server-side templating

We don't want to just serve static file with node, we want to use some logic to create dynamic content.

My preference is to use [mustache templates](https://mustache.github.io/) for converting data into html. So let's plug mustache in.

[Hogan.js](https://github.com/twitter/hogan.js/) is a JavaScript implementation of Mustache, and [hogan-express](https://github.com/vol4ok/hogan-express) allows you to easily hook it up to express.

Install the module using npm: 

{% highlight text %}
> npm install hogan-express --save
{% endhighlight  %}

Now let's register the middleware to handle the views:

{% highlight JavaScript %}
app.engine('html', require('hogan-express'));
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');
app.set('layout', 'layout');
{% endhighlight %}

These lines can be placed immediately above the `app.use` we wrote earlier for the static files.

Let's unpack this code line by line:

1. `app.engine` registers a templating engine. Here we pass in the 'hogan-express' module, and register it as the templating engine for html.
1. `app.set` sets an application setting. First we set the `views` setting, which is the directory where the views are stored. We use the `path` module again to refer to a sub-directory called `views`.
1. We set the default view engine to be html (which refers to the one we registered on the first line).
1. Finally the `layout` variable is the view which is used as the template.

Now let's create a directory for our views;

{% highlight text %}
> mkdir views
{% endhighlight  %}

We can add a `layout.html` file to this directory, which will contain our template:

{% highlight html %}
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{{title}}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"></style>
  </head>
  <body>

    {{{ yield }}}

  </body>
</html>
{% endhighlight  %}

> Note that we're referring to the bootstrap stylesheet hosted on a [CDN](http://www.bootstrapcdn.com/).

Now let's create a simple view to show the current time.

{% highlight html %}
<div class="container">
	The time is : {{ time }}
</div>
{% endhighlight  %}

Call this `time.html`, and add it to the `views` directory.

Now we need to go back to our `server.js` file and wire it up.

Replace the `app.get('/' ...)` code with this:

{% highlight JavaScript %}
app.get('/', function(req, res){
	res.locals.time = new Date();
	res.locals.title = 'the current time';
	res.render('time');
});
{% endhighlight  %}

Let's unpack the code:

1. We create a new data object (which is initialised with the current time), and sets a `time` property on a `res.locals` variable. `res.locals` allows you to pass data into the view. 
1. We also use `res.locals` to set the title of the page, which is in the `layout.html` template.
1. Finally we tell express to render the response with the `time` template.

Our `server.js` file now looks like this:

{% highlight JavaScript %}
// load the path package
var path = require('path');
// load the express package
var express = require('express');

// create an express application 
var app = express();

// set up hogan for rendering views
app.engine('html', require('hogan-express'));
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');
app.set('layout', 'layout');
// register middleware to serve static pages
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', function(req, res){
	res.locals.time = new Date();
	res.locals.title = 'the current time';
	res.render('time');
});

// start listening on port 8080
app.listen(8080);
{% endhighlight  %}

That's it!

We could of course listen to more paths, and create more views. 

Next we'll look at reading and writing to a database - the node way!