# Rime / 鼠须管（本仓库）

静态配置在本目录，由 GNU Stow 链接到 `~/Library/Rime`。

用户造词、词频、`user.yaml` **不在此目录维护**，通过鼠须管 **「同步用户数据」** 写入 `stow/rime/sync/`。说明见 [sync/README.md](../../sync/README.md)。

## 日常操作

| 操作 | 方式 |
|------|------|
| 更新 schema、词库、皮肤等 | `./scripts/apply-stow.sh`，然后 **重新部署** |
| 备份 / 恢复输入习惯 | 菜单 **同步用户数据** |
| 打开配置目录 | **鼠须管 → 用户设定** |

雾凇拼音上游：https://github.com/iDvel/rime-ice
