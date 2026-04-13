#!/usr/bin/env bash

export BROWSER="open"

export DOTFILES_VOLUME_ROOT="/Volumes/APFS"
export DOTFILES_CACHE_ROOT="${DOTFILES_VOLUME_ROOT}/cache"

export CARGO_HOME="${DOTFILES_CACHE_ROOT}/cargo"
export GOMODCACHE="${DOTFILES_CACHE_ROOT}/go"
export HOMEBREW_CACHE="${DOTFILES_CACHE_ROOT}/homebrew"
export PNPM_HOME="${DOTFILES_VOLUME_ROOT}/pnpm"

export GOPROXY="https://goproxy.cn,direct"

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CASK_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_INSTALL_FROM_API="1"
export HOMEBREW_NO_ANALYTICS="1"
export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/web/simple"