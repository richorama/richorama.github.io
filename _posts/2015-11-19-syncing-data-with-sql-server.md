---
layout:     post
title:      Syncing data with SQL Server
date:       2015-11-19 09:00:00
summary:    When building occasionally connected apps, we frequently want to synchronize data between client and server. It's common to build REST APIs to retrieve records from a database that have changed since we last connected.
---

When building occasionally connected apps, we frequently want to synchronize data between client and server. It's common to build REST APIs to
retrieve records from a database that have changed since we last connected.

All too often I've seen dates as way of keeping track of a point in time since changes occurred. I think this is a bad idea 
(as Einstein taught us, time is [not reliable](http://www.space.com/17661-theory-general-relativity.html)). 

This post shows how you can use the timestamp variable in a SQL Server database instead.

## What is the Timestamp?

It is not a time.

It is a [database-wide number](https://msdn.microsoft.com/en-us/library/ms187366.aspx), incremented every time an operation occurs in the database.

You can get the current value like this:

{% highlight sql %}
SELECT @@DBTS;
{% endhighlight %}

SQL Server will also set the current value of the timestamp to a row of the table, if you add a 
[`rowversion` column](https://msdn.microsoft.com/en-us/library/ms182776.aspx) like this:

{% highlight sql %}
CREATE TABLE Example 
(
  ID int PRIMARY KEY, 
  Value varchar(255),
  Version rowversion
);
{% endhighlight %}

Now every time a record is created/updated in this table, the current value of the timestamp is set on the `Version` column. This is done 
automatically for us, we don't need to do anything in the `INSERT`/`UPDATE` statement,

## Using the timestamp to get a delta

(I'm using C# ish pseudo code)

Imagine that our sync API looks something like this (this could be an MVC controller or similar):

{% highlight c# %}
public Tuple<Example[],byte[]> GetDelta(byte[] lastTimestamp)
{
  // The first thing to do is retrieve the current value of the timestamp
  var currentTimestamp = Query("SELECT @@DBTS;");
  
  // next make a query, selecting every record which has changed between last timestamp and the current one
  var results = Query("SELECT * FROM Example WHERE Version > @lastTimestamp AND Version <= @currentTimestamp");
  
  // return the results, and the current timestamp (which is then passed in on the next call)
  return new Tuple<Example[],byte[]>( results, currentTimestamp );
}
{% endhighlight %}

> Note: The current timestamp is used in the query to catch any records which are updated while the method is running

> Note: For the first call to this method, you should pass in `0` as the value for the timestamp (an 8 byte array initialised to zeros).

### Deleted items

This approach does not cope with records which are deleted. Instead, you should soft delete them, and the client should read a flag on them to indicated
they have been deleted.

### Encoding the timestamp

Most ORMs seem to treat the timestamp as a byte array (with 8 bytes). This could be base 64 encoded for convenience. 
It could then be added as an HTTP header on the request/response, or form part of the URI. 

## Conclusion

We saw how to use the timestamp variable, and rowversion data type to implement a basic sync API on SQL Server.

It's a neat approach, which has a few advantages over other methods:

1. The client holds the cursor, so the server is not concerned with how many clients there are, or how up-to-date they are.
1. No data will be lost, the timestamp will give you complete precision.
1. SQL Server maintains both the timestamp variable, and the field in the table, so there's very little to implement.