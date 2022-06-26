#!/usr/bin/env bash

COMMAND=$@

function execute {
  echo "$ $COMMAND"
  sh -c "$COMMAND"
}

execute

inotifywait --quiet --recursive --monitor --event modify --format "%w%f" . \
| while read change; do
  _=$(git check-ignore $change)
  if [[ $? -ne 0 ]]; then
    echo "< $change"
    execute
  fi
done
