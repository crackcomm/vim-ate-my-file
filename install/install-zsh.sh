#!/usr/bin/env bash

apt update
apt install -qy --no-install-recommends \
  zsh

DIR=$(realpath $(dirname $0))/..

cp $DIR/.{zshrc,zshenv} $HOME
