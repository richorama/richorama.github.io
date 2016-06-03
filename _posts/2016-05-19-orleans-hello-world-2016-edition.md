---
layout:     post
title:      Orleans Hello World - 2016 Edition
date:       2016-05-19 09:00:00
summary:    Orleans has seen lots of improvements over the last year, in terms of the client APIs, the configuration and installation. So the process of getting started is now a little different. Let's walk through setting up a grain, with a silo host and client application.
---

Orleans has seen lots of improvements over the last year, in terms of the client APIs, the configuration and installation.
So the process of getting started is now a little different. Let's walk through setting up a grain, with a silo host and client application.

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
    public class HelloWorldGrain : Grain, IHelloWorldGrain
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

...then add a reference to the project containing the grains.

We can now write a client application which connects to a local silo and call the grain.

I have included some retry logic when attempting to initialise the client, so the application waits until the silo is ready.

{% highlight c# %}
using Orleans;
using Orleans.Runtime.Configuration;
using System;
using System.Threading;
using TestGrains;

class Program
{
    static void Main(string[] args)
    {
        // initialize the grain client, with some retry logic
        var initialized = false;
        while (!initialized)
        {
            try
            {
                GrainClient.Initialize(ClientConfiguration.LocalhostSilo());
                initialized = GrainClient.IsInitialized;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                Thread.Sleep(TimeSpan.FromSeconds(1));
            }
        }

        // get a reference to the grain from the grain factory
        var grain = GrainClient.GrainFactory.GetGrain<IHelloWorldGrain>(1);

        // call the grain
        var response = grain.SayHello("World").Result;

        Console.WriteLine(response);
        Console.ReadKey();
    }
}
{% endhighlight %}

Note previously the initialisation required a config file. This is being phased out in favour of programmatic onfiguration (see `ClientConfiguration.LocalhostSilo()`).

## Creating the server

There are lots of ways to host an Orleans silo, but let's write a separate console application to do that.

Create a command line application, and install the following nuget packages:

{% highlight text %}
PM> Install-Package Microsoft.Orleans.Server
PM> Install-Package Microsoft.Extensions.DependencyInjection.Abstractions -Pre
{% endhighlight %}

Note the Dependency Injection package is a pre-release, which means it can't be shipped with the Orleans nugets. This has to be installed separately.

{% highlight c# %}
using Orleans.Runtime.Configuration;
using System;

class Program
{
    static void Main(string[] args)
    {
        using (var silo = new Orleans.Runtime.Host.SiloHost("primary", ClusterConfiguration.LocalhostPrimarySilo()))
        {
            silo.InitializeOrleansSilo();

            var result = silo.StartOrleansSilo();
            if (result)
            {
                Console.WriteLine("silo running");
                Console.ReadKey();
                return;
            }
            Console.WriteLine("could not start silo");
        }
    }
}
{% endhighlight %}

Note we're using the programmatic configuration in a similar way to the client.

Build the application, and then manually copy the DLL containing the grains into an `bin\debug\Applications\` directory.
This is one of the places the silo host will look when discovering grain assemblies.

Start both applications up, and you'll have an Orleans client talking to a server :¬)
