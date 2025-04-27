#!/usr/bin/env bash

. $(dirname $0)/watch_dirs.sh

function execute {
  esy dune runtest
}

execute

inotifywait --quiet --recursive --monitor --event modify --format "%w%f" $(filtered_dirs) \
| while read change; do
  execute
done
