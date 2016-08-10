---
layout:     post
title:      Benchmarking the Image Interpolation in .NET
date:       2016-08-10 09:00:00
summary:    I am attempting to improve the performance of image resizing in C#.
---

I am attempting to improve the performance of image resizing in C#. [This StackOverflow](http://stackoverflow.com/a/11025428/349014) answer provided some excellent pointers for improving performance.

I found these tips make a difference:

* Set pixel format to `PixelFormat.Format32bppPArgb` when creating a Bitmap.
* Set `Graphics.CompositingMode` to `CompositingMode.SourceCopy`.
* Set `Graphics.InterpolationMode` to `InterpolationMode.NearestNeighbor`.

However, the last piece of advice reduces the quality when resizing. This is particularly bad when creating thumbnails.

So how do the different interpolation modes compare against each other in performance?

![](/images/interpolation-compared.png)

(lower is better)

But how do they compare in image quality? I have scaled an image to 10% of it's original size using each technique (slowest first).

__Low__

![](/images/Low.png)

__Bilinear__

![](/images/Bilinear.png)

__Bicubic__

![](/images/Bilinear.png)

__HighQualityBilinear__

![](/images/HighQualityBilinear.png)

__HighQualityBicubic__

![](/images/HighQualityBilinear.png)

__High__

![](/images/High.png)

__NearestNeighbor__

![](/images/NearestNeighbor.png)
