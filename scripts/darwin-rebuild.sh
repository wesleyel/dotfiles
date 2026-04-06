#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hostname="wesleydeMac-mini"

nix_bin="$(command -v nix || true)"
if [ -z "$nix_bin" ] && [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  nix_bin="/nix/var/nix/profiles/default/bin/nix"
fi

if [ -z "$nix_bin" ]; then
  echo "ERROR: Nix binary not found. Install Determinate Nix first." >&2
  exit 1
fi

if [ -e /etc/nix/nix.custom.conf ] && [ ! -L /etc/nix/nix.custom.conf ]; then
  backup_path="/etc/nix/nix.custom.conf.before-nix-darwin"
  if [ -e "$backup_path" ]; then
    backup_path="${backup_path}.$(date +%Y%m%d-%H%M%S)"
  fi

  echo "==> Moving unmanaged /etc/nix/nix.custom.conf to ${backup_path}"
  sudo mv /etc/nix/nix.custom.conf "$backup_path"
fi

sudo -H git config --global --add safe.directory "$repo_root"

sudo -H env HOME=/var/root \
  "$nix_bin" --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- "$@" --flake "${repo_root}#${hostname}"