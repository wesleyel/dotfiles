#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Step 0: Xcode Command Line Tools ─────────────────────────────────────────
# git / clang / make 等工具都依赖 CLT，必须在一切操作之前确保其已安装。
# xcode-select --install 会弹出系统 GUI 对话框，脚本在此轮询等待用户完成安装。
if ! xcode-select -p &>/dev/null; then
  echo "==> Xcode Command Line Tools not found, requesting install..."
  xcode-select --install 2>/dev/null || true
  echo "==> A system dialog has appeared — please click 'Install' and wait for it to finish."
  echo "    This script will continue automatically once the installation completes."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo "==> Xcode Command Line Tools installed."
else
  echo "==> Xcode Command Line Tools already installed at $(xcode-select -p)"
fi
# ─────────────────────────────────────────────────────────────────────────────

"${repo_root}/scripts/install-homebrew.sh"
"${repo_root}/scripts/install-nix.sh"
"${repo_root}/scripts/darwin-rebuild.sh" switch
