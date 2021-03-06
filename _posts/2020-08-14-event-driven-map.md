---
layout: post
title: Event Driven Map
date: 2020-08-14 09:00:00
summary: After implementing maps in react applications a few times, I have found that map components and react have have quite different, and largely incompatible abstractions.
---

## The Problem

After implementing maps in react applications a few times, I have found that map components
and react have have quite different, and largely incompatible abstractions.

A typical map control is initialised, with a DIV element it uses to render the map:

{% highlight js %}
<div id="map" />

const position = [51.505, -0.09]
const map = L.map('map').setView(position, 13)
{% endhighlight %}

You can then call methods on the map to change it's position and be notified of user interaction
such as panning and zooming:

{% highlight js %}
map.panTo(new L.LatLng(40.737, -73.923));
map.on('moveend', () => console.log('the user moved the map'))
{% endhighlight %}

There are react component that wrap up this API, and provide a component instead:

{% highlight js %}
<Map center={[51.505, -0.09]} zoom={13} />
{% endhighlight %}

There are 3rd party components that do this to varying degrees of success. I have even been
guilty of building similar components within a project to do the same thing.

At first glance this looks much easier, neater and more reacty. For a simple map this is
absolutely fine.

The problems start to occur with user interaction. If we want to manipulate the map
from code (say to zoom or pan it) we can update the props. However, the user can also manipulate
the map, so we'd need event handlers for `onZoom`, `onPan` etc... which update the state of the
parent component accordingly.

We then find ourselves duplicating the internal state of the map control as state in the react component.

There can be quite a bit of state, and this grows in complexity as we start using markers/popups,
additional layers, etc...

We also have to start writing code in the map component that looks at changes in the props to figure out
what methods to call on the map.

So we find ourselves updating state to move a map, which the map component then has to do a diff
on to figure out what method to call on the map control.

Writing lots of unnecessary code is a good sign that you're going wrong.

## The Solution

I have found a simple solution to this problem by using events instead of state. I guess they're a
lower level 'common denominator' abstraction.

Libraries such as [pubsub-js](https://www.npmjs.com/package/pubsub-js) make it easy to decouple your
application code into components that can send and subscribe to events.

In short, rather than propagating state to update the map position,
you raise a `map_move` event (or whatever you wish to call it) which a component that contains
the map control will subscribe to. It will then call the map API to adjust the map position. Likewise it
raises events when the map is moved by the user, and any component that wishes to update in response
to that event can subscribe.

This removes the need to hold the value for the map centre as state.

Likewise we can provide the same technique for zooming, adding/removing layers, displaying/hiding popups,
etc...

It means we end up with a map component that looks like this (simplified example) which doesn't
require any props:

{% highlight js %}
class MapComponent extends React.Component {

  componentDidMount() {

    // initialise the map
    const position = [51.505, -0.09]
    this.map = L.map('map').setView(position, 13)
    map.on('moveend', newPosition => PubSub.publish('map_moved', newPosition))

    // subscribe to requests to move the map
    PubSub.subscribe('move_map', this.handleMoveMap)
  }

  handleMoveMap = (_, newPosition) => {
    this.map.panTo(newPosition);
  }

  render() {
    return <div id="map" />
  }
}
{% endhighlight %}

Other components can then request the map to be moved by raising the `move_map` event:

{% highlight js %}
PubSub.publish('move_map', newPosition)
{% endhighlight %}

Likewise, they can subscribe to changes in the map:

{% highlight js %}
PubSub.subscribe('map_moved', this.handleMoveMap)
{% endhighlight %}

I have implemented a simple example application which display earthquake locations.

[Example application](https://richorama.github.io/event-driven-map/)

[Example source code](https://github.com/richorama/event-driven-map)

Enjoy!