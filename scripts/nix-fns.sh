#!/usr/bin/env bash

copy-nixos-config() {
	sudo rm -rf /etc/nixos/apps/
	sudo cp -r ~/x/dot-repo/apps /etc/nixos/
	sudo cp ~/x/dot-repo/*.{nix,lock} /etc/nixos/
	sudo rsync -avh --delete ~/x/dot-repo/nix/ /etc/nixos/nix/
}

rebuild-nixos() {
	copy-nixos-config
	sudo nixos-rebuild build "$@" --flake /etc/nixos#nixos-vm
}

rebuild-nixos-test() {
	copy-nixos-config
	sudo nixos-rebuild test "$@" --flake /etc/nixos#nixos-vm
}

rebuild-nixos-switch() {
	copy-nixos-config
	sudo nixos-rebuild switch "$@" --flake /etc/nixos#nixos-vm
}

rebuild-nixos-boot() {
	copy-nixos-config
	sudo nixos-rebuild boot "$@" --flake /etc/nixos#nixos-vm
}
