{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      alias = {
        br = "branch";
        co = "checkout";
        last = "log -1 --stat";
        st = "status -sb";
      };
      core.editor = "nano";
      fetch.prune = true;
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
  };
}
