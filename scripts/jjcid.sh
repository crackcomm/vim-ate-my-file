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
  echo -e "$body" >"$t"
  mv "$t" "$1"
else
  export CID_EDITOR="editor"
  export CID_REVISION="$1"
  if jj log --no-graph -T description -r "$1" | grep -Eq '^Change-Id: I[0-9a-f]{40}$'; then
    echo "Change-Id already present, skipping edit"
  else
    jj --config="ui.editor='$0'" describe "$CID_REVISION"
  fi
  jj describe $CID_REVISION
fi
