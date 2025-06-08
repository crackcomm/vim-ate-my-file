{ pkgs, lib, ... }:

let
  tokn = pkgs.buildGoModule {
    pname = "tokn";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "crackcomm";
      repo = "tokn";
      rev = "33b129e2a175bf1af2f9e2d33db04d9d34a279eb";
      sha256 = "sha256-y0RKF4zKzWh7M1RCPzEEHhnIVuLEBNylpg61cdfKkhU=";
    };

    vendorHash = "sha256-8qwSLum+HYKBTS5mw253Ro8sGog/iVEoObXRcKR/aS0=";

    goPackagePath = "github.com/crackcomm/tokn";

    meta = with lib; {
      description = "A small Go tool for tokenizing text";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  pythonDevEnv = pkgs.python3.withPackages (ps:
    with ps;
    [
      # dependency of our commit message generator
      unidiff
    ]);

in {
  environment.systemPackages = [
    tokn
    pythonDevEnv

    pkgs.zoxide
    pkgs.zsh-command-time
    pkgs.zsh-nix-shell
    pkgs.zsh-vi-mode
    pkgs.zsh-bd
    pkgs.zsh-abbr
    pkgs.zsh-autocomplete
    pkgs.lsproxy
    pkgs.python312Packages.jedi-language-server
    pkgs.bazel-lsp
  ];
}
