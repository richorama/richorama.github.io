---
layout:     post
title:      Rendering leaflet.js tiles in the browser
date:       2018-08-22 09:00:00
summary:    TODO
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
convert the canvase to a data url, and set the tile src to that.

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

This technique worked, but there was a problem. The fractal calculation is CPU intensive, and it's running on the single UI thread that the browser is using to render the page. This meant that when leaflet requested tiles, the browser stopped responding to user input, and the app freezes.

## Attempt 2 - Service Worker

To improve the performance, we can stand up a Service Worker, and render the tile in a different thread, passing the image data back to the UI thread for display.

Serice workers are sepate Javascript runtime that the browser runs in the background. We can communicate with the worker using message passing. 

In the main JavaScript a redesign is required in the way the tile URL is set, as we now have to render the fractal asynchronously.

We can do this by overriding `createTile` in the TileLayer. This allows us to control the creation of the tile. An id is generated which is used to reference
the tile when the rendering is complete.

Finally it sends the message to the fractal to start the rendering.

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

The worker occupies a separate JavaScript file, it receives the message and then renders the fractal.

Workers cannot create DOM elements, therefore we cannot create a canvas, but they can create the 'ImageData' class which underpins the Canvas.

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
    canvas.width = tileSize;
    canvas.height = tileSize;

    const ctx = canvas.getContext("2d");
    ctx.putImageData(event.data.imageData, 0, 0);

    tile.src = canvas.toDataURL(); // set the source of the tile
    delete tiles[event.data.id]; // remove reference to tile
}
{% endhighlight %}

## Attempt 3 - Worker Pool

On multi-core systems, we could render tiles faster if fractal rendering was distributed across all cores, rather than just a single core which a single Service Worker will consume.

