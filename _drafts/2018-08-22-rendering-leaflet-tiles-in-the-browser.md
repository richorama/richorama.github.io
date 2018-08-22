---
layout:     post
title:      Rendering leaflet.js tiles in the browser
date:       2018-08-22 09:00:00
summary:    TODO
---

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

## Attempt 2 - 