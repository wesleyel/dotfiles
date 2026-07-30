#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# For CARGO_HOME: this script may run from a shell that never exported it.
# shellcheck source=../config/defaults.sh
source "${repo_root}/config/defaults.sh"
if [ -f "${repo_root}/local/env.sh" ]; then
  # shellcheck source=/dev/null
  source "${repo_root}/local/env.sh"
fi
stow_root="${repo_root}/stow"
state_root="${XDG_STATE_HOME:-${HOME}/.local/state}/dotfiles"
backup_root="${state_root}/stow-backups"
backup_session_dir=""

declare -a local_links=(
  "local/fish.local.fish:.config/fish/conf.d/90-local.fish"
  "local/gitconfig.local:.config/git/local.conf"
)

mapfile -t packages < <(find "${stow_root}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

if [ "${#packages[@]}" -eq 0 ]; then
  echo "ERROR: No stow packages found in ${stow_root}." >&2
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU Stow is not installed. Run scripts/install-packages.sh first." >&2
  exit 1
fi

resolve_link_target() {
  local link_path="$1"
  local raw_target
  local link_dir

  raw_target="$(readlink "${link_path}")"
  if [[ "${raw_target}" == /* ]]; then
    printf '%s\n' "${raw_target}"
    return
  fi

  link_dir="$(cd "$(dirname "${link_path}")" && pwd)"
  printf '%s\n' "${link_dir}/${raw_target}"
}

is_managed_symlink() {
  local target_path="$1"
  local resolved_target

  if [ ! -L "${target_path}" ]; then
    return 1
  fi

  resolved_target="$(resolve_link_target "${target_path}")"
  case "${resolved_target}" in
    "${stow_root}"/*|"${repo_root}"/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_safe_relative_path() {
  local relative_path="$1"

  case "${relative_path}" in
    ""|"/"|"."|"./"*|".."|"../"*|*"/.."|*"/../"* )
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

ensure_backup_session_dir() {
  if [ -n "${backup_session_dir}" ]; then
    return
  fi

  backup_session_dir="${backup_root}/$(date '+%Y%m%d-%H%M%S')"
  mkdir -p "${backup_session_dir}"
  echo "==> Backing up displaced targets under ${backup_session_dir}"
}

backup_target() {
  local relative_path="$1"
  local reason="$2"
  local target_path="${HOME}/${relative_path}"
  local backup_path

  if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
    return 0
  fi

  if ! is_safe_relative_path "${relative_path}"; then
    echo "WARN: Refusing to move unsafe path ${relative_path}" >&2
    return 1
  fi

  if is_managed_symlink "${target_path}"; then
    echo "==> Keeping managed link ${relative_path}"
    return 0
  fi

  ensure_backup_session_dir
  backup_path="${backup_session_dir}/${relative_path}"
  mkdir -p "$(dirname "${backup_path}")"
  mv "${target_path}" "${backup_path}"
  echo "==> Backed up ${reason}: ${relative_path} -> ${backup_path}"
}

collect_conflicts() {
  local output_file="$1"

  sed -n \
    -e 's/^  \* existing target is not owned by stow: //p' \
    -e 's/^  \* cannot stow .* over existing target \(.*\) since neither a link nor a directory and --adopt not specified$/\1/p' \
    "${output_file}" | sort -u
}

print_conflict_summary() {
  local -a conflicts=("$@")
  local relative_path

  echo "==> Detected ${#conflicts[@]} unmanaged target(s); moving them aside and retrying"
  for relative_path in "${conflicts[@]}"; do
    echo "    - ${relative_path}"
  done
}

run_stow_once() {
  local output_file
  local -a conflicts

  output_file="$(mktemp)"

  if (
    cd "${repo_root}" &&
    stow --dir "${stow_root}" --target "${HOME}" --restow "${packages[@]}"
  ) >"${output_file}" 2>&1; then
    rm -f "${output_file}"
    return 0
  fi

  mapfile -t conflicts < <(collect_conflicts "${output_file}")

  if [ "${#conflicts[@]}" -eq 0 ]; then
    cat "${output_file}" >&2
    rm -f "${output_file}"
    return 1
  fi

  print_conflict_summary "${conflicts[@]}"
  rm -f "${output_file}"

  for relative_path in "${conflicts[@]}"; do
    backup_target "${relative_path}" "stow conflict"
  done

  return 2
}

apply_stow_packages() {
  local attempts=0
  local status

  while true; do
    attempts=$((attempts + 1))
    if run_stow_once; then
      echo "==> Stow packages linked: ${packages[*]}"
      return 0
    else
      status="$?"
    fi

    if [ "${status}" -ne 2 ]; then
      return "${status}"
    fi

    if [ "${attempts}" -ge 5 ]; then
      echo "ERROR: Stow still reports unmanaged conflicts after ${attempts} attempts." >&2
      return 1
    fi
  done
}

link_declared_file() {
  local source_rel="$1"
  local target_rel="$2"
  local source_path="${repo_root}/${source_rel}"
  local target_path="${HOME}/${target_rel}"

  if [ ! -f "${source_path}" ]; then
    return 0
  fi

  if [ -L "${target_path}" ] && [ "$(resolve_link_target "${target_path}")" = "${source_path}" ]; then
    echo "==> Local link already up to date: ${target_rel}"
    return 0
  fi

  if [ -e "${target_path}" ] || [ -L "${target_path}" ]; then
    backup_target "${target_rel}" "local override"
  fi

  mkdir -p "$(dirname "${target_path}")"
  ln -sfn "${source_path}" "${target_path}"
  echo "==> Linked local override ${source_rel} -> ${target_rel}"
}

apply_local_links() {
  local entry
  local source_rel
  local target_rel

  for entry in "${local_links[@]}"; do
    source_rel="${entry%%:*}"
    target_rel="${entry#*:}"
    link_declared_file "${source_rel}" "${target_rel}"
  done
}

# Cargo reads $CARGO_HOME/config.toml unconditionally, but only finds a
# .cargo/config.toml by walking up from the cwd — so the stowed ~/.cargo copy is
# invisible to every project outside $HOME (i.e. all of the code volume), and
# those builds silently bypass the crates.io mirror. Link it into $CARGO_HOME,
# which lives outside $HOME and so is out of stow's reach.
link_cargo_config() {
  local source_path="${stow_root}/mirrors/.cargo/config.toml"
  local cargo_home="${CARGO_HOME:-${HOME}/.cargo}"
  local target_path="${cargo_home}/config.toml"

  if [ ! -f "${source_path}" ]; then
    return 0
  fi

  if [ -L "${target_path}" ] && [ "$(resolve_link_target "${target_path}")" = "${source_path}" ]; then
    echo "==> Cargo config already linked: ${target_path}"
    return 0
  fi

  if [ -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
    echo "WARN: ${target_path} exists and is not a link — leaving it alone" >&2
    return 0
  fi

  mkdir -p "${cargo_home}"
  ln -sfn "${source_path}" "${target_path}"
  echo "==> Linked cargo config -> ${target_path}"
}

# rustup toolchains live on the code volume, but a context with no shell env
# (a GUI app, `bash -c`) falls back to ~/.rustup and would then fail with "no
# default toolchain" — unlike cargo, which merely duplicates. Point ~/.rustup at
# $RUSTUP_HOME so both routes reach the same toolchains.
link_rustup_home() {
  local rustup_home="${RUSTUP_HOME:-}"
  local target_path="${HOME}/.rustup"

  if [ -z "${rustup_home}" ] || [ "${rustup_home}" = "${target_path}" ]; then
    return 0
  fi

  if [ -L "${target_path}" ] && [ "$(resolve_link_target "${target_path}")" = "${rustup_home}" ]; then
    echo "==> rustup home already linked: ${target_path}"
    return 0
  fi

  if [ -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
    echo "WARN: ${target_path} is a real directory — move it to ${rustup_home} first" >&2
    return 0
  fi

  mkdir -p "${rustup_home}"
  ln -sfn "${rustup_home}" "${target_path}"
  echo "==> Linked rustup home -> ${target_path}"
}

apply_stow_packages
apply_local_links
link_cargo_config
link_rustup_home

if [ -d "${stow_root}/emacs" ]; then
  # Stow skips dotfiles inside packages; link .gitignore explicitly.
  link_declared_file "stow/emacs/.emacs.d/.gitignore" ".emacs.d/.gitignore"
fi

if [ -d "${stow_root}/rime" ]; then
  "${repo_root}/scripts/configure-rime-sync.sh"
fi
