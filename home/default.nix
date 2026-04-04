{ lib, mirrorConfig, username, ... }:
{
  imports =
    [
      ./modules/fish.nix
      ./modules/git.nix
      ./modules/gh.nix
      ./modules/mirrors.nix
      ./modules/vscode.nix
    ]
    ++ lib.optional (builtins.pathExists ../local/home.nix) ../local/home.nix;

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.11";

    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      BROWSER = "open";
      GOPROXY = mirrorConfig.go.proxy;
      HOMEBREW_API_DOMAIN = mirrorConfig.homebrew.apiDomain;
      HOMEBREW_BOTTLE_DOMAIN = mirrorConfig.homebrew.bottleDomain;
      HOMEBREW_BREW_GIT_REMOTE = mirrorConfig.homebrew.brewGitRemote;
      HOMEBREW_CASK_GIT_REMOTE = mirrorConfig.homebrew.caskGitRemote;
      HOMEBREW_CORE_GIT_REMOTE = mirrorConfig.homebrew.coreGitRemote;
      HOMEBREW_INSTALL_FROM_API = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_PIP_INDEX_URL = mirrorConfig.homebrew.pipIndexUrl;
      XDG_CONFIG_HOME = "$HOME/.config";
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
}
