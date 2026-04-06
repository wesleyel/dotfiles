{
  homebrew = {
    enable = true;
    taps = [ "farion1231/ccswitch" ];
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = [
      "1password"
      "betterdisplay"
      "farion1231/ccswitch/cc-switch"
      "codex-app"
      "docker-desktop"
      "google-chrome"
      "iina"
      "iterm2"
      "obsidian"
      "raycast"
      "snipaste"
      "visual-studio-code"
      "xcodes-app"
    ];
  };
}
