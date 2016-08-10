---
layout:     post
title:      Benchmarking Image Interpolation in .NET
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

## Conclusion

It seems to me that the sweet spot is anything starting with 'High'. These seem to have a good enough quality, and an acceptable performance. The `NearestNeighbor` is really ugly, but if you want pure performance, or you're not making a big difference to the scale, you might get away with it.

## Image scaling source code

{% highlight c# %}
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

class Program
{
    static void Main(string[] args)
    {
        Thumbnail(InterpolationMode.NearestNeighbor);
        Thumbnail(InterpolationMode.Bicubic);
        Thumbnail(InterpolationMode.Bilinear);
        Thumbnail(InterpolationMode.High);
        Thumbnail(InterpolationMode.HighQualityBicubic);
        Thumbnail(InterpolationMode.HighQualityBilinear);
        Thumbnail(InterpolationMode.Low);
    }

    private static void Thumbnail(InterpolationMode interpolationMode)
    {
        using (var source = Bitmap.FromFile(@"C:\Users\Richard\Desktop\Windows10-wallpaper-img100.jpg"))
        using (var target = new Bitmap(384, 286, PixelFormat.Format32bppPArgb))
        using (var graphics = Graphics.FromImage(target))
        {
            graphics.CompositingMode = CompositingMode.SourceCopy;
            graphics.CompositingQuality = CompositingQuality.HighSpeed;
            graphics.InterpolationMode = interpolationMode;

            graphics.DrawImage(source,
                new Rectangle(0, 0, target.Width, target.Height),
                new Rectangle(0, 0, source.Width, source.Height),
                GraphicsUnit.Pixel);

            target.Save($"{interpolationMode}.png", ImageFormat.Png);
        }
    }
}
{% endhighlight %}
