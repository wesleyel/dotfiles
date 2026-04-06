{
  homebrew.casks = [ "squirrel-app" ];

  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
    AppleEnabledInputSources = [
      {
        "InputSourceKind" = "Keyboard Layout";
        "KeyboardLayout ID" = 0;
        "KeyboardLayout Name" = "U.S.";
      }
      {
        "InputSourceKind" = "Non Keyboard Input Method";
        "Bundle ID" = "com.googlecode.rimeime";
        "Input Mode" = "com.apple.inputmethod.Roman";
      }
    ];

    AppleSelectedInputSources = [
      {
        "InputSourceKind" = "Keyboard Layout";
        "KeyboardLayout ID" = 0;
        "KeyboardLayout Name" = "U.S.";
      }
      {
        "InputSourceKind" = "Non Keyboard Input Method";
        "Bundle ID" = "com.googlecode.rimeime";
        "Input Mode" = "com.apple.inputmethod.Roman";
      }
    ];
  };
}
