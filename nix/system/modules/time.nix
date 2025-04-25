{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ tzdata ];

  time.timeZone = "Europe/Warsaw";
}
