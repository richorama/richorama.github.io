---
layout:     post
title:      Optimistic Concurrency in Orleans
date:       2015-01-22 14:43:00
summary:    the Storage Provider infrastructure in Orleans exposes an 'Etag' field representing a particular revision of the data in the underlying storage system. This can be used to detect writes competing writes to overwrite grain state.
---

## Introduction

Orleans helps the developer with concurrency problems in a distributed system, by providing single instances of your objects running in a single thread (we call these grains). This eliminates problems such as competing threads attempting to access singleton resources. However, concurrency problems can still be encountered. 

Perhaps you have two users of your system looking at the same item of data (the same piece of grain state). They both retrieve the data at roughly the same time, user 1 updates the value and presses save. Their update is successfully stored by the system. User 2 also updates the value, and presses save. This wipes out user 1's edits. This might be ok in some scenarios, but it would be nice to have the opportunity to react to this situation, and reject user 2's changes.

One possible solution is an event sourced approach, whereby all changes are accepted, and the current value is the sum of all changes. This is a neat solution, but not always applicable.

The Storage Provider infrastructure in Orleans exposes an 'Etag' field. This field represents a particular revision of the data in the underlying storage system. We can use this field to implement [optimistic concurrency](https://msdn.microsoft.com/en-us/library/aa0416cz(v=vs.110).aspx).

If we provide the user with the corresponding Etag for their value, they can present this at the time of writing the update. This allows us to detect any changes in the data since they last retrieved the value.

## Implementation

We'll use the following grain interfaces to model a grain which holds a single value which a user can get and set.

{% highlight c# %}
// we'll use this class as a convenient way to pass the value and etag back to the user
public class ReadResponse
{
    public string Value { get; set; }
    public string ETag { get; set; }
}

// the grain interface, allow a user to get and set the value
public interface IExampleGrain : IGrain
{
    Task<ReadResponse> GetValue();
    Task<ReadResponse> SetValue(string value, string eTag);
}
{% endhighlight %}

Now we'll implement this grain:

{% highlight c# %}
// we'll need a class to store the state
public interface IExampleGrainState : IGrainState
{
    string Value { get; set; }
}

// the grain must be marked as a storage provider which supports etag
[StorageProvider(ProviderName = "AzureStore")]
public class ExampleGrain : Orleans.Grain<IExampleGrainState>, IExampleGrain
{
    ReadResponse ComposeResponse()
    {
        return new ReadResponse
        {
            ETag = this.State.Etag,
            Value = this.State.Value
        };
    }

    public Task<ReadResponse> GetValue()
    {
        return Task.FromResult(ComposeResponse());
    }

    public async Task<ReadResponse> SetValue(string value, string eTag)
    {
        if (this.State.Etag != null)
        {
            // if the state has an etag, we must ensure that the user's etag matches it
            // if they don't match, throw an exception to prevent the write
            if (this.State.Etag != eTag) throw new ArgumentException("out of date", "eTag");
        }

        if (this.State.Value == value)
        {
            // nothing to do
            return ComposeResponse();
        }

        // update the value
        this.State.Value = value;

        // write the state  (which will update the etag)
        await this.State.WriteStateAsync();

        // return the current value and etag
        return ComposeResponse();
    }
}
{% endhighlight %}

Note that in `SetValue()`, before we update the state we compare the eTags to check they match. A mismatch here indicates that the etag supplied is stale, so the write is rejected.

Note that this implementation would not work if the grain is marked as `[Reentrant]`, as the etag mutates while the grain is awaiting the storage operation.

If you don't have a grain with a storage provider, an etag could be maintained by the grain instead. An integer, for example, could be incremented for every write. The advantage of the etag from the storage provider is that it's built-in, and will survive grain re-activation.

A working implementation of this code is [available on GitHub](https://github.com/richorama/orleans-optimistic-concurrency).

## Conclusion

It's fairly simple to introduce optimistic concurrency in a grain, thanks to the etag field in the storage provider.

If you're concerned about competing writes to the same grain, an optimistic concurrency implementation like this would stop clients overwriting each other's data. 

It would also be interesting to implement a pessimistic concurrency model, whereby timed locks could be created in a grain, preventing other users from writing to the grain during the lock period.