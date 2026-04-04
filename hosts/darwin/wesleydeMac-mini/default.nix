{ hostname, pkgs, username, ... }:
{
  imports =
    [
      ../../../modules/roles/base.nix
      ../../../modules/roles/shell.nix
      ../../../modules/roles/cli.nix
      ../../../modules/roles/languages.nix
      ../../../modules/roles/gui.nix
      ../../../modules/roles/input-method.nix
      ../../../modules/roles/secrets.nix
    ]
    ++ (if builtins.pathExists ../../../local/darwin.nix then [ ../../../local/darwin.nix ] else [ ]);

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  system.primaryUser = username;

  users.users.${username} = {
    description = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
}
