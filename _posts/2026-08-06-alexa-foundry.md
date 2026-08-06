---
layout: post
title: Building a Conversational Alexa Skill with Microsoft Foundry Agents
date: 2026-08-06 09:00:00
summary: A practical walkthrough for connecting an Alexa custom skill to a Microsoft Foundry agent using Azure Functions, managed identity, conversational context, and a latency-safe fallback.
---

What happens if you give Alexa a modern AI agent?

Alexa already provides a microphone, a speaker, and a natural place for a
conversation, but it has not traditionally been backed by a particularly
powerful or stateful AI. Microsoft Foundry agents offer reasoning, tools, and
conversation context, but they do not come with a ready-made consumer
interface.

Combining the two seemed like an interesting science project: Alexa could
provide the voice interface, while Foundry supplied the intelligence.

The idea is simple, but the integration is not. Alexa expects a signed HTTPS
request to produce a complete spoken response within a few seconds. A Foundry
agent can take longer while it reasons or calls tools. Connecting them means
designing around that mismatch rather than simply sending prompts between two
APIs.

This walkthrough builds an Alexa custom skill backed by a Microsoft Foundry
prompt agent. Along the way, we will:

- host Alexa's webhook in Azure Functions;
- authenticate to Foundry with managed identity;
- preserve conversation context between turns;
- let users ask natural follow-up questions;
- give the agent a strict latency budget; and
- fall back to a direct model call when the agent is too slow.

The result is a conversational skill that stays within Alexa's practical
response window without relying on API keys.

## Architecture

The request path is deliberately simple:

```text
Alexa device
    |
    | signed Alexa request
    v
Azure Function
    |
    | managed identity
    v
Microsoft Foundry project
    |
    +-- prompt agent
    |
    +-- direct model fallback
```

Foundry does not implement Alexa's request verification or response schema, so
the Azure Function acts as the protocol adapter.

You will need:

- an Alexa developer account;
- an Azure subscription;
- a Microsoft Foundry project with a deployed model;
- Azure Functions Core Tools; and
- Python with the Azure Functions, Alexa Skills Kit, Azure Identity, and
  Foundry SDK packages.

## Step 1: Create a focused voice agent

A voice agent should not behave like a general-purpose chat interface. Long
answers, Markdown, links, and follow-up questions all sound awkward when read
aloud.

Create a prompt agent with instructions designed for speech:

```python
definition = PromptAgentDefinition(
    model="gpt-5-mini",
    instructions=(
        "You are a conversational assistant speaking through Alexa. "
        "Answer in plain spoken English with at most two short sentences, "
        "no markdown, and no URLs. Use prior conversation context for "
        "follow-up questions. Do not ask a follow-up question; the Alexa "
        "skill handles that."
    ),
    reasoning=Reasoning(effort="minimal"),
)

project_client.agents.create_version(
    agent_name="alexa-conversation-agent",
    definition=definition,
)
```

Using a prompt agent gives the voice experience its own versioned
instructions, model configuration, and evaluation target.

> **Gotcha: tools can be too slow for voice.** A research agent with web search
> frequently exceeded Alexa's practical response window in testing. Keep the
> synchronous voice agent small. Put long-running research into an
> asynchronous workflow or a client that can wait.

## Step 2: Create the Alexa endpoint

An Alexa custom-skill web service must:

1. be publicly reachable over HTTPS;
2. use a trusted certificate;
3. verify Amazon's request signature;
4. reject stale requests; and
5. return Alexa response JSON.

The Alexa Skills Kit web-service adapter performs the signature and timestamp
checks. Connect it to an HTTP-triggered Azure Function:

```python
@app.route(route="alexa", methods=["GET", "OPTIONS", "POST"])
def alexa(req: func.HttpRequest) -> func.HttpResponse:
    if req.method != "POST":
        return func.HttpResponse("Alexa endpoint is ready.", status_code=200)

    try:
        body = req.get_body().decode("utf-8")
        response = webservice_handler.verify_request_and_dispatch(
            dict(req.headers),
            body,
        )
    except (AskSdkException, UnicodeDecodeError) as error:
        logging.warning("Rejected Alexa request: %s", error)
        return func.HttpResponse(status_code=400)

    return func.HttpResponse(
        body=response if isinstance(response, str) else json.dumps(response),
        status_code=200,
        mimetype="application/json",
    )
```

It is useful for `GET` to return a simple health response, but only verified
`POST` requests should reach the skill handler.

