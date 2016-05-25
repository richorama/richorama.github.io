---
layout:     post
title:      Orleans Hello World - 2016 Edition
date:       2016-05-19 09:00:00
summary:    XXXX
---

## Creating the grains

First of all, open Visual Studio and create a class library which will host our grains. You can now put grain
interfaces and implementations side-by-side in the same assembly, so let's do that.

Orleans is now delivered by a number of nuget packages, so let's install them:

{% highlight text %}
PM> Install-Package Microsoft.Orleans.OrleansCodeGenerator.Build
{% endhighlight %}

We can now create an interface for our like, like this:

{% highlight c# %}
using Orleans;
using System.Threading.Tasks;

namespace TestGrains
{
    public interface IHelloWorldGrain : IGrainWithIntegerKey
    {
        Task<string> SayHello(string name);
    }
}
{% endhighlight %}

...and add an implementation:

{% highlight c# %}
using Orleans;
using System.Threading.Tasks;

namespace TestGrains
{
    public class HelloWorldGrain : IHelloWorldGrain
    {
        public Task<string> SayHello(string name)
        {
            return Task.FromResult($"hello {name}");
        }
    }
}
{% endhighlight %}

That's the grains, now let's create some calling code.

## Creating the client

Let's create a simple command line executable to act as a client.

Once added to the solution, add the client nuget packages:

{% highlight text %}
PM> Install-Package Microsoft.Orleans.Client
{% endhighlight %}
