---
layout: post
title: Connecting Azure Logic Apps to Azure OpenAI
date: 2023-12-21 09:00:00
summary: GenAI can also be used in a variety of ways to support 'back end' processes. Azure Logic Apps provides a great way to implement business process, with it's rich set of connectors and visual workflow designer. This guide talks through a simple example of a Logic App that calls the Azure OpenAI API.
---

Most of the GenAI use cases we see are the 'copilot' experiences, with a chat assistant helping a user to complete a task.

However GenAI can also be used in a variety of ways to support 'back end' processes, such as:

* Classify documents/emails
* Converting unstructured data into structured data
* Summarisation of documents/conversations

Azure Logic Apps provides a great way to implement business process, with it's rich set of connectors and visual workflow designer.

At the time of writing, the native connectors for Azure OpenAI are in private preview, so this post describes how to call the OpenAI API from a Logic App using the HTTP action.

In this post I'll show how you can call the Azure OpenAI API from Logic Apps to build a simple integration. The Logic App described will trigger when a blob is added to an Azure Storage Container. The contents of the blob will then be submitted to the OpenAI API, which will summarise the contents and write another blob containing the summary.

![](/images/workflow.png)

Stepping through each action in the workflow:

## When a blob is added or updated

This is the trigger for the Logic App. Logic apps can be triggered in a few different ways, including in response to an HTTP request, a timer or an event. In this case we are triggering the workflow when a blob is added to an Azure Storage Container. This give us access to the name of the the blob that was written.

## Read blob content

The next step is to read the contents of the blob. This is done using the Azure Blob Storage connector. The name of the blob is passed in from the previous step.

## HTTP

We now need to make an HTTP request to the OpenAI endpoint, passing in the content of the blob, and the instructions for what we want the AI to do.

![](/images/settings.png)

> I would normally suggest using KeyVault to store credentials such as the OpenAI API key.

## Parse JSON

The OpenAI endpoint returns an HTTP response with a JSON body. The Logic App needs to parse this JSON so that we can access the data in the response.

A JSON schema for the response is shown at the end of this post.

## For each

The OpenAI API can return multiple results, in fact we'll only get one, so the loop will only execute once. But the loop is used to access the data in the response.

## Upload blob to storage container

In this last step we write the summary blob to a different storage container. The name of the blob is the same as the original blob, but with a different extension.

# Conclusion

Although a simple use case, this acts as a reference for how Logic Apps can be used to integrate other systems with the Azure OpenAI API to build automations using GenAI.

# Reference

## Native OpenAI connectors

A Microsoft blob post which demonstrates how the native OpenAI connectors can be used to build worklows. These are currently in a private preview.

[https://techcommunity.microsoft.com/t5/azure-integration-services-blog/use-logic-apps-to-build-intelligent-openai-applications/ba-p/4014121](https://techcommunity.microsoft.com/t5/azure-integration-services-blog/use-logic-apps-to-build-intelligent-openai-applications/ba-p/4014121)

## JSON schema for OpenAI response

{% highlight json %}
  {
      "type": "object",
      "properties": {
          "id": {
              "type": "string"
          },
          "object": {
              "type": "string"
          },
          "created": {
              "type": "integer"
          },
          "model": {
              "type": "string"
          },
          "prompt_filter_results": {
              "type": "array",
              "items": {
                  "type": "object",
                  "properties": {
                      "prompt_index": {
                          "type": "integer"
                      },
                      "content_filter_results": {
                          "type": "object",
                          "properties": {
                              "hate": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "self_harm": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "sexual": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "violence": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              }
                          }
                      }
                  },
                  "required": [
                      "prompt_index",
                      "content_filter_results"
                  ]
              }
          },
          "choices": {
              "type": "array",
              "items": {
                  "type": "object",
                  "properties": {
                      "finish_reason": {
                          "type": "string"
                      },
                      "index": {
                          "type": "integer"
                      },
                      "message": {
                          "type": "object",
                          "properties": {
                              "role": {
                                  "type": "string"
                              },
                              "content": {
                                  "type": "string"
                              }
                          }
                      },
                      "content_filter_results": {
                          "type": "object",
                          "properties": {
                              "hate": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "self_harm": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "sexual": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              },
                              "violence": {
                                  "type": "object",
                                  "properties": {
                                      "filtered": {
                                          "type": "boolean"
                                      },
                                      "severity": {
                                          "type": "string"
                                      }
                                  }
                              }
                          }
                      }
                  },
                  "required": [
                      "finish_reason",
                      "index",
                      "message",
                      "content_filter_results"
                  ]
              }
          },
          "usage": {
              "type": "object",
              "properties": {
                  "prompt_tokens": {
                      "type": "integer"
                  },
                  "completion_tokens": {
                      "type": "integer"
                  },
                  "total_tokens": {
                      "type": "integer"
                  }
              }
          }
      }
  }    
{% endhighlight %}