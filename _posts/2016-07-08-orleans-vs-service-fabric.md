---
layout:     post
title:      Comparing Microsoft Orleans and Azure Service Fabric Actors
date:       2016-07-08 09:00:00
summary:    Never has there been such a good time for C# developers wanting to develop software based on Virtual Actors. At the moment there are two systems available, Orleans and Service Fabric Actors.
---

## Introduction

Never has there been such a good time for C# developers wanting to develop software based on [Virtual Actors](http://dotnet.github.io/orleans/Introduction).

At the moment there are two systems available, [Orleans](https://github.com/dotnet/orleans) and [Service Fabric Reliable Actors](https://azure.microsoft.com/en-gb/documentation/articles/service-fabric-reliable-actors-introduction/).

Other actor frameworks are available of course. On the JVM there is [Orbit](https://github.com/orbit/orbit), a Virtual Actor implementation,
and [Akka](http://akka.io/) with more traditional actors.

In .NET there is also [Akka.NET](http://getakka.net/), a port of the JVM project.

And of course there's [Erlang](https://www.erlang.org/).

I'm concentrating on comparing the virtual actor feature of Service Fabric and Orleans, because attempting to compare anything else
wouldn't be fair. Akka.NET, for example, is an implementation of the Actor framework, but has a different design to the 'Virtual Actor'
concept.

Please note that Service Fabric is a more broad offering than Orleans. It offers replicated storage and service hosting (for example),
with the actors being just one aspect. I'm limiting my comparison between the actor implementations, and not a full feature comparison.

Please also note that in Orleans, Actors are called 'grains'.

## The Comparison

The two implementations are very similar, and share more in common than there are differences.

This table focuses on where there are variations.

<style>
tr:nth-child(even) {
    background-color: whitesmoke;
}
</style>

<table style="font-size:18px" cellpadding="8">
    <tr>
        <th width="20%"></th>
        <th width="40%">Orleans</th>
        <th width="40%">Service Fabric</th>
    </tr>
    <tr>
        <th>Source Code</th>
        <td>Open Source</td>
        <td>Closed Source</td>
    </tr>    

    <tr>
        <th>Partition Tolerance (CAP)</th>
        <td>AP - During a network partition Orleans will maintain availability, this may result in some duplicate grain activations which are removed when the network heals. CP can be achieved on a call-by-call basis by deferring to the storage tier.</td>
        <td>CP - During a network partition or node failure, if a consensus cannot be reached between nodes, actors may fail to activate and persist state.
        </td>
    </tr>

    <tr>
        <th>Actor Placement</th>
        <td>
            Orleans uses a distributed hash table to record actor placement.
            It provides several placement strategies, including 'prefer local' and 'random'.
        </td>
        <td>
            Service Fabric uses a deterministic hash of the actor identity to place actors in a partition.
            Partitions are distributed across the nodes in the cluster.
        </td>
    </tr>

    <tr>
        <th>Actor Identity</th>
        <td>Guid, string or long, as well as compound keys (guid + string, long + string), as well as identifying different concrete class implementations.</td>
        <td>Guid, string or long.</td>
    </tr>

    <tr>
        <th>Message Serialization</th>
        <td>Custom binary serializer.</td>
        <td>Data contract serializer.</td>
    </tr>

    <tr>
        <th>Persisting State</th>
        <td>A grain can use a POCO class to serialize state to an underling provider model. Providers include table storage, blob storage and SQL</td>
        <td>An actor has a state dictionary, keys can be loaded and persisted as required. Values must be annotated with the Data Contract serialization attributes. State is stored in local replicated storage. A provider model allows persistence in alternative stores.</td>
    </tr>

    <tr>
        <th>Pub/Sub Messaging</th>
        <td>Grain observers allow pub sub messaging between actors and actors, and actors and clients.</td>
        <td>Actor events allow pub sub messaging between actors and clients.</td>
    </tr>

    <tr>
        <th>Streaming</th>
        <td>Streaming between actors or between actors and clients. Different underlying stream providers can provide different semantics.</td>
        <td>None</td>
    </tr>

    <tr>
        <th>Cluster Membership</th>
        <td>Membership is outsourced using a provider model. Providers include table storage, SQL, Consul and Zoo Keeper.</td>
        <td>Service Fabric provides it's own cluster membership using a replicated log.</td>
    </tr>

    <tr>
        <th>Stateless Workers</th>
        <td>Stateless Worker grains can have multiple activations to handle high workloads. Activations are always local
        to the calling grain.</td>
        <td>None</td>
    </tr>


    <tr>
        <th>Controlling Actor Lifecycle</th>
        <td>Grains can request to defer deactivation, or request immediate deactivation.</td>
        <td>An actor can be deleted by a client.</td>
    </tr>

    <tr>
        <th>Reentrancy</th>
        <td>Grains are not reentrant by default.</td>
        <td>Actors are reentrant by default.</td>
    </tr>

    <tr>
        <th>Hosting</th>
        <td>Orleans is a library which can be hosted by any .NET 4.5.1 process, including on-premesis, Worker Roles in Azure and Service Fabric! It also comes with a host executable to run directly on Windows.</td>
        <td>Service Fabric can run in a local dev environment or in Azure.</td>
    </tr>

</table>

Features such as Timers, Reminders and Interceptors have no significant difference.
