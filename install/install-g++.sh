#!/usr/bin/env bash

set -e

add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y --no-install-recommends \
  g++-13

# cc and c++ aliases are used by ocaml
update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-13 130
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-13 130

apt-get clean
rm -rf /var/lib/apt/lists/*
