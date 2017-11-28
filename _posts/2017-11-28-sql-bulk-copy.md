---
layout:     post
title:      Bulk inserting data into SQL Server
date:       2017-11-28 09:00:00
summary:    Let's say with have a simple table in SQL Server in which we want to insert thousands of values (Guids) from a .NET application.
---

Let's say with have a simple table in SQL Server

{% highlight sql %}
CREATE TABLE [dbo].[test](
    [Value] [varchar](36) NOT NULL
)
{% endhighlight %}

...in which we want to insert thousands of values (Guids) from a .NET application.

## One by one

A naive approach is to insert one at a time, like this:

{% highlight c# %}
public void OneByOne()
{
    const string sql = "INSERT INTO [Test] ([Value]) Values (@Value)";
    for (var i = 0; i < count; i++)
    {
        connection.Execute(sql, new { Value = Guid.NewGuid().ToString()});
    }
}
{% endhighlight %}

(note this code uses Dapper)

Inserting 10,000 records on a local SQL Express database takes 54,533ms, which is __183 records per second__. Slow :¬(

## 1000 at a time

SQL Server allows you to insert multiple records in a single insert statement, in fact we can insert up to 1,000 at a time.

{% highlight c# %}
public void BatchOf1000()
{
    foreach (var batch in Enumerable.Range(0, count).Chunk(1000))
    {
        if (batch.Length == 0) continue;
        var sql = "INSERT INTO [Test] ([Value]) VALUES \r\n" + string.Join(",\r\n", batch.Select(x => $"('{Guid.NewGuid().ToString()}')"));
        connection.Execute(sql);
    }
}
{% endhighlight %}

Inserting 1,000,000 records on a local SQL Express database takes 22,256ms, which is __44,931 records per second__. Must faster.

## Bulk Copy

Can we go any faster? Of course we can.

SQL Server (and SQL Database in Azure) supports [bulk insert](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/bulk-copy-operations-in-sql-server), you may have used bcp in the past.

The `SqlBulkCopy` class provides easy access to this from .NET.

{% highlight c# %}
public void BulkCopy()
{
    var table = new DataTable();
    table.Columns.Add("Value", typeof(string));

    for (var i = 0; i < count; i++)
    {
        table.Rows.Add(Guid.NewGuid().ToString());
    }

    using (var bulk = new SqlBulkCopy(this.connection))
    {
        bulk.DestinationTableName = "test";
        bulk.WriteToServer(table);
    }
}
{% endhighlight %}

Inserting 1,000,000 records on a local SQL Express database takes 9,315ms, which is __107,353 records per second__. Even faster.

## Notes on SqlBulkCopy

The above code samples shows that in C# you must first create a `DataTable`, and then tell it the schema of the destination table. You then add values according to their position in the table.

This code is a little fragile to changes in the table structure, so another approach is to load the table structure from the database, and then insert the values by name rather than position:

{% highlight c# %}
public void BulkCopy()
{
    var table = new DataTable();

    // read the table structure from the database
    using (var adapter = new SqlDataAdapter($"SELECT TOP 0 * FROM test", this.connection))
    {
        adapter.Fill(table);
    };

    for (var i = 0; i < count; i++)
    {
        var row = table.NewRow();
        row["Value"] = Guid.NewGuid().ToString(); 
        table.Rows.Add(row);
    }

    using (var bulk = new SqlBulkCopy(this.connection))
    {
        bulk.DestinationTableName = "test";
        bulk.WriteToServer(table);
    }
}
{% endhighlight %}

I've noticed a small overhead in using `SqlBulkCopy`, so I wouldn't use it for insert a small number of records (i.e. less than 100), but your mileage may vary.

Happy inserting!
