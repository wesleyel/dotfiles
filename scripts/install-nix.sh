#!/usr/bin/env bash
set -euo pipefail

if command -v determinate-nixd >/dev/null 2>&1 || command -v nix >/dev/null 2>&1 || [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "Determinate Nix already installed"
  exit 0
fi

if [ "$#" -eq 0 ]; then
  set -- install --no-confirm
fi

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- "$@"
