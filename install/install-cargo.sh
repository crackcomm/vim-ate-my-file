#!/usr/bin/env bash

set -e

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.71.0 -c clippy --no-modify-path -y
