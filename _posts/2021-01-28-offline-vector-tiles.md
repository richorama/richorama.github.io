---
layout: post
title: Offline maps with vector tiles
date: 2021-01-28 09:00:00
summary: On a recent project we wanted to have high quality mapping, but completely offline.
---

<img src="/images/osm-canberra.png" style="width: 100%" />

On a recent project we wanted to have high quality mapping, but completely offline.

Most map providers are online-only, and some permit temporary download as a cache.

In my case the whole dataset needed to be downloaded in advance, as the device I'm working
with will not be connected to the internet.

I decided on the [map tiler](https://data.maptiler.com/downloads/planet/) datasets,
they provide various extracts of open street map, as vector tiles, and satellite imagery as well.

The data provided as a single 'mbtiles' file. This is actually a SQLite database, containing
vector or raster tiles of your selected region, and also a high level layer of the entire world.

Map tiler provide [instructions](https://www.maptiler.com/news/2018/04/maps-with-docker/) and
a [docker image](https://hub.docker.com/r/klokantech/openmaptiles-server/) for serving the tiles.
This will convert the vector tiles into PNG raster images.

I didn't want to go with this solution, my hardware is highly constrained (a Raspberry Pi) so
serving raw vector tiles and rendering them in the browser on-the-fly is preferable. It also
provides a better user experience.

Whilst I say I'm offline, to clarify this is a web application (browser application and web
node.js web server) which is not connected to the internet.

# Serving MBTiles

I have a node.js TypeScript application running on my device already. So the first task
is to provide an endpoint that will serve vector tiles with express.

The [@mapbox/mbtiles](https://www.npmjs.com/package/@mapbox/mbtiles) package will open the
mbtiles file and retrieve the vector tiles. So this just needs connecting to the http request.

I wrote a simple module which wraps `@mapbox/mbtiles`. It open the mbtiles file and returns a function
to retrieve a tile using promises:

{% highlight ts %}
import MBTiles from '@mapbox/mbtiles'

export interface ITileGetter {
  getTile: (
    x: number,
    y: number,
    z: number
  ) => Promise<{ headers: any; data: Buffer }>
}

const openVectorTiles = (file: string) => {
  return new Promise<ITileGetter>((resolve, reject) => {
    new MBTiles(`${file}?mode=ro`, (err, tiles) => {
      if (err) return reject(err)

      const getTile = (
        x: number,
        y: number,
        z: number
      ): Promise<{ headers: any; data: Buffer }> => {
        return new Promise((resolveTile, rejectTile) => {
          tiles.getTile(z, x, y, (err, data, headers) => {
            if (err) return rejectTile(err)
            return resolveTile({
              data,
              headers
            })
          })
        })
      }

      resolve({ getTile })
    })
  })
}

export default openVectorTiles
{% endhighlight %}

You can then connect this to express like so:

{% highlight ts %}
import openVectorTiles, { ITileGetter } from './tiles/index'

// you should wait until you open this file before opening the http port
const vectorTiles = await openVectorTiles('./vector-tiles.mbtiles')

// express initialisation omitted

app.get('/tile/:z/:x/:y', async (req, res) => {
  try {
    const { data, headers } = await vectorTiles.getTile(
      parseInt(req.params.x),
      parseInt(req.params.y),
      parseInt(req.params.z)
    )
    Object.keys(headers).forEach(key => res.setHeader(key, headers[key]))
    res.send(data)
  } catch (err) {
    res.status(404).send()
  }
})
{% endhighlight %}

Note that an error is thrown when a tile doesn't exist, which is why we return a 404 in this case.

This code will serve any kind of mbtiles file, regardless of whether it contains raster
or vector tiles.

# Rendering Raster Tiles

<img src="/images/raster.png" style="width: 100%" />

Rendering the raster tiles on a web page using [OpenLayers](https://openlayers.org/) is simple,
just a matter of registering a `Tile` layer which points to our express endpoint.

{% highlight ts %}
import Map from 'ol/Map'
import TileLayer from 'ol/layer/Tile'

const layer = new TileLayer({
  source: new XYZ({
    url: '/tile/{z}/{x}/{y}'
  })
})

const map = new Map({
  target: 'map', // this points to a <div id="map"/> element
  layers: [ layer ],
  view: new ol.View()
});
{% endhighlight %}


# Rendering Vector Tiles

Vector tiles require some hackery. Vector tiles contain just vector data, so they need to be
rendered in the browser. OpenLayers can do this rendering, but it needs configuration to tell
it how different features in the vector tile should be drawn. i.e. what colours, line thicknesses,
fills etc... should be used.

This is taken care of in the [ol-mapbox-style package](https://www.npmjs.com/package/ol-mapbox-style).
This package gives you a function which will return you a map, preconfigured with your vector layer
added with the correct styling set up. The documentation offers an alternative to this where it
provides just a styling function, but I couldn't get this to work.

So our map is now initialised like this:

{% highlight ts %}
import Map from 'ol/Map'
import olms from 'ol-mapbox-style'

olms('map', `/styles.json`)
  .then((map: Map) => {
    // you get your map instance here
  })
{% endhighlight %}

The `styles.json` file is loaded at runtime, and contains the styling information for the map.
Several versions of these file can be downloaded from the map tiler website (once you have an account)
but I couldn't get these to work.

I figured out the files I needed from reverse engineering one of the example maps. I'll save
you this inconvencience with this zip file, which contains the styles.json file for the 'bright'
map scheme, and the associated assets.

[styles.zip](/files/styles.zip)

# Summary

Offline mapping is not a mainstream usecase, but it can be done. Raster maps stored in an
mbtiles file is a convenient way to serve and render maps. Using vector tiles rendered in the
browser requires a bit more hackery, and I hope better support will one day be provided in
OpenLayers to make this easier.
