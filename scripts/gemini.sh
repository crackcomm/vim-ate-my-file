#!/usr/bin/env bash

set -euo pipefail

# 1. Get the model name (gemini-2.5 flash by default)
MODEL="${1:-gemini-2.5-flash}"

# 2. Get API key from environment or from ~/.gemini_api_key file
GEMINI_API_KEY="${GEMINI_API_KEY:-$(cat ~/.gemini_api_key)}"

# 3. Read entire stdin into PROMPT
PROMPT=$(cat)

# 4. Build JSON payload using Gemini's schema
# Gemini uses: { contents: [ { parts: [ { text: "..." } ] } ] }
PAYLOAD=$(jq -n \
  --arg prompt "$PROMPT" \
  '{
    contents: [{
      parts: [{
        text: $prompt
      }]
    }],
    generationConfig: {
      temperature: 0.2
    }
  }')

# 5. Send request to Google Gemini API
# Note: The model name is part of the URL
URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}"

curl -sS -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | \
  jq -r '.candidates[0].content.parts[0].text // "Error: No content returned (Check safety settings or API key)"'
