#!/usr/bin/env bash

set -e

wget -O/usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64
chmod +x /usr/local/bin/bazel

wget -O/usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-linux-amd64
chmod +x /usr/local/bin/buildifier

dir_path="/usr/share/zsh/vendor-completions/"

if [ -d "$dir_path" ]; then
  curl -o "$dir_path/_bazel" https://raw.githubusercontent.com/bazelbuild/bazel/master/scripts/zsh_completion/_bazel
  echo "Downloaded and copied _bazel to $dir_path"
else
  echo "Directory $dir_path does not exist. Please create it and run the script again."
fi
