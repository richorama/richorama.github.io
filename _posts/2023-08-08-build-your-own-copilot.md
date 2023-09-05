---
layout: post
title: Build your own Copilot
date: 2023-09-05 09:00:00
summary: There are many use cases for generative AI, but one that many people have been excited about is the ability to build a chatbot that can answer questions about any topic. In this post I cover the different levels of sophistication you can build into your chatbot, and how you can use the Azure OpenAI API to build your own Copilot.
---

<img src="/images/OIG.jpeg" style="width:100%" />

_An AI generated image of "constructing a large language model"._

There are many use cases for generative AI, but one that many people have been excited about is the ability to build a chatbot that can answer questions about any topic.

In this post I cover the different levels of sophistication you can build into your chatbot, and how you can use the [Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview) API to build your own Copilot.

## Copilot Level 1 - Basic Chat

You can build an interactive chat experience for your customers using the Azure OpenAI API and the
chat completions API. The Large Language Model (LLM) has enough context to generate a response to a wide
variety of tasks. You can use this to build a chatbot, or a simple question and answer system.

However this is limited as the LLM has been trained on historical data, and is limited to public
data which may not include information useful to your customer (such as internal documentation).

## Copilot Level 2 - Augmenting the LLM

You can build a more advanced chat experience by bring some of your own data to the prompt, and
augmenting the knowledge in the LLM. You can take advantage of the system message in the API
to include data from your own knowledge base.

For example you could include a list of today's football scores in the system message, and 
the AI could answer questions about the results.

You can see an example of this here: [https://github.com/richorama/approved-services-copilot](https://github.com/richorama/approved-services-copilot)

However, you are limited in the number of tokens you can include in a request (16k at time of writing) so you need to be selective about what data is included with the prompt. You probably have a much larger knowledge base that you want to draw knowledge from.

## Copilot Level 3 - Augmenting with Dynamic Data

Loading additional data relevant to the question allows you to augment the model with a subset of your knowledge base, so that it has just the right data is needs to answer the question.

First you need to index your data into a search engine. Azure Cognitive Search is a natural choice, but it could be any search system. Redis and Cosmos DB are also common choices. All of these services support vector search, which allows you to search based on the similarity of the data to the prompt, rather than matching keywords.

You can use ChatGPT to extract he appropriate search terms from the prompt, and then use the search engine to find the most relevant data. You can then use the search results to augment the prompt, and then use the LLM to generate a response.

An additional advantage of this approach is you can include the list of search results in the response to the user, so they can read the source material for themselves.

## Copilot Level 4 - Calling Functions

Your request to the OpenAI API can include the definition of several [functions](https://openai.com/blog/function-calling-and-other-api-updates), and their input parameters. These functions are not called directly by the service, but instead the AI can respond with an instruction to call it, and what the arguments should be.

Your code is then responsible for calling the function, and sanitizing the input, and collecting the output. The output value should be added to the conversation history of the chat session, and another call made to the ChatGPT API to generate a response for the user to read.

Functions can be used to execute actions; such as creating a support ticket, sending an email, submitting a meter reading or anything else you would like the user to be able to do.

Functions bring to life the Copilot experience to make it more than just a chatbot, it can become an agent which can perform actions on behalf of the user.

You can see an example of this here: [https://github.com/richorama/etch-a-sketch-copilot](https://github.com/richorama/etch-a-sketch-copilot)

## Copilot Level 5 - Extensibility in the Enterprise

At the time of writing [ChatGPT extensibility](https://openai.com/blog/chatgpt-plugins) is a an area of active development. But it seems like the approach a large enterprise will need to
take to scale Copilots across the organisation.

If you imagine multiple business units within an organisation stand up their own Copilots, i.e. one for HR, one of finance, one for IT support etc... the result will be confusion for users not knowing where to go to ask a question, and technical debt for the organisation having to maintain multiple systems that do broadly the same thing.

Instead, the organisation should stand up a single Copilot, and allow each business unit to extend it with their own knowledge base, and their own functions. This will allow the organisation to scale the Copilot across the organisation, and allow users to ask questions about any topic, and perform any action, without having to know which business unit is responsible for that topic.

How this works from a technical perspective is debatable. Should a central Copilot ask questions in plain text to other Copilots in the business via an HTTP API? Should business units just register API endpoints that get called by the central Copilot when it determines it's appropriate. Should the Copilot search a directory of API endpoints to find the right one to call? It will be interesting to see how this evolves. I'm excited to be helping customers work this out.
