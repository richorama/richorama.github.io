---
layout: post
title: App Modernisation
date: 2021-11-29 09:00:00
summary: ***
---

# History

In the early days of Azure (circa 2008) there was only PaaS (Platform as a Service) in the form of Web Roles and Worker Roles.

It was often a challenge to get software running in this environment, but the work put in to get software to work in this way
often resulted in a system that was stateless, scalable, it might have used the native queues and blobs, and probably had some deployment automation from the start.
The apps were modernised and cloud-native.

When general purpose Virtual Machines (IaaS) were later made available, many kinds of workloads that were previously hard or impossible
to deploy as PaaS could then be deployed to the cloud. This started a 'lift and shift' mindset, whereby entire data centres could just
be duplicated in a cloud environment.

This made cloud migration easy, quick and low risk.

There was less invest in software to modernise it for a PaaS environments.

The app modernisation winter had begun.

However, during this time several advancements had been made in PaaS.

1. Containerisation and the rise of Kubernates means you can run PaaS on IaaS and move between clouds or support hybrid deployments.
1. Serverless computing took off with a pricing structure where you only pay for the compute resources you need, without having to think about scaling.

We are now emerging to a new dawn of application modernisation. With

