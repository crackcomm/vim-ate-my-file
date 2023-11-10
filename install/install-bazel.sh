#!/usr/bin/env bash

set -e

wget -O/usr/local/bin/bazel https://releases.bazel.build/6.1.0/release/bazel-6.1.0-linux-x86_64
chmod +x /usr/local/bin/bazel

wget -O/usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-linux-amd64
chmod +x /usr/local/bin/buildifier
