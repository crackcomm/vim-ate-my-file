#!/usr/bin/env bash

. $(dirname $0)/watch_dirs.sh

file=$(echo $@ | sed 's/\.ml/\.exe/')

function execute {
  esy dune exec $file
}

execute

inotifywait --quiet --recursive --monitor --event modify --format "%w%f" $(filtered_dirs) \
| while read change; do
  execute
done
