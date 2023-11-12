#!/usr/bin/env bash

# Thanks to @thoughtpolice

set -eo pipefail

if [[ "${CID_EDITOR}" == "editor" ]]; then
  CID=$(jj log --no-graph -r $CID_REVISION -T "change_id" | sha256sum | head -c 40)
  CHGSTR="Change-Id: I${CID}"

  contents=$(<"$1")
  readarray -t lines <<<"$contents"

  body=''
  last=''
  for x in "${lines[@]}"; do
    [[ "$x" =~ ^"JJ:" ]] && continue
    [[ "$x" =~ ^"Change-Id:" ]] && continue

    [[ "$x" == '' ]] && [[ "$last" == '' ]] && continue

    last="$x"
    body+="$x\n"
  done

  body+="$CHGSTR\n"

  t=$(mktemp)
  printf "$body" >"$t"
  mv "$t" "$1"
else
  export CID_EDITOR="editor"
  export CID_REVISION="$1"
  jj --config-toml="ui.editor='$0'" describe $CID_REVISION
fi
