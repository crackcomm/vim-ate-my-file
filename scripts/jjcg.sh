#!/usr/bin/env bash

set -eo pipefail

SCRIPT_PATH=$(dirname "$(realpath "$0")")
PROMPT_PATH="$SCRIPT_PATH/../prompts/commit.txt"

if [[ "${CID_EDITOR}" == "editor" ]]; then
  body=$((cat $PROMPT_PATH; $SCRIPT_PATH/committer.py -r $CID_REVISION) | $SCRIPT_PATH/oai.sh gpt-4.1-nano)

  t=$(mktemp)
  echo -e "$body" >"$t"
  mv "$t" "$1"
else
  export CID_EDITOR="editor"
  export CID_REVISION="$1"
  jj --config="ui.editor='$0'" describe $CID_REVISION
fi
