{ pkgs, lib, ... }:

pkgs.buildGoModule {
  pname = "lsp_mcp";
  version = "0.1.0";

  src = ./.;

  vendorHash = "sha256-A9zIGoD2DECms5bTQEhKO9k1+r0jAjZZTJpZ20KcjXk=";
  doCheck = false;
}