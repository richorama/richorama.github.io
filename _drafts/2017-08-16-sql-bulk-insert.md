---
layout:     post
title:      Bulk inserting data into SQL Server
date:       2017-08-16 09:00:00
summary:    XXXXX
---

Let's say with have a simple table in SQL Server

{% highlight sql %}
CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255) 
);
{% endhighlight %}
