#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../config/defaults.sh
source "${repo_root}/config/defaults.sh"

if [ -f "${repo_root}/local/env.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/env.sh"
fi

if command -v brew >/dev/null 2>&1; then
  echo "homebrew already installed"
  exit 0
fi

git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git /tmp/brew-install
/bin/bash /tmp/brew-install/install.sh
rm -rf /tmp/brew-install
