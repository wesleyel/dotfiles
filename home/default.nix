{ lib, mirrorConfig, username, ... }:
{
  imports =
    [
      ./modules/fish.nix
      ./modules/git.nix
      ./modules/gh.nix
      ./modules/mirrors.nix
      ./modules/input-method.nix
      ./modules/vscode.nix
    ]
    ++ lib.optional (builtins.pathExists ../local/home.nix) ../local/home.nix;

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.11";

    sessionPath = [ "$HOME/.local/bin" "/Volumes/APFS/pnpm" ];
    sessionVariables = {
      BROWSER = "open";
      # --- 外置 APFS 缓存路径 ---
      CARGO_HOME = "/Volumes/APFS/cache/cargo";
      GOMODCACHE = "/Volumes/APFS/cache/go";
      HOMEBREW_CACHE = "/Volumes/APFS/cache/homebrew";
      PNPM_HOME = "/Volumes/APFS/pnpm";
      # --- 镜像 ---
      GOPROXY = mirrorConfig.go.proxy;
      HOMEBREW_API_DOMAIN = mirrorConfig.homebrew.apiDomain;
      HOMEBREW_BOTTLE_DOMAIN = mirrorConfig.homebrew.bottleDomain;
      HOMEBREW_BREW_GIT_REMOTE = mirrorConfig.homebrew.brewGitRemote;
      HOMEBREW_CASK_GIT_REMOTE = mirrorConfig.homebrew.caskGitRemote;
      HOMEBREW_CORE_GIT_REMOTE = mirrorConfig.homebrew.coreGitRemote;
      HOMEBREW_INSTALL_FROM_API = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_PIP_INDEX_URL = mirrorConfig.homebrew.pipIndexUrl;
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;

  # pnpm 内容寻址 store 重定向到外置 APFS 盘
  xdg.configFile."pnpm/rc".text = "store-dir=/Volumes/APFS/cache/pnpm-store\n";
}
