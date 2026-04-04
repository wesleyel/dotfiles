{
  programs.git = {
    enable = true;
    lfs.enable = true;

    aliases = {
      br = "branch";
      co = "checkout";
      last = "log -1 --stat";
      st = "status -sb";
    };

    extraConfig = {
      core.editor = "nano";
      fetch.prune = true;
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
  };
}
