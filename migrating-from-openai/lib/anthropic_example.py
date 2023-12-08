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
