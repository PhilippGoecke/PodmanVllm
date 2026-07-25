#!/usr/bin/env bash
set -euo pipefail

# Configuration
MODEL="${MODEL:-mistralai/Mistral-7B-Instruct-v0.3}"
PORT="${PORT:-8000}"
CONTAINER_NAME="${CONTAINER_NAME:-vllm-openai}"
HF_CACHE="${HF_CACHE:-$HOME/.cache/huggingface}"
IMAGE="docker.io/vllm/vllm-openai:latest"
API_KEY="${API_KEY:-$(openssl rand -hex 32)}"

mkdir -p "$HF_CACHE"

# Remove existing container if present
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

podman run -d \
  --name "$CONTAINER_NAME" \
  --device nvidia.com/gpu=all \
  --security-opt=label=disable \
  --env LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/usr/local/cuda/lib64 \
  --volume /dev/null:/etc/ld.so.conf.d/00-cuda-compat.conf:ro \
  -p "${PORT}:8000" \
  -v "${HF_CACHE}:/root/.cache/huggingface:Z" \
  ${HF_TOKEN:+-e "HF_TOKEN=${HF_TOKEN}"} \
  -e "VLLM_API_KEY=${API_KEY}" \
  --ipc=host \
  "$IMAGE" \
  --model "$MODEL" \
  --max-model-len 16384 \
  --max-num-seqs 64 \
  --gpu-memory-utilization 0.92 \
  --enable-prefix-caching \
  --served-model-name mistral-7b \
  --host 0.0.0.0 \
  --port 8000 \
  --api-key "$API_KEY"

echo "vLLM OpenAI server starting at http://localhost:${PORT}/v1"
echo "API key: ${API_KEY}"
echo "Logs: podman logs -f ${CONTAINER_NAME}"
podman logs -f ${CONTAINER_NAME}
