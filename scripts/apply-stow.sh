#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stow_root="${repo_root}/stow"
packages=(atuin fish gh git mirrors rime snipaste vscode)
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="${HOME}/.local/share/dotfiles-backups/stow-${timestamp}"

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU Stow is not installed. Run scripts/install-packages.sh first." >&2
  exit 1
fi

backup_unmanaged_target() {
  local relative_path="$1"
  local target_path="${HOME}/${relative_path}"
  local backup_path="${backup_root}/${relative_path}"
  local resolved_target

  if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
    return
  fi

  if [ -L "${target_path}" ]; then
    resolved_target="$(readlink "${target_path}")"
    case "${resolved_target}" in
      "${stow_root}"/*|"${repo_root}"/*)
        return
        ;;
    esac
  fi

  mkdir -p "$(dirname "${backup_path}")"
  mv "${target_path}" "${backup_path}"
  echo "==> Backed up ${relative_path} -> ${backup_path}"
}

backup_unmanaged_target ".config/atuin"
backup_unmanaged_target ".config/fish/config.fish"
backup_unmanaged_target ".config/gh/config.yml"
backup_unmanaged_target ".config/git/config"
backup_unmanaged_target ".bunfig.toml"
backup_unmanaged_target ".cargo/config.toml"
backup_unmanaged_target ".config/pip/pip.conf"
backup_unmanaged_target ".config/pnpm/rc"
backup_unmanaged_target ".npmrc"
backup_unmanaged_target ".snipaste/config.ini"
backup_unmanaged_target "Library/Rime"
backup_unmanaged_target "Library/Application Support/Code/User/keybindings.json"
backup_unmanaged_target "Library/Application Support/Code/User/settings.json"

mkdir -p \
  "${HOME}/.config/cargo" \
  "${HOME}/.config/fish/conf.d" \
  "${HOME}/.config/git" \
  "${HOME}/.config/gh" \
  "${HOME}/.config/pip" \
  "${HOME}/.config/pnpm" \
  "${HOME}/.snipaste" \
  "${HOME}/Library/Application Support/Code/User"

if [ -d "${backup_root}" ]; then
  echo "==> Existing unmanaged files were moved to ${backup_root}"
fi

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