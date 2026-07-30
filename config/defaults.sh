#!/usr/bin/env bash

# Cache roots, CARGO_HOME/GOMODCACHE/PNPM_HOME and the PATH additions live in
# the shell env file, so the install scripts and every non-fish shell agree on
# one definition. Everything below is install-time only.
_defaults_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=../stow/shellenv/.config/dotfiles/env.sh
source "${_defaults_dir}/../stow/shellenv/.config/dotfiles/env.sh"
unset _defaults_dir

export BROWSER="open"

export GOPROXY="https://goproxy.cn,direct"

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CASK_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_INSTALL_FROM_API="1"
export HOMEBREW_NO_ANALYTICS="1"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/web/simple"