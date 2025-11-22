#!/usr/bin/env bash

set -euo pipefail

MODEL=${1:-}
if [[ -z "$MODEL" ]]; then
  echo "Usage: $0 <model-name>" >&2
  exit 1
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY not set in environment" >&2
  exit 1
fi

# Read entire stdin into PROMPT
PROMPT=$(cat)

# Build JSON payload safely with jq to avoid any quoting issues
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  '{model: $model,
    messages: [{role: "user", content: $prompt}],
    temperature: 0.2
  }')

# Send request to OpenAI Chat Completions endpoint
curl -sS https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq -r '.choices[0].message.content'