> **Gotcha: never disable verification in production.** It is reasonable to
> bypass request verification in unit tests, but a public endpoint must verify
> both the Amazon signature and request timestamp.

## Step 3: Authenticate with managed identity

Enable a system-assigned managed identity on the Function App, then use
`DefaultAzureCredential`:

```python
@lru_cache(maxsize=1)
def get_credential():
    return DefaultAzureCredential()


@lru_cache(maxsize=2)
def get_openai_client(agent_name=None):
    project = AIProjectClient(
        endpoint=os.environ["FOUNDRY_PROJECT_ENDPOINT"],
        credential=get_credential(),
        allow_preview=agent_name is not None,
    )

    return project.get_openai_client(
        agent_name=agent_name,
        timeout=3.0,
        max_retries=0,
    )
```

Configure the Function App with identifiers rather than credentials:

```text
FOUNDRY_PROJECT_ENDPOINT=https://<account>.services.ai.azure.com/api/projects/<project>
FOUNDRY_MODEL_DEPLOYMENT_NAME=gpt-5-mini
FOUNDRY_AGENT_NAME=alexa-conversation-agent
```

Assign the Function identity the **Foundry User** role at the Foundry account
and project scopes. Some resource configurations also require **Cognitive
Services OpenAI User** on the parent AI Services account.

> **Gotcha: a successful Azure login does not prove the Function has access.**
> Local development may authenticate as you, while the deployed Function uses
> its managed identity. Test the deployed identity and check every relevant
> resource scope before debugging the application code.

## Step 4: Define an open-ended Alexa intent

Use an `AMAZON.SearchQuery` slot to capture the first question:

```json
{
  "name": "AskFoundryIntent",
  "slots": [
    {
      "name": "question",
      "type": "AMAZON.SearchQuery",
      "samples": ["{question}"]
    }
  ],
  "samples": [
    "ask {question}",
    "research {question}",
    "tell me about {question}"
  ]
}
```

The first request needs a carrier phrase so Alexa can identify the intent:

> Ask what is the capital of France?

After answering, clear the slot and return a `Dialog.ElicitSlot` directive:

```python
intent = Intent(
    name="AskFoundryIntent",
    confirmation_status=IntentConfirmationStatus.NONE,
    slots={
        "question": Slot(
            name="question",
            value=None,
            confirmation_status=SlotConfirmationStatus.NONE,
        )
    },
)

return (
    response_builder
    .speak(f"{reply} What would you like to ask next?")
    .add_directive(
        ElicitSlotDirective(
            slot_to_elicit="question",
            updated_intent=intent,
        )
    )
    .response
)
```

Alexa now expects another value for the question slot, so the user can say:

> What river runs through it?

They do not need to repeat the wake word, invocation name, or `ask` prefix
while the dialog remains active.

> **Gotcha: the slot must be required.** The interaction model must include an
> elicitation prompt and `SKILL_RESPONSE` delegation. After changing intents,
> samples, slots, or dialog rules, rebuild the Alexa interaction model.

## Step 5: Preserve conversation context

The Foundry Responses API can connect turns using
`previous_response_id`. Store the latest response ID in Alexa's session
attributes:

```python
response = client.responses.create(
    input=prompt,
    previous_response_id=context_id,
    max_output_tokens=500,
)

return FoundryReply(
    text=response.output_text.strip(),
    context_id=response.id,
    mode="agent",
)
```

Omit `previous_response_id` on the first request. Each successful response
replaces the ID stored in the Alexa session.

This creates session-scoped memory without copying the full transcript between
services. Durable memory across Alexa sessions would require storage such as
Azure Table Storage or Cosmos DB, together with a clear consent, privacy, and
retention design.

> **Gotcha: do not mix response chains.** Agent responses and direct-model
> responses may use different execution paths. Store the selected mode with
> the response ID so later turns continue on the same chain.

## Step 6: Design for Alexa's response window

Even a small agent can occasionally be slow. There are two useful safeguards:
progressive speech and a direct-model fallback.

### Send progressive speech

Alexa custom skills cannot stream model tokens as the final response, but they
can send a progressive speech directive while the Function continues working:

```python
directive_service.enqueue(
    SendDirectiveRequest(
        header=Header(request_id=request.request_id),
        directive=SpeakDirective(
            speech="<speak>Let me look that up.</speak>"
        ),
    )
)
```

Failure to send the progressive response should be logged without preventing
the final response.

> **Gotcha: progressive speech does not extend the deadline.** It reassures the
> user that work is happening, but the complete skill response must still
> arrive on time.

