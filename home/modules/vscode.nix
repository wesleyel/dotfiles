let
  vscodeSettings = {
    "editor.fontSize" = 14;
    "editor.formatOnSave" = true;
    "editor.minimap.enabled" = false;
    "files.autoSave" = "onFocusChange";
    "terminal.integrated.defaultProfile.osx" = "fish";
    "workbench.startupEditor" = "none";
    "window.commandCenter" = true;
  };

  vscodeKeybindings = [
    {
      command = "workbench.action.terminal.toggleTerminal";
      key = "cmd+j";
    }
  ];
in
{
  home.file."Library/Application Support/Code/User/settings.json".text =
    builtins.toJSON vscodeSettings;

  home.file."Library/Application Support/Code/User/keybindings.json".text =
    builtins.toJSON vscodeKeybindings;
}
