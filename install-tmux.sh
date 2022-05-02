#!/usr/bin/env bash

git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make -j`nproc`

if [[ $EUID -ne 0 ]]; then
  sudo make install
else
  make install
fi

