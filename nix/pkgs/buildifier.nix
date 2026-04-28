{ pkgs, lib, ... }:
pkgs.buildGoModule {
  pname = "buildifier";
  version = "unstable-2026-04-28";

  src = pkgs.fetchFromGitHub {
    owner = "crackcomm";
    repo = "buildtools";
    # crackcomm/buildtools PR #1 — copilot/update-load-fix-behavior
    rev = "3b6e52ee850ef74fb9778f6f067725cd328e59e8";
    # Run `nix build` once with lib.fakeHash to obtain the real hash from the error message.
    sha256 = lib.fakeHash;
  };

  # Run `nix build` once with lib.fakeHash to obtain the real vendor hash from the error message.
  vendorHash = lib.fakeHash;

  subPackages = [ "buildifier" ];

  meta = with lib; {
    description =
      "A Bazel BUILD file formatter and linter (crackcomm/buildtools PR #1: autofix for allowed-symbol-load-locations and cc rules canonical load path)";
    homepage = "https://github.com/crackcomm/buildtools/pull/1";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
