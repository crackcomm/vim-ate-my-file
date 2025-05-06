#!/usr/bin/env bash

set -eo pipefail

SCRIPT_PATH=$(dirname "$(realpath "$0")")
PROMPT_PATH="$SCRIPT_PATH/../prompts/commit.txt"
PYTHON=/run/current-system/sw/bin/python3

# Check if OPENAI_API_KEY is set
if [[ -z "${OPENAI_API_KEY}" ]]; then
  echo "Error: OPEN_AI_API_KEY is not set. Please set it to your OpenAI API key."
  exit 1
fi

if [[ "${CID_EDITOR}" == "editor" ]]; then
  body=$((cat $PROMPT_PATH; $PYTHON $SCRIPT_PATH/committer.py -r $CID_REVISION) | $SCRIPT_PATH/oai.sh gpt-4.1-nano)

  t=$(mktemp)
  echo -e "$body" >"$t"
  mv "$t" "$1"
else
  export CID_EDITOR="editor"
  export CID_REVISION="$1"
  jj --config="ui.editor='$0'" describe $CID_REVISION
fi
