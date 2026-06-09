{ lib }:
let
  make =
    default: name: path:
    {
      config,
      home,
      pkgs,
      options,
      modulesPath,
      ...
    }@args:
    let
      inner = (import path) args;
    in
    {
      options.local.${name}.enable = lib.mkOption {
        type = lib.types.bool;
        default = default;
      };
      config = lib.mkIf config.local.${name}.enable inner;
    };
in
{
  optionalModule = make false;
  defaultModule = make true;
}
