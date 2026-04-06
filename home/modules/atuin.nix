let
  vendorAtuin = ../../vendor/atuin;
in
{
  programs.atuin.enable = true;
  home.file.".config/atuin".source = vendorAtuin;
}
