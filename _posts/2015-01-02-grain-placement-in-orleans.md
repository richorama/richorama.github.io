---
layout:     post
title:      Grain placement in Orleans
date:       2015-01-02 13:15:00
summary:    It is possible to change this behavior by adding an attribute from the `Orleans.Placement` namespace to the Grain interface.
categories: blog
---

The default grain placement behavior in Orleans is to activate grains on a random silo in the cluster.

However, it is possible to change this behavior on a grain-type basis, by adding an attribute from the `Orleans.Placement` namespace to the Grain interface.

{% highlight c# %}
using Orleans.Placement;

namespace MyGrainInterfaces
{
    // you should probably just choose one of these!
    [LoadAwarePlacement]
    [LocalPlacement]
    [PreferLocalPlacement]
    [RandomPlacement]
    public interface IGrain1 : IGrain
    {

    }
}
{% endhighlight %}

Taken from the `Orleans.XML` file:

### RandomPlacement

Placement strategy that indicates that new activations of this grain type should be placed randomly, subject to the overall placement policy.

### LocalPlacement

Use a local activation, create if not present.

_You can choose a max/min number of activations for this grain._

_It looks like using this placement will give you stateless worker behavior, and you'll potentially get multiple activations of the grain in every silo._ 

### PreferLocalPlacement

Placement strategy that indicates that new activations of this grain type should be placed on a local silo.

_Presumably this only comes into affect when a grain is activated from another grain?_

### LoadAwarePlacement

Placement strategy that indicates that new activations of this grain type should be placed subject to the current load distribution across the deployment. This placement that takes into account CPU/Memory/ActivationCount.

## Observations

After a quick look at the source code, it looks like the `[StatelessWorker]` attribute will override any placement attribute, which makes sense.

Interestingly, there is an another placement attribute (`GraphPartitionPlacement`) which is marked as internal. The summary says it uses a graph partitioning algorithm.

I'm curious that the attribute is applied to the grain interface, and not the grain implementation, as it feels like more of an implementation detail. However, I expect the calling code needs the information.

## So which should you use?

* If you have grains with an affinity to each other, it would make sense to use `[PreferLocalPlacement]`. Thereby limiting the network hops between them when they're sending messages to each other.
* If you're scaling up/down, or you have isolated grains which don't talk to each other, `[LoadAwarePlacement]` would make sense.
* If you want to control the number of stateless workers you have in each silo, use `[LocalPlacement]`.
* If you don't know, you might as well stick with random!