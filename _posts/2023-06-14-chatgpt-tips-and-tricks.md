---
layout: post
title: ChatGPT Copilot Tips and Tricks
date: 2023-06-14 09:00:00
summary: The ChatGPT interface is much more flexible than the chat, text generation and summarisation examples often cited. As a developer there are a few interesting use cases I have played with briefly. Here are a few examples.
---

The ChatGPT interface is much more flexible than the chat, text generation and summarisation examples often cited. As a developer there are a few interesting use cases I have played with briefly. Here are a few examples. If you have any more, let me know!

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

## Redacting Sensitive Information

Question:

{% highlight text %}
replace any name or personal identifiable information with the word "[REDACTED]". Return only the sentence.       
---        
Kevin Jones emailed david.smith@gmail.com before he drove to Nevada.
{% endhighlight %}

Response:

{% highlight text %}
"[REDACTED] emailed [REDACTED] before driving to Nevada."
{% endhighlight %}

## Profanity Detection

Question:

{% highlight text %}
Score this statement for profanity from 1 to 10. Return only the number.
---            
All this AI stuff is total bullshit.
{% endhighlight %}

Response:

{% highlight text %}
8
{% endhighlight %}  

## Validation / Completion

Question:

{% highlight text %}
Which country is Redmond in?      
Respond with only the name of the country
{% endhighlight %}

Response:

{% highlight text %}
United States
{% endhighlight %}

## Fuzzy Matching

Question:

{% highlight text %}
Which option most closely matches the input:  
---  
INPUT  
Kubernetes  
---  
OPTION 1  
Wild flowers of Great Britain  
---  
OPTION 2  
Cloud Native Computing  
---  
OPTION 3  
Bicycle Maintenance Guide
{% endhighlight %}

Response:

{% highlight text %}
OPTION 2 - Cloud Native Computing
{% endhighlight %}


# Getting Started

Calling the Azure OpenAI service is simple. You can use any programming language that supports HTTP requests. Here is an example in Python using the OpenAI Python SDK:

{% highlight python %}
import os
import openai
import sys

openai.api_type = "azure"
openai.api_base = "https://XXX.openai.azure.com/"
openai.api_version = "2023-03-15-preview"
openai.api_key = os.getenv("OPENAI_API_KEY")

prompt = "What colour is a banana?"

response = openai.ChatCompletion.create(
  engine="YOUR_ENGINE_ID",
  messages = [{"role": "user", "content": prompt}],
  temperature=0.7,
  max_tokens=800,
  top_p=0.95,
  frequency_penalty=0,
  presence_penalty=0,
  stop=None)

print(response)
{% endhighlight %}
