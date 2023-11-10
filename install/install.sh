#!/usr/bin/env bash

set -e

DIR=$(realpath $(dirname $0))

$DIR/install-deb-pkgs.sh
$DIR/install-extras.sh
$DIR/install-zsh.sh
$DIR/install-nodejs.sh
$DIR/install-g++.sh
$DIR/install-tmux.sh
$DIR/install-nvim.sh
$DIR/install-bazel.sh
$DIR/install-clang.sh
$DIR/install-esy.sh
$DIR/install-cargo.sh
$DIR/install-jj.sh
