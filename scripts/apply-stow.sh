#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stow_root="${repo_root}/stow"
packages=(atuin fish gh git mirrors rime vscode)

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU Stow is not installed. Run scripts/install-packages.sh first." >&2
  exit 1
fi

mkdir -p \
  "${HOME}/.config/cargo" \
  "${HOME}/.config/fish/conf.d" \
  "${HOME}/.config/git" \
  "${HOME}/.config/gh" \
  "${HOME}/.config/pip" \
  "${HOME}/.config/pnpm" \
  "${HOME}/Library/Application Support/Code/User"

stow --dir "${stow_root}" --target "${HOME}" --restow "${packages[@]}"

link_local_file() {
  local source_path="$1"
  local target_path="$2"

  if [ -f "${source_path}" ]; then
    mkdir -p "$(dirname "${target_path}")"
    ln -sfn "${source_path}" "${target_path}"
  fi
}

link_local_file "${repo_root}/local/fish.local.fish" "${HOME}/.config/fish/conf.d/90-local.fish"
link_local_file "${repo_root}/local/gitconfig.local" "${HOME}/.config/git/local.conf"