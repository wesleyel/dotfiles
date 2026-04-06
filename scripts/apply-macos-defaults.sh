#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../config/defaults.sh
source "${repo_root}/config/defaults.sh"

if [ -f "${repo_root}/local/env.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/env.sh"
fi

defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{ enabled = 0; value = { parameters = (65535, 49, 1048576); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '{ enabled = 0; value = { parameters = (65535, 49, 1572864); type = standard; }; }'

defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
  '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }' \
  '{ InputSourceKind = "Non Keyboard Input Method"; "Bundle ID" = "com.googlecode.rimeime"; "Input Mode" = "com.apple.inputmethod.Roman"; }'

defaults write com.apple.HIToolbox AppleSelectedInputSources -array \
  '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }' \
  '{ InputSourceKind = "Non Keyboard Input Method"; "Bundle ID" = "com.googlecode.rimeime"; "Input Mode" = "com.apple.inputmethod.Roman"; }'

if [ -x /opt/homebrew/bin/fish ]; then
  if ! grep -qx '/opt/homebrew/bin/fish' /etc/shells; then
    echo '/opt/homebrew/bin/fish' | sudo tee -a /etc/shells >/dev/null
  fi

  current_shell="$(dscl . -read "/Users/${USER}" UserShell | awk '{ print $2 }')"
  if [ "${current_shell}" != '/opt/homebrew/bin/fish' ]; then
    chsh -s /opt/homebrew/bin/fish
  fi
fi

if [ -f "${repo_root}/local/macos-defaults.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/macos-defaults.sh"
fi

killall cfprefsd >/dev/null 2>&1 || true