#!/usr/bin/env bash

set -e

DIR=$(realpath $(dirname $0))/..

$DIR/wget-checked.sh \
  "https://go.dev/dl/go1.23.2.linux-amd64.tar.gz" \
  "542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e" \
  --install-dir ~/.local

echo 'export GOROOT="$HOME/.local/go"' >>"$HOME/.bashrc"
echo 'export GOROOT="$HOME/.local/go"' >>"$HOME/.zshenv"

echo 'export PATH="$HOME/.local/go/bin:$PATH"' >>"$HOME/.bashrc"
echo 'export PATH="$HOME/.local/go/bin:$PATH"' >>"$HOME/.zshenv"
