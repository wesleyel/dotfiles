{ lib, pkgs, ... }:
let
  optionalPackage = attrPath:
    lib.optionals (lib.hasAttrByPath attrPath pkgs) [ (lib.getAttrFromPath attrPath pkgs) ];
in
{
  environment.systemPackages =
    (with pkgs; [
      bat
      curl
      direnv
      eza
      fd
      fish
      fzf
      git
      gh
      gnugrep
      gnused
      jq
      ripgrep
      wget
      zoxide
    ])
    ++ optionalPackage [ "austin" ]
    ++ optionalPackage [ "_1password-cli" ];
}
