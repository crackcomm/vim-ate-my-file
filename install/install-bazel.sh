#!/usr/bin/env bash

set -e

wget -O/usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64
chmod +x /usr/local/bin/bazel

wget -O/usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-linux-amd64
chmod +x /usr/local/bin/buildifier
