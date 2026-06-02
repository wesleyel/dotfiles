#!/usr/bin/env bash
# Point Rime sync_dir at this repo and migrate user-local files out of stow symlinks.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rime_repo="${repo_root}/stow/rime/Library/Rime"
rime_user="${HOME}/Library/Rime"
sync_dir="${repo_root}/stow/rime/sync"
installation_yaml="${rime_repo}/installation.yaml"

if [ ! -d "${rime_user}" ]; then
  echo "==> Skipping Rime sync setup: ${rime_user} does not exist"
  exit 0
fi

mkdir -p "${sync_dir}"

if [ ! -f "${installation_yaml}" ]; then
  echo "ERROR: ${installation_yaml} not found. Run apply-stow.sh first." >&2
  exit 1
fi

# sync_dir lives in the stowed installation.yaml (symlinked from ~/Library/Rime).
escaped_sync_dir="${sync_dir//\\/\\\\}"
if grep -q '^sync_dir:' "${installation_yaml}"; then
  sed -i '' "s|^sync_dir:.*|sync_dir: \"${escaped_sync_dir}\"|" "${installation_yaml}"
else
  printf '\nsync_dir: "%s"\n' "${sync_dir}" >>"${installation_yaml}"
fi
echo "==> Rime sync_dir -> ${sync_dir}"

migrate_symlink_to_file() {
  local path="$1"
  if [ ! -e "${path}" ] && [ ! -L "${path}" ]; then
    return 0
  fi
  if [ -L "${path}" ]; then
    local tmp
    tmp="$(mktemp)"
    cp -L "${path}" "${tmp}" 2>/dev/null || cp "${path}" "${tmp}"
    rm "${path}"
    cp "${tmp}" "${path}"
    rm "${tmp}"
    echo "==> Migrated ${path} from stow symlink to local file"
  fi
}

migrate_symlink_to_file "${rime_user}/user.yaml"

# userdb must stay under ~/Library/Rime as real directories, never stowed.
find "${rime_user}" -maxdepth 1 -name '*.userdb' -type l 2>/dev/null | while read -r link; do
  echo "WARN: Unexpected userdb symlink ${link}; replace with a real directory." >&2
done
