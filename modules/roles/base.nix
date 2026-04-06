{ lib, mirrorConfig, username, ... }:
let
  nixSubstituters = lib.concatStringsSep " " mirrorConfig.nix.substituters;
in
{
  nix.enable = false;

  environment.etc."nix/nix.custom.conf".text = ''
    extra-experimental-features = nix-command flakes
    auto-optimise-store = true
    warn-dirty = false
    trusted-users = @admin ${username}
    substituters = ${nixSubstituters}
  '';

  programs.zsh.enable = true;

  system = {
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        "com.apple.swipescrolldirection" = false;
      };
    };
  };
}
