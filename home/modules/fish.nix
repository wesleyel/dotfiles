{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;

    shellAbbrs = {
      cat = "bat";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gs = "git status -sb";
      ll = "eza -la --group-directories-first";
    };

    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path "$HOME/.local/bin"
      if type -q atuin
        atuin init fish | source
      end
    '';
  };
}
