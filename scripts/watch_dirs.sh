#!/usr/bin/env bash

filtered_dirs() {
  dirs=$(find . -maxdepth 1 -type d)
  filtered=""
  for dir in $(echo $dirs); do
    dir=$(basename $dir)
    if [[ $dir == "." || $dir == ".git" ]]; then
      continue
    fi
    _=$(git check-ignore $dir)
    if [[ $? -ne 0 ]]; then
      filtered="$filtered $dir"
    fi
  done
  echo "$filtered"
}
