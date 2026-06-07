return {
  cmd = { "nixd", "--inlay-hints" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = [[(let flake = builtins.getFlake (toString ./.); configs = flake.nixosConfigurations or { }; names = builtins.attrNames configs; in if names != [ ] then configs.${builtins.head names}.options else { })]],
        },
      },
      diagnostic = {
        suppress = { "sema-extra-with" },
      },
      inlayHints = {
        enable = true,
      },
    },
  },
}
