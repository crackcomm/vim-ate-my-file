#!/usr/bin/env bash

set -e

apt-get update
apt-get install -y --no-install-recommends \
  g++-11

# cc and c++ aliases are used by ocaml
update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-11 110
update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-11 110

apt-get clean
rm -rf /var/lib/apt/lists/*
