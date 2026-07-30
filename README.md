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
    ├── shellenv
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
5. 把跨 shell 环境变量写入 ~/.zshenv、~/.profile、~/.bashrc。
6. 应用 macOS defaults 并把默认 shell 切到 Homebrew Fish。

后续日常更新：

```bash
./scripts/install-packages.sh
./scripts/apply-stow.sh
./scripts/install-shell-env.sh
./scripts/apply-macos-defaults.sh
```

## Stow 包

- stow/fish：Fish 环境变量、abbreviations、direnv、zoxide、atuin 初始化。
- stow/git：Git 身份、别名、LFS 和默认行为。
- stow/gh：GitHub CLI 基础配置。
- stow/emacs：`~/.emacs.d` 启动文件与 `lisp/` 模块；`elpa/`、`.emacs.desktop`、`rime/` 等运行态目录留在本机，不纳入 Stow。
- stow/mirrors：npm、bun、pip、cargo、pnpm 镜像与缓存配置。
- stow/shellenv：非 fish shell（zsh/bash/sh）的环境变量与 PATH，见下节。
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

## 跨 shell 环境

日常 shell 是 Fish，但 zsh / bash / `sh -c`（编辑器任务、agent、launchd、各种安装脚本）同样要看到一致的环境。所以缓存目录、`CARGO_HOME` / `GOMODCACHE` / `PNPM_HOME` 和 PATH 追加有两份实现，必须同步修改：

- `stow/fish/.config/fish/conf.d/10-environment.fish`：Fish。
- `stow/shellenv/.config/dotfiles/env.sh`：POSIX shell。由 `scripts/install-shell-env.sh` 以带标记的代码块追加到 `~/.zshenv`、`~/.profile`、`~/.bashrc`（这三个文件不走 Stow：rustup、SkillHub、Otty 都往里写过东西，Stow 接管会把它们挤掉）。`config/defaults.sh` 也 source 这一份，脚本与 shell 因此共用同一处定义。

缓存目录都放在 `$DOTFILES_CACHE_ROOT` 下（cargo、rustup、go、homebrew）：系统盘是紧张的那块，rustup 工具链单独就有 1.7G。

为什么必须显式导出 `CARGO_HOME`：rustup 生成的 `$CARGO_HOME/env` 只往 PATH 前面插 `$CARGO_HOME/bin`，从不导出 `CARGO_HOME`。少了这一行的 shell 会用「对的 cargo 二进制 + 错的 cargo home」：

- `cargo install` 装到 `~/.cargo/bin`，而 PATH 上更靠前的 `$CARGO_HOME/bin` 里往往还留着旧版本，于是命令行跑的一直是旧的。
- registry 缓存在 `~/.cargo` 下重下一份（几百 MB）。
- `$CARGO_HOME/config.toml`（crates.io 镜像）读不到。

`RUSTUP_HOME` 的失败方式比 `CARGO_HOME` 更硬：读不到就直接 "no default toolchain"，而不是安静地建第二份。非交互 `bash -c` / `sh -c` 不读任何 rc 文件，GUI 应用（Finder 启动）更是完全没有 shell 环境，所以 `scripts/apply-stow.sh` 额外把 `~/.rustup` 链接到 `$RUSTUP_HOME`，让没有环境变量的路径也能落到同一份工具链。

`env.sh` 里 PATH 的写法是「先按倒序 prepend，再去重保留首次出现」，而不是「已存在就跳过」：这样即便 `~/.zshenv` 里 rustup 那行先执行过，最终优先级仍由这份文件决定，重复 source 也不会让 PATH 变长。

校验：

```bash
env -i HOME="$HOME" zsh -c 'echo $CARGO_HOME; echo $PATH | tr : "\n" | head -3'
```

## 镜像策略

- Homebrew：TUNA API、bottles 和 git remote。
- npm / pnpm / bun：npmmirror。
- pip：TUNA PyPI。
- Cargo：TUNA sparse index。注意 cargo 只无条件读取 `$CARGO_HOME/config.toml`，`~/.cargo/config.toml` 要靠「从 cwd 逐级向上找 .cargo/」才会命中，因此 `$HOME` 以外的项目（也就是整个代码卷）根本读不到它。`scripts/apply-stow.sh` 会把同一份配置额外链接到 `$CARGO_HOME/config.toml`。
- Go：goproxy.cn,direct。

工具链与缓存位置：`CARGO_HOME=$DOTFILES_CACHE_ROOT/cargo`、`RUSTUP_HOME=$DOTFILES_CACHE_ROOT/rustup`。`~/.rustup` 是指向后者的软链接；`~/.cargo` 只保留 Stow 链接过去的 `config.toml`。

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
