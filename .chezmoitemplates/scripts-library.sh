# shellcheck shell=bash

set -euo pipefail

_OS="$(uname)"
if [[ "${_OS}" == "Darwin" ]]
then
  UNAME_MACHINE="$(/usr/bin/uname -m)"

  HOMEBREW_REPOSITORY_Arm64="/opt/homebrew"
  HOMEBREW_REPOSITORY_X86="/usr/local/Homebrew"

  if [[ "${UNAME_MACHINE}" == "arm64" ]]
  then
    # On ARM macOS, this script installs to /opt/homebrew only
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
  else
    # On Intel macOS, this script installs to /usr/local only
    HOMEBREW_PREFIX="/usr/local"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  fi
  HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"
  HOMEBREW_LOGS="${HOME}/Library/Logs/Homebrew"

  #获取Mac系统版本
  macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
else [[ "${_OS}" == "Darwin" ]]
then
  UNAME_MACHINE="$(uname -m)"

  # On Linux, this script installs to /home/linuxbrew/.linuxbrew only
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  HOMEBREW_CACHE="${HOME}/.cache/Homebrew"
  HOMEBREW_LOGS="${HOME}/.logs/Homebrew"
fi

# export homebrew mirror
export HOMEBREW_INSTALL_FROM_API=1
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

if [[ -n "${DOTFILES_DEBUG:-}" ]]; then
  set -x
fi

function ensure_path_entry() {
  local entries=("$@")

  for entry in "${entries[@]}"; do
    if [[ ":${PATH}:" != *":${entry}:"* ]]; then
      export PATH="${entry}:${PATH}"
    fi
  done
}

function log_color() {
  local color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

function log_red() {
  log_color "0;31" "$@"
}

function log_blue() {
  log_color "0;34" "$@"
}

function log_green() {
  log_color "1;32" "$@"
}

function log_yellow() {
  log_color "1;33" "$@"
}

function log_task() {
  log_blue "🔃" "$@"
}

function log_manual_action() {
  log_red "⚠️" "$@"
}

function log_c() {
  log_yellow "👉" "$@"
}

function c() {
  log_c "$@"
  "$@"
}

function c_exec() {
  log_c "$@"
  exec "$@"
}

function log_error() {
  log_red "❌" "$@"
}

function log_info() {
  log_blue "ℹ️" "$@"
}

function log_success() {
  log_green "✅" "$@"
}

function error() {
  log_error "$@"
  exit 1
}

function sudo() {
  local exec=false
  if [[ "$1" == "exec" ]]; then
    shift
    exec=true
  fi

  # shellcheck disable=SC2312
  if [[ "$(id -u)" -eq 0 ]]; then
    if [[ "${exec}" == "true" ]]; then
      exec "$@"
    else
      "$@"
    fi
  else
    if ! command sudo --non-interactive true 2>/dev/null; then
      log_manual_action "Root privileges are required, please enter your password below"
      command sudo --validate
    fi
    if [[ "${exec}" == "true" ]]; then
      exec sudo "$@"
    else
      command sudo "$@"
    fi
  fi
}

function is_apt_package_installed() {
  local package="$1"

  apt list --quiet --quiet --installed "${package}" 2>/dev/null | grep --quiet .
}

function not_during_test() {
  if [[ "${DOTFILES_TEST:-}" == "true" ]]; then
    log_info "Skipping '${*}' because we are in test mode"
  else
    "${@}"
  fi
}

# https://stackoverflow.com/a/53640320/12156188
function service_exists() {
  local n=$1
  if [[ $(systemctl list-units --all -t service --full --no-legend "${n}.service" | sed 's/^\s*//g' | cut -f1 -d' ') == ${n}.service ]]; then
    return 0
  else
    return 1
  fi
}