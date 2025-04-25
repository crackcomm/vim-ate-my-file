#!/usr/bin/env bash

rebuild-nixos() {
  sudo rsync -avh ~/x/dot-repo/nix/ /etc/nixos/nix/
  sudo nixos-rebuild switch --flake /etc/nixos#nixos-vm
}