### Add a bounded fallback

Give the agent a strict timeout and fall back to the underlying model
deployment:

```python
try:
    response = agent_client.responses.create(
        input=prompt,
        timeout=3.5,
        max_output_tokens=500,
    )
except APITimeoutError:
    return generate_model_reply(prompt)
```

The fallback instructions should match the voice agent's concise style. They
should also avoid claiming to have searched the web or used tools that were not
available on the fallback path.

Once a session falls back, keep later turns on the direct-model response chain.
Switching back and forth makes conversational context unreliable.

> **Gotcha: budget for the whole request.** The agent timeout is only one part
> of the request. Leave enough time for the fallback call, Alexa response
> construction, and network overhead.

## Step 7: Keep non-conversational requests fast

Launch, help, stop, session-ended, and Alexa exception requests do not need
Foundry. Handle them locally.

For example, the launch response can invite the first question:

```python
speech = (
    "Hello, I am an Alexa agent in Microsoft Foundry. "
    "Start your first question with ask."
)

return response_builder.speak(speech).ask(reprompt).response
```

This avoids spending the response budget before the user has asked anything.

## Step 8: Deploy and connect the skill

Publish the Function:

```bash
func azure functionapp publish <function-app-name>
```

Configure the Alexa skill endpoint as:

```text
https://<function-app-name>.azurewebsites.net/api/alexa
```

For the standard Azure hostname, select Alexa's wildcard certificate option.
Save the endpoint configuration, import the interaction model, and build the
skill.

Test at least these paths:

1. launch the skill;
2. ask an initial question;
3. ask a contextual follow-up;
4. trigger an agent timeout and confirm the fallback;
5. end and restart the session; and
6. send an invalid or stale request to confirm it is rejected.

> **Gotcha: rebuild after model changes.** Editing the interaction model JSON
> does not update the live Alexa model until it has been rebuilt.

## Cold starts and production hosting

Cold starts consume part of Alexa's response budget. A timer trigger can be
useful during development, but it is not a strong production guarantee.

For production, use a hosting option designed for predictable startup latency,
such as Flex Consumption with always-ready instances or an Azure Functions
Premium plan.

## Use telemetry to tune the design

Application Insights made the important bottlenecks visible:

- static Alexa turns completed in milliseconds;
- the tool-enabled research agent frequently timed out;
- fallback turns approached Alexa's response window;
- the focused conversation agent responded in roughly 2.4 seconds; and
- some apparent backend failures were actually interaction-model routing or
  Alexa lifecycle requests.

Log request duration, agent timeouts, fallback use, session termination, and
Alexa system exceptions. Do not log access tokens, user identifiers, complete
request payloads, or sensitive conversation content.

## Production checklist

- Keep Alexa signature and timestamp verification enabled.
- Use managed identity instead of Foundry API keys.
- Give the Function identity only the roles it needs.
- Put explicit timeouts on outbound HTTP and model calls.
- Keep synchronous agents small and predictable.
- Preserve the response ID and execution mode together.
- Handle launch and lifecycle requests without calling Foundry.
- Avoid logging credentials or personal conversation data.
- Use telemetry to measure end-to-end latency, not only model latency.

## Conclusion

The difficult part of connecting Alexa to Foundry is not sending a prompt and
reading the response. It is reconciling an agent runtime with a voice platform
that has a short and unforgiving response window.

A focused prompt agent, managed identity, Alexa dialog elicitation,
session-scoped response IDs, and a bounded model fallback provide a practical
foundation. The same design can later support account linking, business API
tools, asynchronous research, richer Alexa displays, and Foundry evaluation
suites.

The boundary remains simple: Azure Functions speaks Alexa's protocol;
Microsoft Foundry runs the conversation.

## References

- [Host a Custom Skill as a Web Service](https://developer.amazon.com/en-US/docs/alexa/custom-skills/host-a-custom-skill-as-a-web-service.html)
- [Dialog Interface Reference](https://developer.amazon.com/en-US/docs/alexa/custom-skills/dialog-interface-reference.html)
- [Define an Alexa Dialog Model](https://developer.amazon.com/en-US/docs/alexa/custom-skills/define-the-dialog-to-collect-and-confirm-required-information.html)
- [Microsoft Foundry Python SDK](https://learn.microsoft.com/python/api/overview/azure/ai-projects-readme)
- [Foundry RBAC](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry)
- [Azure Functions Python guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-python)
