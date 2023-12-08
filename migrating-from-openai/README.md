## Background

The [recent drama](https://openai.com/blog/openai-announces-leadership-transition) surrounding OpenAI has been an interesting rollercoaster to say the least... Regardless of your personal feelings about this news, one thing does become clear: **Having your products and/or systems rely on the OpenAI api is a recipe for disaster.**

Tools like [LangChain](https://python.langchain.com/docs/get_started/introduction) can be a great way of being model agnostic, but there is a lot of hidden functionality and magic wand waving in massive packages such as that.

This guide is for developers that do not choose to use larger frameworks like that, and opt to use the api's directly, in Python or not.

## Alternatives

Before we look at how to migrate your code, lets take a look at what other potential llm options we have besides OpenAI:

- **[Anthropic Claude](https://www.anthropic.com/index/introducing-claude)**: This model comes in two flavors, an instant model and a more powerful model. In my testing, the text generation felt more natural compared to GPT-4, but the model has a lot more guard-rails built around it. (You can see this in effect on this little test chat-bot I created to compare how models react to instructions [here](https://pucknorris.com/chat))
- **[LLama 2](https://ai.meta.com/llama/)**: Llama 2 is an interesting model from Meta that is completely open source.
- **[Google Gemini](https://developers.googleblog.com/2023/12/how-its-made-gemini-multimodal-prompting.html)**: This series of models is brand new from Google, but does not currently have a public api. But, it will be interesting to see how this technology evolves, and a blog post may come to discuss this.

In this tutorial, we will be using Anthropic Claude 2.1

## An OpenAI Sample App

First, we will create a bog-simple application using the openai python package to generate a JSON object response giving us book ideas.

### Python Code

```python
import openai
import json

client = openai.OpenAI()

SYS_MSG = """
    You are an AI that generates creative book ideas.
    You will be passed a topic, and you will respond with 3 book ideas.
    You must respond with the following JSON schema:
    {"ideas": [{"title": str, "author": str, "genre" str}]}
"""

messages = [
    {"role": "system", "content": SYS_MSG},
    {"role": "user", "content": "Topic: Realistic science fiction about space travel."},
]

# send the request
response = client.chat.completions.create(
    model="gpt-4-1106-preview",
    response_format={"type": "json_object"},
    temperature=1.0,
    messages=messages,
    timeout=30,
)

# error handling
if len(response.choices) == 0:
    exit(1)
if response.choices[0].finish_reason != "stop":
    exit(1)

# attempt to parse the object
obj = json.loads(response.choices[0].message.content)

print(json.dumps(obj, indent=4))

```

### Json Response

When we run this code, we get the response we expect. Great.

```json
{
    "ideas": [
        {
            "title": "The Kepler Memoirs",
            "author": "Adrian Clarke",
            "genre": "Science Fiction / Adventure"
        },
        {
            "title": "Void Horizon",
            "author": "Eleanor Voss",
            "genre": "Science Fiction / Hard Sci-Fi"
        },
        {
            "title": "Gravity's Echo",
            "author": "Leonard S. Huxley",
            "genre": "Science Fiction / Speculative Fiction"
        }
    ]
}
```

## An Anthropic Equivilent

Now, it is time to develop the anthropic equivilent using the `anthropic` python package.

### Python Code

```python
import anthropic
import json

client = anthropic.Anthropic()

PROMPT = """

Human:
You are an AI that generates creative book ideas.
You will be passed a topic, and you will respond with 3 book ideas.
You **MUST ONLY** respond with the following JSON schema:
{"ideas": [{"title": str, "author": str, "genre" str}]}
Topic = Realistic science fiction about space travel.

Assistant:"""

# send the request
response = client.completions.create(
    model="claude-2.1",
    temperature=0.5,
    timeout=30,
    max_tokens_to_sample=1024,
    prompt=PROMPT,
)

# parse the response
obj = json.loads(response.completion)
print(json.dumps(obj, indent=4))
```

As you can see, the code structure is very similar, with some differences with how anthropic expects your prompts to be created. You must start with `\n\nHuman:` when sending to the api, and they do not have a concept of system messages so the prompt was modified as such.

> You can read more about the anthopic api [here](https://docs.anthropic.com/claude/reference/getting-started-with-the-api).

Also, in our testing we found that anthropic needed a bit more nudging to get a JSON output. Markdown bolding seemed to give the most consistent results, but your mileage may vary.

### Json Response

```json
{
    "ideas": [
        {
            "title": "Wormholes to the Stars",
            "author": "John Smith",
            "genre": "Science Fiction"
        },
        {
            "title": "The Mars Colonization Project",
            "author": "Jane Doe",
            "genre": "Science Fiction"
        },
        {
            "title": "Journey to a Distant Planet",
            "author": "Bob Johnson",
            "genre": "Science Fiction"
        }
    ]
}
```

## Conclusion

Voila! As you can see, we get a very similar result using the anthropic API. 

## Sources

- [LangChain](https://python.langchain.com/docs/get_started/introduction)
- [OpenAI Leadership Change](https://openai.com/blog/openai-announces-leadership-transition)
- [Anthropic Claude](https://www.anthropic.com/index/introducing-claude)
- [Google Gemini](https://deepmind.google/technologies/gemini/#build-with-gemini)
- [Meta Llama](https://ai.meta.com/llama/)
- [Anthropic Docs](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)