---
layout: post
title: ChatGPT Copilot Tips and Tricks
date: 2023-06-14 09:00:00
summary: A few example use cases of the ChatGPT API for programmers.
---

## Extracting search terms from a question

Question:

{% highlight text %}
from the question below, extract the relevant search terms as a comma separated list  
---   
what is the correct treatment of a migrane?
{% endhighlight %}

Response:

{% highlight text %}
migraine, treatment, correct
{% endhighlight %}

Notice it corrects the spelling mistake.

## Sentiment Analysis

Question:

{% highlight text %}
Rate the sentiment of this statement from 1 to 10. Return only the numerical value.  
---    
I was really happy to receive a new puppy on my birthday.
{% endhighlight %}

Response:

{% highlight text %}
9
{% endhighlight %}

## Feature extraction, JSON formatting

Question:

{% highlight text %}
List the animals in this statement as a JSON array  
---  
The quick brown fox jumped over the lazy dog
{% endhighlight %}

Response:

{% highlight text %}
["fox","dog"]
{% endhighlight %}

## Spelling Correction

Question:

{% highlight text %}
correct the spelling of this text  
---  
Munday is my leest favorite day of the weak.
{% endhighlight %}

Response:

{% highlight text %}
Monday is my least favorite day of the week.
{% endhighlight %}

## Test Data Generation

Question:

{% highlight text %}
generate some test data for a person in JSON format with keys for firstName, lastName, cellNumber, address, dateOfBirth
{% endhighlight %}

Response:

{% highlight text %}
Sure, here's an example of test data for a person in JSON format:
{  
  "firstName": "Alice",  
  "lastName": "Smith",  
  "cellNumber": "+1-555-123-4567",  
  "address": {  
    "street": "456 Oak St",  
    "city": "Springfield",  
    "state": "IL",  
    "zipCode": "62704"  
  },  
  "dateOfBirth": "1990-05-20"  
}  
{% endhighlight %}

{% highlight text %}
invent 100 email addresses
{% endhighlight %}

Response:

{% highlight text %}
Sure, here are 100 invented email addresses:
johndoe123@gmail.com
sarahjones456@yahoo.com
bob.smith789@hotmail.com
emilybrown234@gmail.com
...
{% endhighlight %}

## Translation

Question:

{% highlight text %}
Say good morning in arabic. Just return the arabic response.
{% endhighlight %}

Response:

{% highlight text %}
صباح الخير
{% endhighlight %}

