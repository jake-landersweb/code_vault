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
