#!/usr/bin/env bash

set -e

source "$HOME/.cargo/env"

cd /tmp
git clone https://github.com/martinvonz/jj.git
cd jj
cargo build --release --bin jj
mv target/release/jj $HOME/.local/bin/jj
cd
rm -rf /tmp/jj
