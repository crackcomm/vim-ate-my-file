{ ... }:
{
  services.openssh = {
    enable = true;
    # WARNING:
    # TODO: change it soon
    settings = {
      PasswordAuthentication = true;
    };
  };
}
