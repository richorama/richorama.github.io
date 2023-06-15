---
layout: post
title: ChatGPT Tips and Tricks
date: 2023-06-14 09:00:00
summary: The ChatGPT interface is much more flexible than the chat, text generation and summarisation examples often cited. As a developer there are a few interesting use cases I have played with briefly. Here are a few examples.
---

The ChatGPT interface is much more flexible than the chat, text generation and summarisation examples often cited. As a developer there are a few interesting use cases I have played with briefly. Here are a few examples. If you have any more, let me know!

## Extracting search terms from a question

Question:

    from the question below, extract the relevant search terms as  comma separated list  
    ---   
    what is the correct treatment of a migrane?

Response:

    migraine, treatment, correct

Notice it corrects the spelling mistake.

## Sentiment Analysis

Question:

    Rate the sentiment of this statement from 1 to 10. Return only the numerical value.  
    ---    
    I was really happy to receive a new puppy on my birthday.

Response:

    9

## Feature extraction, JSON formatting

Question:

    List the animals in this statement as a JSON array  
    ---  
    The quick brown fox jumped over the lazy dog

Response:

    ["fox","dog"]

## Spelling Correction

Question:

    correct the spelling of this text  
    ---  
    Munday is my leest favorite day of the weak.

Response:

    Monday is my least favorite day of the week.

## Test Data Generation

Question:

    generate some test data for a person in JSON format with keys for firstName, lastName, cellNumber, address, dateOfBirth

Response:

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

Request:

    invent 100 email addresses

Response:

    Sure, here are 100 invented email addresses:
    johndoe123@gmail.com
    sarahjones456@yahoo.com
    bob.smith789@hotmail.com
    emilybrown234@gmail.com
    ...

## Translation

Question:

    Say good morning in arabic. Just return the arabic response.

Response:

```
صباح الخير
```

## Redacting Sensitive Information

Question:

    replace any name or personal identifiable information with the word "[REDACTED]". Return only the sentence.       
    ---        
    Kevin Jones emailed david.smith@gmail.com before he drove to Nevada.

Response:

    "[REDACTED] emailed [REDACTED] before driving to Nevada."

## Profanity Detection

Question:

    Score this statement for profanity from 1 to 10. Return only the number.
    ---            
    All this AI stuff is total bullshit.

Response:

    8

## Validation / Completion

Question:

    Which country is Redmond in?      
    Respond with only the name of the country

Response:

    United States

## Fuzzy Matching

Question:

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

Response:

    OPTION 2 - Cloud Native Computing

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
