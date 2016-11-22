---
layout:     post
title:      The rise of the Virtual Actor
date:       2016-11-22 09:00:00
summary:    Pioneered in 2008 by the Extreme Computing Group in Microsoft Research with the Orleans framework, the Virtual Actor concept is
starting to spread to other ecosystems.
---

Pioneered in 2008 by the Extreme Computing Group in Microsoft Research with the Orleans framework, the Virtual Actor concept is
starting to spread to other ecosystems.

Let's quickly examine what's on the open source marker.

## Orleans

[https://github.com/dotnet/orleans](https://github.com/dotnet/orleans)

Originally from Microsoft Research, Orleans was open sourced in 2014 and joined the .NET Foundation.
Best known for supporting the Halo 4 & 5 games, Orleans' users range from Skype to Visa.

{% highlight c# %}
// example actor interface
public interface IHello : Orleans.IGrainWithIntegerKey
{
  Task<string> SayHello(string greeting);
}

// example actor implementation
public class HelloGrain : Orleans.Grain, IHello
{
  Task<string> SayHello(string greeting)
  {
    return Task.FromResult($"You said: '{greeting}', I say: Hello!");
  }
}

// call the actor
var friend = GrainClient.GrainFactory.GetGrain<IHello>(0);
await friend.SayHello("Good morning, my friend!");
{% endhighlight %}

## Service Fabric

[https://azure.microsoft.com/en-gb/services/service-fabric/](https://azure.microsoft.com/en-gb/services/service-fabric/)

Service Fabric implments actors in a very similar way to Orleans -[see this post for a comparison](/2016/07/08/orleans-vs-service-fabric/).
It supports actors written in both C# and Java.


{% highlight c# %}
// example actor interface
public interface IHello : IActor
{
  Task<string> SayHello(string greeting);
}

// example actor implementation
public class HelloActor : Actor, IHello
{
  public MyActor(ActorService actorService, ActorId actorId)
    : base(actorService, actorId) { }

  Task<string> SayHello(string greeting)
  {
    return Task.FromResult($"You said: '{greeting}', I say: Hello!");
  }
}

// register the actor            
ActorRuntime.RegisterActorAsync<HelloActor>((context, actorType) => new ActorService(context, actorType, () => new HelloActor())).GetAwaiter().GetResult();

// call the actor
var friend = ActorProxy.Create<IHello>(0, new Uri("fabric:/MyApp/MyActorService"));
await friend.SayHello("Good morning, my friend!");
{% endhighlight %}

## Orbit

[https://github.com/orbit/orbit](https://github.com/orbit/orbit)

{% highlight java %}
// example actor interface
public interface Hello extends Actor
{
    Task<String> sayHello(String greeting);
}

// example actor implementation
public class HelloActor extends AbstractActor implements Hello
{
    public Task<String> sayHello(String greeting)
    {
        return Task.fromValue(You said " + greeting + ", I say: Hello!");
    }
}

// call the actor
Actor.getReference(Hello.class, "0").sayHello("Good morning, my friend!");
{% endhighlight %}

## GAM

[https://github.com/AsynkronIT/gam](https://github.com/AsynkronIT/gam)

## Wraith.io

[https://github.com/JoeHegarty/wraith.io](https://github.com/JoeHegarty/wraith.io)
