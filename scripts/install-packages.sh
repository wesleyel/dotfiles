#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../config/defaults.sh
source "${repo_root}/config/defaults.sh"

if [ -f "${repo_root}/local/env.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/env.sh"
fi

brew_bin="$(command -v brew || true)"
if [ -z "${brew_bin}" ] && [ -x /opt/homebrew/bin/brew ]; then
  brew_bin="/opt/homebrew/bin/brew"
fi

if [ -z "${brew_bin}" ]; then
  echo "ERROR: Homebrew is not installed yet." >&2
  exit 1
fi

"${brew_bin}" bundle --file "${repo_root}/Brewfile"

if [ -f "${repo_root}/local/Brewfile" ]; then
  "${brew_bin}" bundle --file "${repo_root}/local/Brewfile"
fi