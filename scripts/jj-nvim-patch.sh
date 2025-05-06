#!/usr/bin/env bash

set -euo pipefail

left="$1"
right="$2"
output="$3"
patch_dir="$4"

if [ -z "$left" ] || [ -z "$right" ] || [ -z "$output" ] || [ -z "$patch_dir" ]; then
  echo "Usage: $0 <left> <right> <output> <patch_dir>"
  exit 1
fi

files_to_patch=$(
  find "$patch_dir" -type f -name "*.patch" -exec realpath --relative-to="$patch_dir" {} \; |
    sed 's|\.patch$||'
)

rm -rf $output
cp -r $left $output

# Iterate over each patch file
for file in $files_to_patch; do
  patch_file="$patch_dir/$file.patch"
  cp -f "$right/$file" "$output/$file"
  chmod +w "$output/$file"
  patch -p1 -d $output <"$patch_file" || {
    echo "Failed to apply patch: $file"
    exit 1
  }
done
