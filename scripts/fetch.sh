#!/usr/bin/env bash

DIR=$(realpath $(dirname $0))/../env/

cp ~/.tmux.conf $DIR
cp ~/.jjconfig.toml $DIR
cp ~/.zshrc $DIR
