#!/usr/bin/env bash
set -euo pipefail

# Source ~/.config/dotfiles/env.sh from the POSIX shells' startup files, so
# zsh/bash/sh get the same CARGO_HOME, cache roots and PATH that fish gets from
# conf.d/10-environment.fish.
#
# These files are deliberately *not* stow-managed: rustup, SkillHub and Otty all
# append their own lines to them, and stowing would displace that. So append one
# guarded block instead, idempotently.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config/defaults.sh
source "${repo_root}/config/defaults.sh"

if [ -f "${repo_root}/local/env.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/env.sh"
fi

marker_begin="# >>> dotfiles shell env >>>"

# ~/.zshenv     — every zsh, including non-interactive `zsh -c`
# ~/.profile    — sh / login shells
# ~/.bashrc     — interactive bash (~/.bash_profile already sources it)
declare -a rc_files=(
  "${HOME}/.zshenv"
  "${HOME}/.profile"
  "${HOME}/.bashrc"
)

block="$(cat <<'EOF'
# >>> dotfiles shell env >>>
# Managed by dotfiles/scripts/install-shell-env.sh
# Edit stow/shellenv/.config/dotfiles/env.sh, not this block.
if [ -r "$HOME/.config/dotfiles/env.sh" ]; then
  . "$HOME/.config/dotfiles/env.sh"
fi
# <<< dotfiles shell env <<<
EOF
)"

install_block() {
  local rc_file="$1"

  if [ -f "${rc_file}" ] && grep -qF "${marker_begin}" "${rc_file}"; then
    echo "==> Shell env block already present: ${rc_file}"
    return 0
  fi

  # Keep whatever is already there — other installers own lines in these files.
  if [ -s "${rc_file}" ] && [ -n "$(tail -c 1 "${rc_file}")" ]; then
    printf '\n' >>"${rc_file}"
  fi
  printf '\n%s\n' "${block}" >>"${rc_file}"
  echo "==> Added shell env block to ${rc_file}"
}

for rc_file in "${rc_files[@]}"; do
  install_block "${rc_file}"
done

if [ ! -r "${HOME}/.config/dotfiles/env.sh" ]; then
  echo "WARN: ${HOME}/.config/dotfiles/env.sh is missing — run scripts/apply-stow.sh" >&2
fi

echo "==> Done. Open a new shell, then check: env | grep CARGO_HOME"
