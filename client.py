import os

from vllm import LLM, SamplingParams

# vLLM API key
api_key = os.environ.get("VLLM_API_KEY", "your_vllm_api_key_here")

# Initialize the model
llm = LLM(
    model="mistralai/Mistral-7B-Instruct-v0.3",
    dtype="auto",
    gpu_memory_utilization=0.9,
    api_key=api_key,
)

# Define sampling parameters
sampling_params = SamplingParams(
    temperature=0.7,
    top_p=0.95,
    max_tokens=256,
)

# Prompts to generate completions for
prompts = [
    "Explain what vLLM is in one sentence.",
    "Write a haiku about GPUs.",
]

# Generate outputs
outputs = llm.generate(prompts, sampling_params)

# Print results
for output in outputs:
    print(f"Prompt: {output.prompt}")
    print(f"Generated: {output.outputs[0].text.strip()}")
    print("-" * 40)
