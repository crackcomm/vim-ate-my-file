{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.python3.withPackages (ps:
      [
        ps.unidiff # dependency of our commit message generator
      ]))
    pkgs.tokn
  ];
}
