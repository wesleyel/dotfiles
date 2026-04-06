# nixconfig

纯 macOS 的 Homebrew + GNU Stow 配置仓。目标是在 Apple Silicon Mac 上用一套可重复执行的脚本恢复 CLI 工具、语言运行时、GUI 应用、shell 配置、编辑器配置和常用系统 defaults，不再依赖 Nix、nix-darwin 或 home-manager。

## 设计边界

- 软件安装统一走 Homebrew：公式、cask、tap 都收敛到 Brewfile。
- 用户态配置统一走 GNU Stow：Fish、Git、GitHub CLI、VS Code、Atuin、Rime、镜像配置都在 stow/ 下管理。
- macOS 系统设置统一走脚本：键盘、滚动方向、输入法和默认 shell 都由 scripts/apply-macos-defaults.sh 处理。
- 私有覆盖保留在 local/：仅在本机使用，不提交到仓库。
- 默认启用中国大陆镜像，但允许本地覆盖。

## 目录结构

```text
.
├── Brewfile
├── config
│   └── defaults.sh
├── local
├── scripts
└── stow
    ├── atuin
    ├── fish
    ├── gh
    ├── git
    ├── mirrors
    ├── rime
    └── vscode
```

## 快速开始

首次引导：

```bash
./scripts/bootstrap.sh
```

这个入口会依次完成：

1. 检查并等待 Xcode Command Line Tools。
2. 安装 Homebrew。
3. 根据 Brewfile 安装公式、tap 和 cask。
4. 用 GNU Stow 链接 dotfiles。
5. 应用 macOS defaults 并把默认 shell 切到 Homebrew Fish。

后续日常更新：

```bash
./scripts/install-packages.sh
./scripts/apply-stow.sh
./scripts/apply-macos-defaults.sh
```

## Stow 包

- stow/fish：Fish 环境变量、abbreviations、direnv、zoxide、atuin 初始化。
- stow/git：Git 身份、别名、LFS 和默认行为。
- stow/gh：GitHub CLI 基础配置。
- stow/mirrors：npm、bun、pip、cargo、pnpm 镜像与缓存配置。
- stow/vscode：VS Code 用户设置和快捷键。
- stow/atuin：Atuin 配置。
- stow/rime：Rime 输入法配置。

## 本地覆盖

私有信息不要提交。按需复制这些模板：

- local/env.sh.example -> local/env.sh
- local/Brewfile.example -> local/Brewfile
- local/fish.local.fish.example -> local/fish.local.fish
- local/gitconfig.local.example -> local/gitconfig.local
- local/macos-defaults.sh.example -> local/macos-defaults.sh

约定如下：

- local/env.sh：覆盖 scripts 和 Homebrew 用到的环境变量与镜像地址。
- local/Brewfile：安装本机私有公式和 cask。
- local/fish.local.fish：追加交互式 Fish 配置，脚本会把它链接到 ~/.config/fish/conf.d/90-local.fish。
- local/gitconfig.local：追加私有 Git 身份，脚本会把它链接到 ~/.config/git/local.conf。
- local/macos-defaults.sh：追加机器专属的 defaults write 逻辑。

## 镜像策略

- Homebrew：TUNA API、bottles 和 git remote。
- npm / pnpm / bun：npmmirror。
- pip：TUNA PyPI。
- Cargo：TUNA sparse index。
- Go：goproxy.cn,direct。

注意：Homebrew cask 的实际安装包通常仍来自应用作者自己的上游地址，因此 GUI 下载只能做到尽力加速。

## 故障排查

### 1. brew bundle 找不到 brew

先运行：

```bash
./scripts/install-homebrew.sh
```

如果 Homebrew 已安装在 /opt/homebrew，脚本会自动复用它。

### 2. Stow 报目标文件已存在

先确认该文件是否来自旧手工配置。如果你要用仓库版本覆盖它，手动备份后再执行：

```bash
./scripts/apply-stow.sh
```

现在脚本会自动把这些“不是 Stow 创建的旧文件”移动到 `~/.local/share/nixconfig-backups/stow-时间戳/`，再重新执行链接，因此第一次迁移时不需要手工逐个清理。

对 Rime 做了特殊处理：仓库不会再尝试接管 `build/` 和 `rime_ice.userdb/` 这类运行时产物，避免把编译缓存和用户词频当成受管配置。

### 3. Fish 没有成为默认 shell

首次应用系统设置时脚本会尝试把 /opt/homebrew/bin/fish 写入 /etc/shells 并执行 chsh。如果你取消了权限授权，可以单独重跑：

```bash
./scripts/apply-macos-defaults.sh
```

### 4. 输入法列表没有刷新

Rime 资源链接后，重新运行系统设置脚本并注销一次当前会话：

```bash
./scripts/apply-stow.sh
./scripts/apply-macos-defaults.sh
```
