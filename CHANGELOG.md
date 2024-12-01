## 0.1.0 (2024-12-01)

### Feat

- update brew package installation and improve Rust installation script for better compatibility
- refactor OS detection in scripts-library.sh for improved compatibility
- improve homebrew installation scripts for macOS and Linux compatibility
- enhance installation scripts for cross-platform compatibility and update user configuration
- update homebrew prefix handling for cross-platform compatibility

## 0.0.2 (2024-09-12)

### Feat

- **uv**: init uv config
- **navi**: init navi
- add ~/.local/bin to path
- **starship**: modify git_status
- more interactive options
- **fish**: Add gpc alias for gerrit_push_commit
- **fish**: disable up arrow in atuin init fish
- **fish**: Add git push and git pull aliases
- Add bat, eza, and atuin to brew packages
- **fish**: separate fish config
- **bat**: add bat config
- **fish**: enhance fzf
- **fish**: add fzf default opts for fish
- add dirhistory for fish
- add git_sync_tag_date
- Add git aliases for common commands
- Add initial project files and configurations

### Fix

- **fish**: ignore bat config if not installed
- skip op if not tiny distro

### Refactor

- Update pxy function to allow forcing proxy setting
- Update APT sources to use USTC mirror for Ubuntu
- **scripts**: change scripts running order
