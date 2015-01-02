---
layout:     post
title:      Bootstrap provider in Orleans
date:       2015-01-02 14:35:00
summary:    The bootstrap provider enables you to hook in some code at silo startup. There are a variety of reasons for doing this, perhaps you want to set some local grains up, or initialize some data. The Hub design pattern makes use of the bootstrap provider create a stateless worker in each Silo.
categories: blog
---

Thanks to [Yevhen Bobrov](https://twitter.com/yevhen) for pointing this out.

The default behavior of an Orleans system is to respond to external signals. Your grains are activated when required, so with no requests coming into the system, nothing happens. The bootstrap provider enables you to hook in some code at silo startup. There are a variety of reasons for doing this, perhaps you want to set some local grains up, or initialize some data. The [Hub](https://github.com/OrleansContrib/DesignPatterns/tree/master/samples/Hub) design pattern makes use of the bootstrap provider create a stateless worker in each Silo.

Creating a bootstrap provider is simple, just inherit `IBootstrapProvider` and implement the members. Put your code in `Init`, which is of course asynchronous.

{% highlight c# %}
using Orleans;
using Orleans.Providers;
using System;
using System.Threading.Tasks;

namespace GrainCollection1
{
    public class FooProvider : IBootstrapProvider
    {
        public Task Init(string name, IProviderRuntime providerRuntime, IProviderConfiguration config)
        {
            this.Name = name;
            Console.WriteLine("Hello from my provider");
            return TaskDone.Done;
        }

        public string Name { get; private set; }
    }
}

{% endhighlight %}

Then register your provider in the `BootstrapProviders` section of `OrleansConfiguration.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<OrleansConfiguration xmlns="urn:orleans">
  <Globals>
    <StorageProviders>
    	...
    </StorageProviders>
    <BootstrapProviders>
      <Provider Type="GrainCollection1.FooProvider" Name="FooProvider" />
    </BootstrapProviders>
    <SeedNode Address="localhost" Port="11111" />
    ...
  </Globals>
  ...
</OrleansConfiguration>

{% endhighlight %}

Like other providers, any additional attributes you add to the `Provider` tag will be presented in the `IProviderConfiguration` parameter on `Init`.

If your provider throws an exception, the silo will fail to start.

Simple!
