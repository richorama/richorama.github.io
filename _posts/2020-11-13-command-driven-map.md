---
layout: post
title: Command Driven Map
date: 2020-11-13 09:00:00
summary: I have found an approach that works well when building web based map applications in React.js. I've found in the past that map components can get very complicated very quickly, making it difficult to add new features to the map control.
---

## Summary

In a [previous post](/2020/08/14/event-driven-map/) I discussed a pattern for implementing maps in React based
web applications. This post expands on this, presenting a complementary approach using the
[command pattern](https://en.wikipedia.org/wiki/Command_pattern).

The basic problem is that the state driven approach of React.js is at odds with API approach of web map components.

Using the command pattern allows encapsulation of the logic to drive the map making the map component itself very simple.

## Implementation

> All samples are provided in React.js using Typescript with the OpenLayers map control.

I have found an approach that works well when building web based map applications in React.js. I've found in the past
that map components can get very complicated very quickly making it difficult to add new features to the map control.

This solution is based around the command pattern, where operations performed on the map are encapsulated in
classes. These classes have a common interface which requires a single 'execute' method:

{% highlight js %}
// command.ts
import Map from 'ol/Map'

export interface IContext {
  map: Map
}

export interface ICommand {
  execute: (context: IContext) => void
}
{% endhighlight %}

> I initially used 'context' as I thought I would have to attach additional map objects (such as views and layers) for commands to use, but I found in practice this wasn't necessary. I kept it for clarity.

This allows us to have a very simple map component which accepts an array of commands as props
which are executed in turn.

{% highlight js %}
// map.tsx
import React, { createRef } from 'react'
import 'ol/ol.css'
import Map from 'ol/Map'
import View from 'ol/View'
import { ICommand } from './command'

export default class MapComponent extends React.Component<{ commands?: ICommand[] }> {
  divRef = createRef<HTMLDivElement>()

  componentDidMount() {
    if (!this.divRef.current) return

    const map = new Map({
      target: this.divRef.current,
      view: new View({
        center: [0, 0],
        zoom: 2
      })
    })

    const context = { map }

    // the commands are executed here
    this.props.commands?.forEach(x => x.execute(context))
  }

  shouldComponentUpdate() {
    return false
  }

  render() {
    return <div ref={this.divRef} style={{ width: '100%', height: '100vh' }} />
  }
}
{% endhighlight %}

So what does a command do and what does it look like? 

Well a command can contain any operation that you may wish to perform on the map. Let's take adjusting the 
zoom level as an initial example:

{% highlight js %}
// zoom-command.ts
import { IContext, ICommand } from './command'

export default class ZoomCommand implements ICommand {
  private map?: Map

  execute(context: IContext) {
    this.map = context.map
  }

  zoom(delta: number) {
    this.map.getView().adjustZoom(delta)
  }
}
{% endhighlight %}

In this case when the map component calls 'execute' the command keeps a reference to the map object. The command
exposes a 'zoom' method which will then adjust the zoom level on the map accordingly.

This is a simple example, how about something more interesting?

This example will add features to the map:

{% highlight js %}
// display-features-command.ts
import Feature from 'ol/Feature'
import VectorLayer from 'ol/layer/Vector'
import VectorSource from 'ol/source/Vector'
import { IContext, ICommand } from './command'
import { Circle, Fill, Style } from 'ol/style'

export default class DisplayFeaturesCommand implements ICommand {
  features: Feature[]
  
  constructor(features: Feature[]) {
    this.features = features
  }

  execute(context: IContext) {

    const vectorLayer = new VectorLayer({
      source: new VectorSource({ features: this.features }),
      style: feature =>
        new Style({
          image: new Circle({
            radius: 20,
            fill: new Fill({ color: 'red' })
          })
        })
    })

    context.map.addLayer(vectorLayer)
  }
}
{% endhighlight %}

One final example which is to respond to map clicks and call a function back when a feature is selected:

{% highlight js %}
// select-feature-command.ts
import { FeatureLike } from 'ol/Feature'
import { IContext, ICommand } from './command'

export default class SelectFeatureCommand implements ICommand {
  onClick: (feature: FeatureLike) => void

  constructor(onClick: (feature: FeatureLike) => void) {
    this.onClick = onClick
  }

  execute(context: IContext) {
    context.map.on('click', e => {
      const features = context.map.getFeaturesAtPixel(e.pixel)
      if (features[0]) this.onClick(features[0])
    })
  }
}
{% endhighlight %}

To add the map component to the page you simply create the commands and pass them in as props:

{% highlight js %}
  
  ...

  this.zoomCommand = new ZoomCommand()

  handleZoom = (delta: number) => {
    this.zoomCommand.zoom(delta)
  }

  render() {
    return <Map
      commands={[
        this.zoomCommand,
      ]}
    />
  }

  ...
  
{% endhighlight %}

Methods to manipulate the map can be coupled to a pub/sub system as mentioned in my
[previous blog post](/2020/08/14/event-driven-map/).

## Conclusion

The command pattern seems to be a nice way to reduce the complexity of implementing maps components in web
applications.

I have used this approach on a couple of recent projects with some complicated interactions such as drawing geofences,
adding/removing tile layers, and display additional controls on the map. Everything I have tried seems to have worked out easily, which is a good confirmation that the pattern is well
suited to this task.

I particularly like the encapsulation of all the boiler plate that open layers requires when dealing with the map and exposes
higher order 'business' functions which are reusable between different parts of your application, or different applications.

Perhaps a library of these commands could be built to accelerate map projects.