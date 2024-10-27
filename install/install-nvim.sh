#!/usr/bin/env bash

set -e

DIR=$(realpath $(dirname $0))/..

$DIR/wget-checked.sh \
  "https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz" \
  "9f696e635d503b844e4e78e88a22bcf512a78f288bf471379afc3d0004e15217" \
  --install-dir ~/.local

# Add the directory to the PATH for Bash
echo 'export PATH="$PATH:$HOME/.local/nvim-linux64/bin"' >>"$HOME/.bashrc"

# Add the directory to the PATH for Zsh
echo 'export PATH="$PATH:$HOME/.local/nvim-linux64/bin"' >>"$HOME/.zshenv"

mkdir -p ~/.config
cp -r $(realpath $(dirname $0))/../nvim ~/.config/nvim

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

export PATH="$PATH:$HOME/.local/nvim-linux64/bin"

apt-get update
apt-get install -y --no-install-recommends \
  python3-pip

python3 -m pip install neovim

nvim -es -u $HOME/.config/nvim/init.vim -i NONE -c "PlugInstall --sync" -c "qa" || true
