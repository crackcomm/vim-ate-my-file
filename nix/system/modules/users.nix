{ pkgs, ... }: {
  users.users.root.hashedPassword =
    "$6$A0b7tZwNy$Bqw/sqKTMuq3q4FD4dfS2wxZHC40M6dqb7anoC63/CKYD0ZoQXjHb59N0hS4RnpQN3v5DxXi/ybS3eUwr//uA/";

  users.users.pah = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "lp" "docker" ];
    hashedPassword =
      "$6$A0b7tZwNy$Bqw/sqKTMuq3q4FD4dfS2wxZHC40M6dqb7anoC63/CKYD0ZoQXjHb59N0hS4RnpQN3v5DxXi/ybS3eUwr//uA/";
    packages = [ pkgs.home-manager ];
  };

  security.sudo.wheelNeedsPassword = false;
}
