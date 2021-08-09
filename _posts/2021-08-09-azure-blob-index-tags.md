---
layout: post
title: Azure Blob Storage Index Tags
date: 2021-08-09 09:00:00
summary: Index tags allow you to provide up to 10 key-value pairs for a blob. The tags are indexed, and you can use them to query blobs in your storage account.
---

# Background

I think the storage services in Azure are excellent. They provide a cheap and reliable data
storage mechanism which can scale to 500TB (per container/table/queue) and provide 20k req/sec
throughput.

The challenge is the lack of secondary indexing. Blob and Table records are indexed by a sorted key.
This allows easy retrieval if you know the name of the thing you want. The key can be
used/abused to make querying easier if you want to get a range of entities.

Blobs can be retrieved by a prefix of their key, table entities
can be retrieved a partition at a time (up to 1000 entities), and bounds can be set on the key range.

But if you want to index it by a second property you need to store a second entity. There are no transactions in Storage. You can store multiple table entities in a single operation,
but they have to share the same partition key.

The other option is to use a secondary service, such as Azure Search, but that's more complexity
and cost.

# Index Tags

In Just 2021 Index Tags were made generally available for Azure Blob Storage.

Index tags allow you to provide up to 10 key-value pairs for a blob. These tags
are outside of the blob data, and are specified when you create or update a blob.

The tags are indexed, and you can use them to query blobs in your storage account.

Index Tags have some interesting features:

* Maximum to 10 tags per blob.
* Maximum of 768 bytes per tag.
* Maximum of 5k results per page.
* Tags have eventual-consistency (other blob operations have immediate consistency).
* Tags are exposed in the Portal, including searching for blobs.
* All blob types are supports (page, block and append).
* By default searches span all containers in the storage account.
* Tags are case-sensitive.
* You can use tags to move blobs to cooler storage tiers.
* Tags are lexicographically sorted (sorted by string value, not numerical).

# Querying

Tags are queried using a simple query language:

```
"Animal" = 'panda' AND Age >= "10"
```

Key names should be wrapped in double quotes (this isn't strictly necessary, but it will escape spaces).
Values should be wrapped in single quotes.

Conditions can be joined using `AND`, but no other logical operators (such as `OR`) are supported for querying.

To limit queries to a single container a special `@container` key can be supplied.

```
@container = "animals" AND "Animal" = 'panda'
```

The supported equality operators are: `=` `>` `>=` `<` `<=`


There are some constraints on querying:

* Queries than include a range condition (such as `'Age' > "10"`) can
  only apply range constraints to a single tag.

  This is an __invalid__ query: `'Age' > "10" AND 'Length' < "200"`

  This is a __valid__ query:  `'Age' > "10" AND 'Age' <= "40"`

* Queries that constrain the results to a single container cannot include
  range constraints.

  This is an __invalid__ query: `@container = "animals" AND 'Age' > "10"`

  This is a __valid__ query:  `@container = "animals" AND 'name' = "Rambo"`

# Using Index Tags from C#

Set index tags using `BlobUploadOptions`.

{% highlight c# %}
// get a reference to the blob
var blob = new BlobServiceClient("XXX");
  .GetBlobContainerClient("animals")
  .GetBlockBlobClient("panda");

// set the tags on the blob upload options
var options = new BlobUploadOptions();
options.Tags = new Dictionary<string, string>{
  { "animal", "panda" },
  { "name", "Rambo" },
  { "age", "10" }
};

using (var stream = new MemoryStream())
{
  // upload JSON as the blob content
  await JsonSerializer.SerializeAsync(stream, new AnimalData());
  stream.Position = 0;
  await blob.UploadAsync(stream, options);
}
{% endhighlight %}

To query blobs use `FindBlobsByTagAsync()`.

{% highlight c# %}
var client = new BlobServiceClient("XXX");

var queryString = @"@container = 'animals' AND ""name"" = 'Rambo'";

var blobs = new List<TaggedBlobItem>();
await foreach (var taggedBlobItem in client.FindBlobsByTagsAsync(queryString))
{
  blobs.Add(taggedBlobItem);
}

return blobs;
{% endhighlight %}

# Questions

I haven't tried large volumes of data, and there are few unanswered questions:

* How do the query times change when the data volume rises?
* How does the time to consistency change when the index sizes increase?
* Will query capabilities be improved over time?

# Conclusion

Index Tags look like a useful feature, to make it easier to build software using
Azure Blob Storage as an underlying datastore.

Whilst there are some constraints
with Index Tags, discussed in this post, the added querying capability is
an interesting development, and provides
a flexibility that wasn't previously available.