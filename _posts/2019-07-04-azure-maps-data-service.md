---
layout: post
title: Azure Maps Data Service - First Impressions
date: 2019-07-04 09:00:00
summary: Azure Maps consists of a set of geospatial REST APIs and a JavaScript web map control. Some of the services (including the data service) are in preview.
---

[Azure Maps](https://azure.microsoft.com/en-au/services/azure-maps/) consists of
a set of geospatial REST APIs and a JavaScript web map control. Some of the
services (including the data service) are in preview.

What caught my particular interest was a
[Data Service](https://docs.microsoft.com/en-us/rest/api/maps/data) which allows
you to bring your own data in GeoJSON format, upload it, and then perform
[spatial queries](https://docs.microsoft.com/en-us/rest/api/maps/spatial) on the
data.

After a quick play with the service, there are some interesting things to note:

1. The API services are secured with an API key (similar to Azure Storage) which
   you include as part of the URL to any call to the service. You can also use
   an OAuth flow (which I haven't tried). One thing that bothers me here is that
   there isn't (as far as I can tell) a public key / private key. If you embed
   an Azure Map control on a web page you include your subscription key to
   enable it. However, anyone reading the source can then take that key and
   download/update/delete all of your data. They have full read/write permission
   to all the data in your Azure Map service.

1. The API services are CORS enabled, so you can upload/download and perform
   queries directly from the browser. Nice.

1. The Data API allows you to upload a data 'set' at a time. You can update a
   set, but you replace the entire set. You cannot update/delete a single
   feature. This means it's well suited to large 'static' sets of data, and not
   dynamic data feeds.

1. The Data API allows you to download the data set as a single JSON file, but
   you cannot page or download a subsection using a bounding box (or similar).
   The Spatial APIs do allow you to query the data by finding the features
   nearest a point, or within a buffer, but not a simple bounding box.

1. The Spatial API only returns the value of the `geometryId` property of the
   GeoJSON feature, and doesn't give you the feature object itself. This means
   you need to include a `geometryId` property on your source data if you want
   to use it with the Spatial API. It also means you need to download your
   entire dataset in advance, or have it stored elsewhere, so you can look it up
   by `geometryId`.

1. The Spatial API allows you to make queries such as 'find the nearest point'
   on data that you post up with the call. You can also calculate the distance
   between two given points. These seem like calls that should be provided by a
   library rather than an API.

1. When I uploaded invalid data (my bad) I got an error message like this, which
   didn't help me to identify the cause of the problem
   ` Upload request failed.\nYour data has been removed as we encountered the following problems with it: System.Threading.Tasks.Task'1[System.String[]] `

1. Although I haven't explored much of functionality, the
   [Azure Maps Web Control](https://azuremapscodesamples.azurewebsites.net/)
   does look promising.

## My Own Admin Portal

![](/images/azure-maps-admin-portal.png)

There is no management user interface to view/upload/delete your data sets, so I
created one (for fun):
[Azure Maps Admin Portal](https://richorama.github.io/azure-maps-admin-portal/).

It's open source, and you can contribute to it on
[GitHub](https://github.com/richorama/azure-maps-admin-portal/).

## Conclusion

The Azure Maps Data Service is in preview, and we can't expect a polished
product. However there are a number of problems with the current offering, which
need to be addressed before it could be used for real world problems.

I'm keeping an eye on it.
