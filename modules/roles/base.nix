{ mirrorConfig, username, ... }:
{
  services.nix-daemon.enable = true;

  nix = {
    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = mirrorConfig.nix.substituters;
      trusted-users = [
        "@admin"
        username
      ];
      warn-dirty = false;
    };
  };

  programs.zsh.enable = true;

  system = {
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };
  };
}
