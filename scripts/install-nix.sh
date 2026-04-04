#!/usr/bin/env bash
set -euo pipefail

if command -v nix >/dev/null 2>&1; then
  echo "nix already installed"
  exit 0
fi

if [ "$#" -eq 0 ]; then
  set -- --daemon --yes
fi

sh <(curl --proto '=https' --tlsv1.2 -L https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install) "$@"
