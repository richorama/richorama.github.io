---
layout:     post
title:      Pessimistic Concurrency in Orleans
date:       2015-03-13 15:21:00
summary:    Pessimistic concurrency stops two users from modifying the same record, by one user taking out a lock on that record, preventing any other user from changing it. This is not a feature built into Orleans, but it's simple to add.
---

## Introduction

Previously I blogged about [Optimistic Concurrency in Orleans](/2015/01/22/optimistic-concurrency-in-orleans/). To complement that post, here is the pessimist's perspective!

Pessimistic concurrency stops two users from modifying the same record, by one user taking out a lock on that record, preventing any other user from changing it. This is not a feature built into Orleans, but it's simple to add.

The grain will maintain an internal value, which we can get/set by calling methods on the grain. However, to set the value we must first lock the grain. This gives us back a guid which we then present when we update the value. If we don't hold the right guid, we can't update the grain.

However, what happens if we never come back and do the update? The lock will be permenantly set, and we can never write to the grain again. To solve this, the grain automatically releases the lock after a set period.

Let's see how this is put together.

## Implementation

We'll use the following grain interfaces to model a grain which holds a single value which a user can get and set. We'll also get fancy, and use generics to specify the type that the grain maintains.

{% highlight c# %}
public interface ILockGrain<T> : IGrain
{
    Task<Lockable<T>> GetValue();
    Task<Locked<T>> GetLock();
    Task SetValue(T value, Guid lockValue);
    Task ReleaseLock(Guid lockValue);
}
{% endhighlight %}

* __GetValue__ just returns the current value of the grain. It also tells you if the grain is currently locked or not.
* __GetLock__ will attempt to lock the grain, it also returns the current value.
* __SetValue__ is used to update the value, and unlock the grain. You must present the current value of the lock for this method to succeed.
* __ReleaseLock__ just releases the lock (if you have it).

As suggested by [Jakub Konecki](https://twitter.com/JakubKonecki) about my last post, I'm using a couple of monads for the return values of the grains:

{% highlight c# %}
public class Lockable<T>
{
    public Lockable(T value, bool locked)
    {
        this.Locked = locked;
        this.Value = value;
    }

    public bool Locked { get; private set; }
    public T Value { get; private set; }
}

public class Locked<T>
{
    public Locked(T value, Guid @lock)
    {
        this.Lock = @lock;
        this.Value = value;
    }

    public Guid? Lock { get; private set; }
    public T Value { get; private set; }
}
{% endhighlight %}

Now we'll implement this grain:

{% highlight c# %}
public class LockGrain<T> : Grain, ILockGrain<T>
{
    // the current value of the lock (null if not locked)
    Guid? _lock;

    // the current value for the grain
    T value;

    // a timer which is used to clear the lock after an interval
    IDisposable timer;

    public Task<Lockable<T>> GetValue()
    {
        // return the value, and whether the grain is locked
        return Task.FromResult(new Lockable<T>(this.value, this._lock.HasValue));
    }

    public Task<Locked<T>> GetLock()
    {
        if (this._lock.HasValue) throw new Exception("Cannot acquire lock, grain is already locked");
            
        var lockValue = Guid.NewGuid();
        this._lock = lockValue;

        // register a timer to clear the lock in 60 seconds
        this.timer = this.RegisterTimer(x => ReleaseLock((Guid) x), lockValue, TimeSpan.FromSeconds(60), TimeSpan.FromSeconds(60));

        // return the lock and the value
        return Task.FromResult(new Locked<T>(this.value, this._lock.Value));
    }

    public Task ReleaseLock(Guid lockValue)
    {
        // the grain is not locked
        if (!this._lock.HasValue || lockValue != this._lock.Value) return TaskDone.Done;

        // dispose of the timer
        if (this.timer != null) this.timer.Dispose();
        this.timer = null;

        // clear the lock
        this._lock = null;
            
        return TaskDone.Done;
    }

    public Task SetValue(T value, Guid lockValue)
    {
        if (!this._lock.HasValue || this._lock.Value != lockValue) throw new Exception("Cannot update value, you don't have the lock");

        // set the value and release the lock
        this.value = value;
        return ReleaseLock(lockValue);
    }
}
{% endhighlight %}

## Calling the grain

{% highlight c# %}
// get a grain
var grain = LockGrainFactory<string>.GetGrain(1);

// get a lock
var result = await grain.GetLock();

// set the value
await grain.SetValue("foo", result.Lock.Value);

// read the value
await grain.GetValue();
{% endhighlight %}

## Conclusion

It seems almost too simple (I'm sure I've missed something!) but implementing a pessimistic locking system in Orleans is quite straight forward.

The support for generics is an added bonus, and makes it possible for grains to be much more flexible.

You might want to improve on this by adding in persistence (I didn't want to overload the sample code).