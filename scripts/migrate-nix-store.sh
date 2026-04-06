#!/usr/bin/env bash
# migrate-nix-store.sh
# 将已安装的 Nix store 从内置盘迁移到外置 APFS 硬盘（通过 fstab 挂载到 /nix）
#
# 前提条件：
#   1. Nix 已在内置盘安装完毕（/nix 存在且健康）
#   2. 外置 APFS 磁盘已接入，对应 volume 挂载于 /Volumes/APFS
#   3. 以普通用户执行（脚本内部按需使用 sudo）
set -euo pipefail

# ── 参数配置 ─────────────────────────────────────────────────────────────────
EXTERNAL_BASE_VOLUME="/Volumes/APFS"  # 外置盘上已存在的 APFS volume（用于获取磁盘 ID）
NEW_VOLUME_NAME="Nix Store"           # 将要创建的新 APFS volume 名称
NEW_VOLUME_QUOTA="200g"               # 配额（可调整）
FSTAB="/etc/fstab"

nix_src="/nix"
nix_dst="/Volumes/${NEW_VOLUME_NAME}"

# ── 检查前提 ──────────────────────────────────────────────────────────────────
if [ ! -d "$nix_src/store" ]; then
  echo "ERROR: $nix_src/store not found. Please install Nix first." >&2
  exit 1
fi

if [ ! -d "$EXTERNAL_BASE_VOLUME" ]; then
  echo "ERROR: External volume $EXTERNAL_BASE_VOLUME not found. Please connect the external disk." >&2
  exit 1
fi

# ── Step 1: 找到外置盘的磁盘标识符 ──────────────────────────────────────────
echo "==> Detecting external disk..."
part_of_whole="$(diskutil info "$EXTERNAL_BASE_VOLUME" | awk '/Part of Whole:/{print $NF}')"
if [ -z "$part_of_whole" ]; then
  echo "ERROR: Could not determine disk identifier for $EXTERNAL_BASE_VOLUME" >&2
  exit 1
fi
disk_id="/dev/${part_of_whole}"
echo "    External disk: $disk_id"

# ── Step 2: 检查是否已有名为 "Nix Store" 的 volume ──────────────────────────
if diskutil info "$nix_dst" &>/dev/null; then
  echo "==> APFS volume '${NEW_VOLUME_NAME}' already exists at $nix_dst, skipping creation."
else
  echo "==> Creating APFS volume '${NEW_VOLUME_NAME}' on $disk_id (quota: ${NEW_VOLUME_QUOTA})..."
  sudo diskutil apfs addVolume "$part_of_whole" APFS "$NEW_VOLUME_NAME" -quota "$NEW_VOLUME_QUOTA"
fi

# ── Step 3: 重挂以启用 owners（权限所有权支持）────────────────────────────
echo "==> Remounting '${NEW_VOLUME_NAME}' with owners support..."
vol_dev="$(diskutil info "$nix_dst" | awk '/Device Node:/{print $NF}')"
sudo diskutil unmount "$nix_dst"
sudo diskutil mount -mountOptions owners "$vol_dev"

# ── Step 4: 获取 UUID（用于 fstab）────────────────────────────────────────
vol_uuid="$(diskutil info "$nix_dst" | awk '/Volume UUID:/{print $NF}')"
echo "    Volume UUID: $vol_uuid"

# ── Step 5: 停止 Nix 相关 daemon ────────────────────────────────────────────
echo "==> Stopping Nix daemons..."
sudo launchctl bootout system/org.nixos.nix-daemon 2>/dev/null || true
sudo pkill -x determinate-nixd 2>/dev/null || true
sudo pkill -x nix-daemon 2>/dev/null || true

# ── Step 6: 同步数据 ─────────────────────────────────────────────────────────
echo "==> Syncing $nix_src -> $nix_dst (this may take a while)..."
sudo rsync -aHE --progress "$nix_src/store"     "$nix_dst/"
sudo rsync -aHE --progress "$nix_src/var"       "$nix_dst/"
for f in .nix-installer-hook.* nix-installer receipt.json; do
  [ -e "$nix_src/$f" ] && sudo cp "$nix_src/$f" "$nix_dst/" || true
done

# ── Step 7: 修正 store 目录权限（nixbld 组需要 1775）────────────────────
echo "==> Fixing store directory permissions..."
sudo chgrp nixbld "$nix_dst/store"
sudo chmod 1775  "$nix_dst/store"

# ── Step 8: 更新 /etc/fstab ──────────────────────────────────────────────────
fstab_entry="UUID=${vol_uuid} /nix apfs rw,noatime,nobrowse,nosuid,owners"
echo "==> Updating $FSTAB..."
sudo cp "$FSTAB" "${FSTAB}.backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true

# 移除旧的 /nix 行（如果有）
sudo sed -i '' '/[[:space:]]\/nix[[:space:]]/d' "$FSTAB"
# 追加新行
printf '%s\n' "$fstab_entry" | sudo tee -a "$FSTAB" >/dev/null
echo "    Added: $fstab_entry"

# ── Step 9: 提示重启 ──────────────────────────────────────────────────────────
cat <<'EOF'

==> Migration complete!

Next steps:
  1. Reboot the machine:
       sudo reboot
  2. After reboot, the external volume will mount at /nix automatically.
    3. If macOS blocks access to the external /nix volume, enable Full Disk Access for Determinate Nixd in:
       System Settings → Privacy & Security → Full Disk Access
    Add: /usr/local/bin/determinate-nixd
  4. Verify the store:
       mount | grep /nix
       nix-env --version
    5. Reinitialize Determinate Nix if needed:
      sudo determinate-nixd init

The old /nix on the internal disk is still intact. Once verified, you may
reclaim the space with:
  sudo rm -rf /nix   # only after confirming the external store works!
EOF
