import os

# vLLM API key
api_key = os.environ.get("VLLM_API_KEY", "your_vllm_api_key_here")

from openai import OpenAI

client = OpenAI(
    base_url="http://host.containers.internal:8000/v1",
    api_key=api_key
)

response = client.chat.completions.create(
    model="mistral-7b",
    messages=[
        {"role": "system", "content": "Du bist ein hilfreicher Assistent."},
        {"role": "user", "content": "Erkläre kurz, was vLLM ist."}
    ],
    temperature=0.7
)

print(response.choices[0].message.content)
