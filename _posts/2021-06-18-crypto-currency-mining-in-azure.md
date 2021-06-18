---
layout: post
title: Cryptocurrency Mining in Azure
date: 2021-06-18 09:00:00
summary: I thought I would try my hand at mining crypto in the cloud. After all, who wouldn't want to be a bitcoin billionaire?
---

![Tesla M60](/images/tesla-m60.png)

# TL;DR

Don't bother.

# Hardware Selection

I thought I would try my hand at mining crypto in the cloud. After all, who wouldn't want to be
a bitcoin billionaire?

There are a few VM options in Azure which have GPUs installed, I tried 

* Standard NV6 (6 vcpus, 56 GiB memory) - £783.47 /month
* Standard NC6 (6 vcpus, 56 GiB memory) - £365.62 /month (promotion)

It turns out the NC6 is an older model and uses the NVIDIA Tesla K80, and many of the crypto algorithms no longer support it. If you're looking for optimal mining we'd better go with the latest...

The NV6 has an NVIDIA Tesla M60 installed, which the algorithms seemed quite happy with.

For anyone interested in the benchmarks:

{% highlight text %}
DaggerHashimoto ETH - 2.63 MH/s
DaggerHashimoto EXP - 9.01 MH/s
RandomX (CPU) - 2305.57 H/s
RandomX - 284.32 H/s
KawPow - 3.78 MH/s
BeamHashIII - 6.90 H/s
Ubqhash - 17.80 MH/s
{% endhighlight %}

# OS Selection

I went with Windows 10 Preview. I didn't want any of that Windows Server security lockdown
getting in the way of my money making hackery.

# Software Installation

1. Install the NVIDIA driver, from the [NVIDIA website](https://www.nvidia.com/Download/index.aspx).
1. I went for the [Kryptex Miner](https://www.kryptex.org/en/). It was extremely easy to use.
1. I ran the benchmarks on Kryptex, and I was away.

# Revenue

The next step was to sit back and what the money roll in. Fortunately the software
provides you with an idea of your expected earnings.

![Tesla M60](/images/crypto-earnings.png)

Oh dear.

That's £13.00 /month.

We're losing £770.47 /month, or a -5926% profit margin.

# Energy

Microsoft is a [carbon neutral company](https://azure.microsoft.com/en-gb/global-infrastructure/sustainability/) but we're still burning unnecessary energy.

The Kryptex software reports that the GPU uses 100W or power, I can't get a precise
figure for the CPU consumption, so let's say that's around the same, totally 200W.

The PUE (Power Usage Effectiveness) for Azure, which is a measure of the energy efficiency
of the data centre is 1.125, so multiplying 200W by 1.125 gives us 225W of energy required
to power the server.

That's 162 kWh /month.

The average cost of electricity in the UK in 2020 was 17.2p/kWh.

That's an electricity bill of £27.86 /month.

I'm sure Microsoft pay less for their electricity, but it looks like mining can't even
pay for it's own power.

# How do the pros do it?

Crypto is only profitably mined in countries with low power costs, using [custom hardware](https://www.buybitcoinworldwide.com/mining/hardware/).

Interestingly, Microsoft have [experimented with 
ASIC hardware](https://azure.microsoft.com/en-gb/blog/improved-cloud-service-performance-through-asic-acceleration/), to improve compression performance in their storage systems. There's no
option to use these machines directly at the moment though.

# Conclusion

It's not financially viable to mine crypto in the cloud, don't bother.



