---
layout:     post
title:      Rendering leaflet.js tiles in the browser
date:       2018-08-22 09:00:00
summary:    I wrote a fractral viewer using Leaflet.js which renders map tiles in the browser using a pool of service workers.
---

## TL;DR

I wrote a fractral viewer using Leaflet.js which renders map tiles in the browser using a pool of service workers.

You can [view the app](https://richorama.github.io/frac-js/) and [source code](https://github.com/richorama/frac-js).


![](/images/frac-js2.png)

## Introduction

I've used [leaflet.js](https://leafletjs.com/) before to render fractals in [Go](https://github.com/richorama/go-mandlebrot) and [C#](https://github.com/richorama/OrleansMandelbrot), but I thought it would be intersting to see if it was possible to render tiles in the browser without any cooperation from a tile server.

First of all, what is a fractal? A fractal, such as the Mandlebot or Julia plot, is an image drawn using a mathematical formula. 
The formula takes two coordinates, and runs an iterative function until an exit condition is met. The colour for that pixel then represents the number of iterations that the formula took. If the exit condition is not met, it hits a limit on the maximum number of iterations we want to support, and it's (usually) coloured black.

Fractals have some interesting properies. We can zoom into them and discover more detail, and repeating patterns.

Leaflet.js is well suited to exploring fractals, it allows you to browse a 2D surface, and zoom in/out.

## Attempt 1 - Rendering to a canvas

In my first attempt I create a tile layer, and override the function that gets the url for the tile (`getTileUrl`).

Rather than supplying a URL to a tile server, I create a canvas, then render the fractal onto that canvas, then 
convert the canvas to a data url, and set the tile src to that.

{% highlight js %}
var map = L.map('map', {crs: L.CRS.Simple}).setView([-128, 128], 2);

L.TileLayer.Mandlebrot = L.TileLayer.extend({
    getTileUrl: function(coords) {
        return draw(coords.x, coords.y, coords.z);
    }
});

new L.TileLayer.Mandlebrot().addTo(map);

function draw(x, y, z){
    var canvas = document.createElement("canvas");
    canvas.width = tileSize;
    canvas.height = tileSize;
    var ctx = canvas.getContext("2d");
    var imageData = ctx.getImageData(0, 0, tileSize, tileSize);
        
    /* code which draws the fractal on the imageData removed for readability */
    
    ctx.putImageData(imageData, 0, 0);

    return canvas.toDataURL();
}
{% endhighlight %}

[Try it out](/images/mandlebrot1.html)

This technique worked, but there was a problem. The fractal calculation is CPU intensive, and it's running on the single UI thread that the browser is also using to render the page. This meant that when leaflet requested tiles, the browser stopped responding to user input, and the app freezes.

## Attempt 2 - Service Worker

To improve the performance we can stand up a Service orker, and render the tile in a different thread, passing the image data back to the UI thread for display.

Service workers are background processess that run in a separate Javascript event loop (thread). We can communicate between the UI script and the worker using message passing. 

In the main JavaScript a redesign is required in the way the tile URL is set, as we now have to render the fractal asynchronously using this message passing, rather then the blocking technique used earlier.

We can do this by overriding `createTile` in the TileLayer. This allows us to control the creation of the tile, and grab a reference to it which we can use later to set the image data once the fractal has been rendered. 

We do this by generating an id, which we pass along with the coordinates to the worker. The worker then passes back the image data with the original id. We then look up the tile and set the data.

To create the tile we use some code like this:

{% highlight js %}
// index.js
var tiles = {};
var id = 0;

var worker = new Worker('worker.js');

var map = L.map('map', {crs: L.CRS.Simple}).setView([-128, 128], 2);

L.TileLayer.Mandlebrot = L.TileLayer.extend({
    createTile:function(coords, done){
        var tile = document.createElement('img');

        L.DomEvent.on(tile, 'load', L.Util.bind(this._tileOnLoad, this, done, tile));
        L.DomEvent.on(tile, 'error', L.Util.bind(this._tileOnError, this, done, tile));

        tile.id = (id++).toString();
        tile.setAttribute('role', 'presentation');

        tiles[tile.id] = tile; // hold a reference to the tile 

        worker.postMessage({ coords:coords, id:tile.id });

        return tile;
    }
});

new L.TileLayer.Mandlebrot().addTo(map);
{% endhighlight %}

In the worker we listen to the 'onmessage' event, waiting for messages to be passed to us, and then render the required tile.

Workers cannot create DOM elements, therefore we cannot create a canvas, but we can create an 'ImageData' object which underpins the Canvas.

We can then render the fractal onto the ImageData, and pass it back to the UI on completion.

{% highlight js %}
// worker.js
onmessage = function(e) {
    var imageData = draw(e.data.coords.x, e.data.coords.y, e.data.coords.z)
    postMessage({id:e.data.id, imageData: imageData});
}

function draw(x, y, z, data){
    const imageData = new ImageData(tileSize, tileSize);

    /* code which draws the fractal on the imageData removed for readability */

    return imageData;
}
{% endhighlight %}

Back in the user interface we receive the message from the worker, retrieve the tile by the id and then set the image source using the canvas to generate the image data uri.

{% highlight js %}
// index.js
worker.onmessage = function(event){
    var tile = tiles[event.data.id]; // retrive the tile
    if (!tile) return;

    const canvas = document.createElement("canvas");
    canvas.width = canvas.height = tileSize;

    const ctx = canvas.getContext("2d");
    ctx.putImageData(event.data.imageData, 0, 0);

    tile.src = canvas.toDataURL(); // set the source of the tile
    delete tiles[event.data.id]; // remove reference to tile
}
{% endhighlight %}

## Attempt 3 - Worker Pool

On multi-core systems, we could render tiles faster if fractal rendering was distributed across all cores, rather than just a single core which a single Service Worker will consume.

In order to do this we need to maintain queue of requests for work, and then distribute them across a pool of workers.

First of all, how many workers should we generate? To try to reach 'mechanical sympathy' we should probably match the number of worker threads to the CPU count. The `navigator.hardwareConcurrency` property will give you this number.

What's the best way to distribute the work? I decided to use a LIFO (last in first out) queue. This means that the tile most recently asked for will be the next tile to render. As the user navigates around, we may find that we spend time rendering tiles that have since dissapeared off the screen, so LIFO should provide the best user experience.

I attempted to write some generalised work distribution code:

{% highlight js %}
// index.js
const WorkDistribution = function(options){
    const queue = [];
    const pool = [];

    // set up workers
    for (var i = 0; i < (options.concurrency || 4); i++){
        const worker = new Worker(options.src);
        worker.working = false;
        pool.push(worker);
    }

    // execute the next item of work
    const processQueue = function(){
        if (!queue.length) return;
        const nextWorker = pool.filter(x => !x.working)[0]
        if (!nextWorker) return;

        var work = queue.pop();
        nextWorker.working = true;
        nextWorker.onmessage = function(e){
            nextWorker.working = false;
            work.cb(e);
            processQueue();
        }
        nextWorker.postMessage(work.item);
    }

    return {
        push : function(item, cb){
            queue.push({item:item, cb:cb});
            processQueue();
        }
    };
}

// create an instance of the work distributor
const workerPool = WorkDistribution({
    oncomplete : workerComplete,
    concurrency : navigator.hardwareConcurrency,
    src : 'worker.js'
});
{% endhighlight %}

We can then call the `workerPool` from the TileLayer, rather than calling the worker directly.

{% highlight js %}
// index.js
var map = L.map('map', {crs: L.CRS.Simple}).setView([-128, 128], 2);

L.TileLayer.Mandlebrot = L.TileLayer.extend({
    createTile:function(coords, done){
        const tile = document.createElement('img');

        L.DomEvent.on(tile, 'load', L.Util.bind(this._tileOnLoad, this, done, tile));
        L.DomEvent.on(tile, 'error', L.Util.bind(this._tileOnError, this, done, tile));
        
        if (this.options.crossOrigin) tile.crossOrigin = '';

        tile.alt = '';
        tile.setAttribute('role', 'presentation');

        workerPool.push({coords:coords, id:tile.id, type : (this._type || 'mandlebrot')}, (e) => {
            const canvas = document.createElement("canvas");
            canvas.height = canvas.width = options.tileSize;

            const ctx = canvas.getContext("2d");
            ctx.putImageData(event.data.imageData, 0, 0);

            tile.src = canvas.toDataURL();
        });
        return tile;
    }
});

new L.TileLayer.Mandlebrot().addTo(map);
{% endhighlight %}

Note that because each worker only processes one message a time, we can refactor the code slightly and use a callback based approach, doing away with the `tiles` object, and just use the tile from within the closure.

## Attmpt 4 - Ignore removed tiles

When navigating around the fractal, it's often the scenario that tiles are requested by Leaflet but by the tile there is a worker ready to process them, they have already disappeared from the screen.

We'll alter the WorkDistribution to support cancellation. 

When queueing an item of work we'll return a cancellation function. The queue will then remove cancelled items, and not bother to process them.

{% highlight js %}
const WorkDistribution = function(options){
    let queue = [];
    const pool = [];

    // set up workers
    for (var i = 0; i < (options.concurrency || 4); i++){
        const worker = new Worker(options.src);
        worker.working = false;
        pool.push(worker);
    }

    // execute the next item of work
    const processQueue = function(){
        // remove cancelled work items
        queue = queue.filter(work => !work.cancel);
        if (!queue.length) return;
        const nextWorker = pool.filter(x => !x.working)[0]
        if (!nextWorker) return;

        var work = queue.pop();
        
        nextWorker.working = true;
        nextWorker.onmessage = function(e){
            nextWorker.working = false;
            if (work.cancel) return; // don't bother to notify if cancelled
            work.cb(e);
            processQueue();
        }
        nextWorker.postMessage(work.item);
    }

    return {
        push : function(item, cb){
            const work = {item:item, cb:cb, cancel:false};
            queue.push(work);
            processQueue();
            return () => work.cancel = true; // return a cancellation function
        }
    };
}
{% endhighlight %}

When a tile is removed, the TileLayer gets notified ysing the 'tileunloaded' event.

We can then listen for this event, and call the cancellation function.

{% highlight js %}
L.TileLayer.Mandlebrot = L.TileLayer.extend({
    initialize:function(){
        // call cancel on the tile when it's unloaded
        this.on('tileunload', e => e.tile.cancel()); // call cancel
    },
    setType:function(value){
        this._type = value;
    },
    getAttribution: function() {
        return "<a href='https://github.com/richorama/frac-js'>frac-js</a>"
    },
    createTile:function(coords, done){
        const tile = document.createElement('img');
        L.DomEvent.on(tile, 'load', L.Util.bind(this._tileOnLoad, this, done, tile));
        L.DomEvent.on(tile, 'error', L.Util.bind(this._tileOnError, this, done, tile));
        tile.setAttribute('role', 'presentation');

        // tile.cancel will cancel the item in the workPool
        tile.cancel = workPool.push({coords:coords, id:tile.id}, (e) => {
            const canvas = document.createElement("canvas");
            canvas.height = canvas.width = options.tileSize;

            const ctx = canvas.getContext("2d");
            ctx.putImageData(event.data.imageData, 0, 0);

            tile.src = canvas.toDataURL();
        });
        return tile;
    }
});
{% endhighlight %}


## Future thoughts

I can't see any further big wins in JavaScript, but I'm curious to see if switching to web assembly could yield a performance boost. Compiled code might be able to perform the fractal calculations quicker than the JavaScript, although there will be a price for interop.

## Access the Code

You can [view the app](https://richorama.github.io/frac-js/) and [source code](https://github.com/richorama/frac-js).