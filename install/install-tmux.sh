#!/usr/bin/env bash

apt update

if ! command -v cc &>/dev/null; then
  apt install -qy --no-install-recommends \
    gcc
fi

apt install -qy --no-install-recommends \
  libevent-dev ncurses-dev build-essential bison pkg-config automake

git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make -j$(nproc)

if [[ $EUID -ne 0 ]]; then
  sudo make install
else
  make install
fi

cd ..
rm -rf tmux

cp $(realpath $(dirname $0))/../.tmux.conf $HOME/
