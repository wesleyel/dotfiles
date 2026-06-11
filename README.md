# dotfiles

纯 macOS 的 Homebrew + GNU Stow 配置仓。目标是在 Apple Silicon Mac 上用一套可重复执行的脚本恢复 CLI 工具、语言运行时、GUI 应用、shell 配置、编辑器配置和常用系统 defaults，不再依赖 Nix、nix-darwin 或 home-manager。

## 设计边界

- 软件安装统一走 Homebrew：公式、cask、tap 都收敛到 Brewfile。
- 用户态配置统一走 GNU Stow：Fish、Git、GitHub CLI、Emacs、VS Code、Atuin、Rime、镜像配置都在 stow/ 下管理。
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
    ├── emacs
    ├── fish
    ├── gh
    ├── git
    ├── mirrors
    ├── rime
    ├── snipaste
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
- stow/emacs：`~/.emacs.d` 启动文件与 `lisp/` 模块；`elpa/`、`.emacs.desktop`、`rime/` 等运行态目录留在本机，不纳入 Stow。
- stow/mirrors：npm、bun、pip、cargo、pnpm 镜像与缓存配置。
- stow/vscode：VS Code 用户设置、快捷键和 HyperSnips 片段。
- stow/atuin：Atuin 配置。
- stow/rime：Rime 输入法静态配置（Stow）；用户词频与 `user.yaml` 经 Rime sync 写入 `stow/rime/sync/`。
- stow/snipaste：Snipaste 配置。

仓库根目录的 `.stowrc` 统一关闭目录折叠，并忽略 `.DS_Store` 之类的 macOS 噪音文件。这样 `~/.config/git` 这类目录会保持为真实目录，既方便增量接管，也避免本地覆盖文件被意外写回仓库。Rime 另做分层：Stow 只链接 schema、词库 YAML、Lua 等静态配置；`build/`、`*.userdb/` 留在 `~/Library/Rime`；`user.yaml` 与 `*.userdb.txt` 通过 `sync_dir`（`stow/rime/sync/`）由「同步用户数据」纳入 Git。详见 `stow/rime/sync/README.md`。Emacs 同理：`stow/emacs/.emacs.d/` 只包含 `init.el`、`lisp/`、`notes/` 等源码；`elpa/`、`.emacs.desktop`、`~/.emacs.d/rime/` 等运行态目录留在本机。

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
- local/fish.local.fish：追加交互式 Fish 配置，`./scripts/apply-stow.sh` 会自动把它链接到 ~/.config/fish/conf.d/90-local.fish。
- local/gitconfig.local：追加私有 Git 身份，`./scripts/apply-stow.sh` 会自动把它链接到 ~/.config/git/local.conf。
- local/macos-defaults.sh：追加机器专属的 defaults write 逻辑。

这些本地覆盖现在由 `scripts/apply-stow.sh` 统一按声明式映射处理：源文件缺失时自动跳过，目标路径已有旧文件时会先备份再接管。

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

先确认该文件是否来自旧手工配置。如果你要用仓库版本覆盖它，直接执行：

```bash
./scripts/apply-stow.sh
```

现在脚本会在 `stow` 报出“existing target is not owned by stow”冲突时，把旧文件移动到：

```bash
~/.local/state/dotfiles/stow-backups/<timestamp>/
```

备份后会自动重试并接管目标路径，因此第一次迁移通常不需要手工逐个清理。如果你想回滚，直接把备份目录里的文件移回原位置即可。

对 Rime 做了特殊处理：Stow 不接管 `build/`、`*.userdb/`、`user.yaml`。用户习惯词库在鼠须管菜单选择 **同步用户数据** 导出到 `stow/rime/sync/`，再把其中的 `*.userdb.txt` 与 `user.yaml` 提交到仓库（详见 `stow/rime/sync/README.md`）。

### 3. Fish 没有成为默认 shell

首次应用系统设置时脚本会尝试把 /opt/homebrew/bin/fish 写入 /etc/shells 并执行 chsh。如果你取消了权限授权，可以单独重跑：

```bash
./scripts/apply-macos-defaults.sh
```

### 4. 输入法列表没有刷新

Rime 资源链接后：

```bash
./scripts/apply-stow.sh
./scripts/apply-macos-defaults.sh
```

然后在鼠须管菜单 **重新部署**，需要备份词频时选择 **同步用户数据**。

新机器恢复时：先 `apply-stow.sh` 并重新部署，再 **同步用户数据**，以把 `stow/rime/sync/` 中的 `*.userdb.txt` 合并进本地 `*.userdb/`。

### 5. Emacs 配置

`stow/emacs/.emacs.d/` 由 dotfiles 统一管理；`~/.emacs.d` 不应再维护独立 Git 仓库。执行 `./scripts/apply-stow.sh` 后，`init.el`、`lisp/`、`notes/` 等源码会链接到仓库，`elpa/`、`.emacs.desktop`、`~/.emacs.d/rime/` 等运行态目录仍留在本机。若曾存在 `~/.emacs.d/.git`，确认 Stow 链接正常后删除即可。首次链接后启动 Emacs 会自动安装 `init-package.el` 中声明的包。
