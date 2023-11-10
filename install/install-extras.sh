#!/usr/bin/env bash

set -e

DIR=$(realpath $(dirname $0))/..

$DIR/wget-checked.sh \
  "https://github.com/eza-community/eza/releases/download/v0.15.3/eza_x86_64-unknown-linux-gnu.tar.gz" \
  "0a90b3f67838e2a9ef69cb04109a2f740a483e7d9d41c3ce5626529f395e0cb4" \
  --install

$DIR/wget-checked.sh \
  "https://github.com/junegunn/fzf/releases/download/0.43.0/fzf-0.43.0-linux_amd64.tar.gz" \
  "a43b0b22649c8e7b2ff7528a5169f868273ba1f74bd5bb4beb282c4af619eb65" \
  --install

$DIR/wget-checked.sh \
  "https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb" \
  "6d78bed13722019cb4f9d0cf366715e2dcd589f4cf91897efb28216a6bb319f1" \
  --install

if [ -n "$DISPLAY" ]; then
  $DIR/wget-checked.sh \
    "https://github.com/crackcomm/vim-ate-my-file/releases/download/v0.0.1/shotgun" \
    "103d8149a71a9ea9692246048ec597959cc70a2132085c41123580008a530870" \
    --install
fi
