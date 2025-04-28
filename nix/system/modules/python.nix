{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (python3.withPackages
        (ps: with ps; [ requests httpx numpy pandas polars-lts-cpu ]))
    ];
}
