---
layout:     post
title:      Running io.js on Azure Websites
date:       2015-01-12 10:22:00
summary:    You can run io.js on Azure Websites easily, by configuring azure to use a custom node version. This blog shows you how.
---

![io.js temporary logo](http://richorama.github.io/images/io.png)

## Download the io.js binary

io.js can be downloaded here : [https://iojs.org/download/](https://iojs.org/download/)

You just need the `iojs.exe` file itself which you can get from the nightly builds, for example:

(https://iojs.org/download/nightly/v1.0.0-nightly2015011284fa1f8c46/win-x64/)[https://iojs.org/download/nightly/v1.0.0-nightly2015011284fa1f8c46/win-x64/]

Place this file in a `bin` directory.

## Configuring Azure

To tell Azure Websitest that you want to use this version of node, rather then the version supplied by Microsoft, add a `iisnode.yml` file, with this line:

{% highlight yaml %}
nodeProcessCommandLine: "D:\home\site\wwwroot\bin\iojs.exe" --harmony
{% endhighlight %}

> note I've added the `--harmony` flag to enable generators.

## Create a Web Server

Now just create your node app in the usual way, to star with you could write out the node version over HTTP:

{% highlight js %}
var http = require('http');

var server = http.createServer(function(req, res){
	res.end(process.version)
});

server.listen(process.env.PORT || 8080);
{% endhighlight %}

## Deploy to Azure in the usual way

```
$ git init
$ git add .
$ git commit -am "intial commit"
$ azure site create
$ git push azure master
```

> Note that your web server will run using this version of node, but npm and other build steps will use the version supplied by Microsoft.

## Next steps

To make it easy, I have publised an [example project](https://github.com/richorama/iojs-azure) on GitHub.

To make it even easier, I've add the '[Deploy to Azure](azure.microsoft.com/blog/2014/11/13/deploy-to-azure-button-for-azure-websites-2/)' button, to get you going really quickly.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/?repository=https://github.com/richorama/iojs-azure)