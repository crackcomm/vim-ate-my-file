{ pkgs, lib, ... }:

pkgs.buildGoModule {
  pname = "lsp_mcp";
  version = "0.1.0";

  src = ./.;

  vendorHash = "sha256-2dWjWn7Ol3Eh9llFQnwquBLa+G6SZr23BoKBv4BjnJU=";
  doCheck = false;
}