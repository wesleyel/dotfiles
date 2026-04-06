{
  homebrew = {
    apiDomain = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    bottleDomain = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    brewGitRemote = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    coreGitRemote = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    caskGitRemote = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git";
    pipIndexUrl = "https://pypi.tuna.tsinghua.edu.cn/web/simple";
  };

  javascript = {
    npmRegistry = "https://registry.npmmirror.com";
  };

  nix = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  python = {
    pipIndexUrl = "https://pypi.tuna.tsinghua.edu.cn/web/simple";
  };

  rust = {
    cargoIndex = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/";
  };

  go = {
    proxy = "https://goproxy.cn,direct";
  };
}
