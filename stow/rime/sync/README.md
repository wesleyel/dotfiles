# Rime 用户数据同步目录

本目录由鼠须管菜单 **「同步用户数据」** 写入，不由 GNU Stow 链接到 `~/Library/Rime`。

`sync_dir` 由 `./scripts/apply-stow.sh` 自动写入 `stow/rime/Library/Rime/installation.yaml`（一般为本仓库的 `stow/rime/sync` 绝对路径）。

## 布局

```text
sync/
└── <installation_id>/     # 来自 installation.yaml，每台设备可不同
    ├── *.userdb.txt       # 用户词频（建议纳入 Git）
    └── user.yaml          # 方案记忆、开关状态（建议纳入 Git）
```

`installation_id` 在 `stow/rime/Library/Rime/installation.yaml` 中配置。多台机器可共用同一 `sync_dir`，各自子目录互不覆盖；在任意一台设备上同步时，Rime 会合并各目录下的 `*.userdb.txt`。

## 工作流

### 1. 更新静态配置

```bash
./scripts/apply-stow.sh
```

然后：**鼠须管 → 重新部署**。

### 2. 导出用户词库到本仓库

在菜单栏点击 **鼠须管**（输入法图标），选择 **同步用户数据**。

也可先打开用户目录核对路径：**鼠须管 → 用户设定**（会打开 `~/Library/Rime`）。同步完成后，本仓库会出现或更新：

```text
stow/rime/sync/<installation_id>/rime_ice.userdb.txt
stow/rime/sync/<installation_id>/user.yaml
```

若同步失败（例如提示无法打开 `*.userdb`），先退出会占用词库的应用，或稍后重试；必要时可先 **重新部署** 再同步。

### 3. 提交到 Git

```bash
git add stow/rime/sync/
git commit -m "rime: sync user dictionary"
```

只提交 `*.userdb.txt` 与 `user.yaml` 即可，不要提交 `~/Library/Rime` 下的 `*.userdb/` 二进制目录。

### 4. 新机器 / 重装后恢复

1. `git clone` 本仓库并执行 `./scripts/apply-stow.sh`
2. **鼠须管 → 重新部署**
3. **鼠须管 → 同步用户数据**（把 `stow/rime/sync/` 中的文本词库合并进本地 `~/Library/Rime/*.userdb/`）

## 与 Stow 的分工

| 内容 | 方式 |
|------|------|
| `*.schema.yaml`、`default.yaml`、`squirrel*.yaml`、`lua/`、`cn_dicts/`（静态词库）等 | Stow → `~/Library/Rime` |
| `build/`、`*.userdb/`（二进制） | 留在 `~/Library/Rime`，不纳入 Git |
| `user.yaml`、`*.userdb.txt` | 菜单「同步用户数据」→ `stow/rime/sync/` |

Rime 同步**不会**备份 `cn_dicts/` 子目录内的大型静态词库；那些仍随 Stow 配置一起管理。
