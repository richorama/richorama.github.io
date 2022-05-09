---
layout: post
title: App Modernisation
date: 2021-11-29 09:00:00
summary: ***
---

![](../images/dark-side-cloud.png)

* operational efficiency
  cost control, scalability, security

* unlock new value
 autonomy, collabotation, data sharing agility 
 
* reduce technical debt

# History

In the early days of Azure (circa 2008) the only compute option was PaaS (Platform as a Service) in the form of Web Roles and Worker Roles.

It was often a challenge to get software running in this environment, but the effort
often resulted in a system that was stateless, scalable, it might have used the native queues and blobs, and was probably connected into the health monitoring and events raised by the cloud fabric. The apps were modernised and cloud-native.

When general purpose Virtual Machines (IaaS) were later made available, many kinds of workloads that were previously hard or impossible
to deploy as PaaS could then be deployed to the cloud. This started a 'lift and shift' mindset, whereby entire data centres could just
be duplicated in a cloud environment.

This made cloud migration easy, quick and low risk.

There was less investment made in software to modernise it for PaaS environments.

The app modernisation winter had begun.

However, during this bleak time several advancements had been made in PaaS.

1. Containerisation and the rise of Kubernetes meant you could run your own PaaS on IaaS and move between clouds or support hybrid deployments.
1. Serverless computing took off with a pricing structure where you only pay for the compute resources you need, without having to think about scaling. It was an extreme PaaS.

> We are now emerging to a new dawn of application modernisation. Microsoft is investing customers wanting to modernise applications, and there are some exciting new options 

# Why Modernise?

What advantages do PaaS services have over Iaas?

__Cost Efficiency.__ PaaS services are generally more elastic than IaaS, making it easier to both scale
up during period of high demand, but also scale down during quieter times. Serverless applications can often scale down to zero. We don't want to pay for computers that are idle. We don't want to consume unnecessary energy either.

__Improved User Experience.__ The ability to rapidly scale horizontally results in a better experience for the end customer. If we can scale to meet traffic demands, we don't see so many cases where system performance degrades due to high demand. 

__Operational Efficiency.__ PaaS services provide a higher level of abstraction than IaaS. Taking away the burden and technical debt of maintaining the operating system and installing your software, PaaS service allow you to just bring your code, and ultimately focus on adding business value than server administration.

__Security.__ With the patching of the underlying compute infrastructure happening automatically, this attack vector is minimised. 

__Agility.__ A PaaS Service allows you to deploy software rapidly, reducing the time between commit and production. This allows developer to respond to new requirements, changes in the market, or fix bugs quickly. We can stand new environments up quickly to provide test infrastructure, or launch new services purely by pushing code.

# How to Modernise?


# Future PaaS

We're seeing some interesting developments in the PaaS services now on offer.

__Azure Arc.__ With services such as Azure Arc, we can run PaaS services on hybrid or multi-cloud scenarios. This allows us to provide developers with many of the advantages of PaaS, and a unified monitoring and management plane for workloads that must remain on-prem.

__Container Apps.__ Takes the 



