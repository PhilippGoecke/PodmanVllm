#!/usr/bin/env bash
set -euo pipefail

# Configuration variables (override via environment variables if needed)
VLLM_BASE_URL="${VLLM_BASE_URL:-http://localhost:8000/v1}"
VLLM_API_KEY="${VLLM_API_KEY:-EMPTY}"
MODEL_ID="${MODEL_ID:-}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"

echo "1. Checking OpenCode installation..."
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    export PATH="$HOME/.opencode/bin:$PATH"
else
    echo "OpenCode is already installed."
fi

echo "2. Detecting model from vLLM at $VLLM_BASE_URL..."
if [ -z "$" ]; then
    if command -v curl &> /dev/null && command -v python3 &> /dev/null; then
        MODEL_ID=$(curl -sS -H "Authorization: Bearer $VLLM_API_KEY" "$VLLM_BASE_URL/models" | \
            python3 -c "import sys, json; data = json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null || true)
    fi
fi

if [ -z "$MODEL_ID" ]; then
    echo "Error: Could not auto-detect a running model at $VLLM_BASE_URL/models."
    echo "Ensure vLLM is running, or pass the model explicitly: MODEL_ID='Qwen/Qwen2.5-Coder-7B-Instruct' ./setup-opencode-vllm.bash"
    exit 1
fi

echo "Found model: $MODEL_ID"

echo "3. Writing OpenCode configuration to $CONFIG_FILE..."
mkdir -p "$CONFIG_DIR"

# Backup existing configuration if present
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%s)"
    echo "Backed up existing configuration."
fi

cat <<EOF > "$CONFIG_FILE"
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "local-vllm": {
      "name": "Local vLLM",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "$VLLM_BASE_URL",
        "apiKey": "$VLLM_API_KEY"
      },
      "models": {
        "$MODEL_ID": {
          "name": "$MODEL_ID (vLLM)"
        }
      }
    }
  },
  "model": "local-vllm/$MODEL_ID",
  "small_model": "local-vllm/$MODEL_ID"
}
EOF

echo "Setup complete! Launch OpenCode by running: opencode"
