set -gx BROWSER open

set -gx NIXCONFIG_VOLUME_ROOT /Volumes/APFS
set -gx NIXCONFIG_CACHE_ROOT "$NIXCONFIG_VOLUME_ROOT/cache"

set -gx CARGO_HOME "$NIXCONFIG_CACHE_ROOT/cargo"
set -gx GOMODCACHE "$NIXCONFIG_CACHE_ROOT/go"
set -gx HOMEBREW_CACHE "$NIXCONFIG_CACHE_ROOT/homebrew"
set -gx PNPM_HOME "$NIXCONFIG_VOLUME_ROOT/pnpm"

set -gx GOPROXY https://goproxy.cn,direct

set -gx HOMEBREW_API_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
set -gx HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
set -gx HOMEBREW_BREW_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
set -gx HOMEBREW_CASK_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
set -gx HOMEBREW_CORE_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
set -gx HOMEBREW_INSTALL_FROM_API 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_PIP_INDEX_URL https://pypi.tuna.tsinghua.edu.cn/web/simple

set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

fish_add_path "$HOME/.local/bin"
fish_add_path "$PNPM_HOME"
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin