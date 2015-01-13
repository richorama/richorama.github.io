---
layout:     post
title:      Thoughts on Deploying Orleans
date:       2015-01-13 13:02:00
summary:    A post discussing a future possibility for deploying Orleans to Azure 
---

Yesterday we had a very interesting and productive Orleans meetup, which included the Orleans product team (Sergey and Gabriel) as well as Hoop from 343 Industries. I suggest you [watch the recording](https://www.youtube.com/watch?v=D4kJKSFfNjI) if you're interested in the future of Orleans.

On the call Sergey mentioned that he would like to make the deployment of Orleans easier. Here are my thoughts.

## Azure SDK Plugins

The Azure SDK has a little known feature, which allows you to 'plug' extra features into your Cloud Services package. 

The Azure SDK uses these plugins to provide Diagnostics, Caching and Remote Desktop etc...

As a side note, the [Azure Plugin Library](http://richorama.github.io/AzurePluginLibrary/) capitalises on this capability to provide a wide range of plugins you can use to bootstrap your Azure Cloud Service Deployments (such as installing nginx, chocolatey, redis ...).

## How could an Orleans plugin work?

A plugin could delivery the binaries and configuration, and start the Orleans Silo on a Web or Worker Role.

Your Web/Worker Role code would contain the Grain Interface and Collection assemblies, and the plugin would do the work of starting the Silo correctly.

## How is the plugin installed?

Plugins are located in a well known directory on the developer's machine, i.e. for the v2.4 of the SDK, this path is used:

{% highlight text %}
C:\Program Files\Microsoft SDKs\Azure\.NET SDK\v2.4\bin\plugins
{% endhighlight %}

This path can be looked up using the registry:

{% highlight text %}
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\ServiceHosting\v2.4
{% endhighlight %}

There are a few options for delivering the plugin to the developer's machine:

1. Install as part of the Azure SDK
1. Install as a stand-alone MSI
1. Install as part of the Orleans SDK [`my preference`]
1. Install using the [Azure Plugin Library](http://richorama.github.io/AzurePluginLibrary/)

## What would the plugin look like?

The plugin itself would contain the Orleans runtime binaries.

It would also contain an `Orleans.csplugin` file which would look something like this:

{% highlight xml %}
<?xml version="1.0" ?>
<RoleModule 
  xmlns="http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceDefinition"
  namespace="Microsoft.Orleans">
  <Startup priority="-1">
    <Task commandLine="OrleansHost.exe" taskType="background" />
  </Startup>
  <ConfigurationSettings>
    <Setting name="DataConnectionString" />  
  </ConfigurationSettings>
  <LocalResources>
    <LocalStorage name="LocalStoreDirectory" cleanOnRoleRecycle="false" />
  </LocalResources>  
  <Endpoints>
    <InternalEndpoint name="OrleansSiloEndpoint" protocol="tcp" port="11111" />
    <InternalEndpoint name="OrleansProxyEndpoint" protocol="tcp" port="30000" />
  </Endpoints>
  <Certificates>
  </Certificates>
</RoleModule>
{% endhighlight %}

Note that the plugin configuration takes care of the internal endpoints (ports), the local storage, declares that a setting must be supplied, and can start a background task (i.e. start the silo). This takes all of these requirements away from the developer.

The plugin does not include the grains. They live in the Visual Studio solution, and are packaged up along with the plugin at deployment time. The plugin discovers the grains on activation in Azure.

## Developer experience

Once installed on the developer's machine, consuming the plugin is simple.

* Create a Cloud Project as normal, with a Worker Role containing references to the grain interfaces and classes.
* Add `Orleans` as an import in the `ServiceDefinition.csdef` file (this tells cspack to include the plugin in the package):

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<ServiceDefinition name="MyWorkerRole" 
	xmlns="http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceDefinition" 
	schemaVersion="2014-06.2.4">
  <WorkerRole name="MyWorkerRole" vmsize="Medium">
    <Imports>
      <Import moduleName="Orleans" />
    </Imports>
  </WorkerRole>
</ServiceDefinition>
{% endhighlight %}

* Visual Studio then automatically creates a setting in the `ServiceConfiguration.*.cscfg` files called `Microsoft.Orleans.DataConnectionString`. The developer uses the Visual Studio GUI to pick the storage connection string.
* Add a `OrleansConfiguration.xml` file to the Worker Role project.
* Publish.

## Problems

1. When defining settings in the plugin, they appear as settings in Visual Studio prefixed with the plugin namespace. So in our case the `DataConnectionString` would become `Microsoft.Orleans.DataConnectionString`. Orleans would not recognise the setting, and the silo would fail to start. Some extra logic would be required in Orleans to look for two different settings names.
1. On the VM, the plugin would be installed in `e:\plugins\Orleans\`, so the Silo would have to scan the `e:\approot\` directory (or `e:\approot\bin\` for a Web Role) to get the grain libraries and the `OrleansConfiguration.XML` file. This would require some extra logic to scan additional paths on startup. (note that the `e:` drive could also be `f:`)

## Benefits

1. Low friction for the developer.
1. A plugin has affinity with an SDK version, making DLL versioning easier?
1. A plugin could be used in conjunction with a Visual Studio template, which could be used to further enhance the developer experience (by automatically including the plugin, and providing a default `OrleansConfiguration.XML` file).

---

## Update

After a twitter exchange with Sergey, I have made some small adjustments to the article. 

* The `OrleansConfiguration.XML` file must be supplied by the developer.
* A Visual Studio template could further improve the development experience (perhaps this is a better option in the first place?)