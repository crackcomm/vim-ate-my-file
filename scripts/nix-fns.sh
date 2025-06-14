#!/usr/bin/env bash

rebuild-nixos() {
  sudo cp ~/x/dot-repo/flake.{nix,lock} /etc/nixos/
  sudo rsync -avh --delete ~/x/dot-repo/nix/ /etc/nixos/nix/
  sudo rsync -avh --delete ~/x/dot-repo/blorq/ /etc/nixos/blorq/
  sudo nixos-rebuild switch "$@" --flake /etc/nixos#nixos-vm
}
