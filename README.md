# nixconfig

从零重建的 `nix-darwin` 模板仓，目标是让这台 Apple Silicon Mac 在重置后能够用一套声明式配置恢复系统、CLI 工具、语言运行时和常用 GUI 应用。

## 设计边界

- `CLI / 语言运行时` 走 Nix
- `GUI / App` 走 Homebrew cask
- `home-manager` 只管理用户态配置和镜像设置
- Nix 通过 Determinate Systems 安装器提供，`nix-darwin` 不接管 Nix daemon 和 `nix.*` 模块选项
- 额外 Nix 配置由 `nix-darwin` 写入 `/etc/nix/nix.custom.conf`
- 默认启用中国大陆镜像，但保留项目级覆盖能力

## 目录结构

```text
.
├── flake.nix
├── hosts/darwin/wesleydeMac-mini
├── home
│   └── modules
├── local
├── modules
│   ├── regions
│   └── roles
└── scripts
```

## 快速开始

1. 首次引导：

   ```bash
   ./scripts/bootstrap.sh
   ```

2. 后续应用配置：

   ```bash
  ./scripts/darwin-rebuild.sh switch
  ```

  这个脚本会自动：

  - 检测 Determinate 安装出来的 `nix`
  - 迁移阻塞激活的 `/etc/nix/nix.custom.conf`
  - 调用 `darwin-rebuild`

3. 仅检查配置：

   ```bash
  /nix/var/nix/profiles/default/bin/nix flake check
  ./scripts/darwin-rebuild.sh build
   ```

## 本地覆盖

私有信息不要提交到仓库里。按需创建以下文件：

- `local/darwin.nix`
- `local/home.nix`

可以参考：

- `local/darwin.example.nix`
- `local/home.example.nix`

适合放入本地覆盖层的内容：

- Git 身份
- 私有 registry / scope
- 公司专用环境变量
- 个人 SSH / 1Password 细节

## 镜像策略

- Nix：TUNA + SJTUG + 官方缓存回退
- npm / pnpm / bun：`npmmirror`
- pip：TUNA PyPI
- Cargo：TUNA sparse index
- Go：`goproxy.cn,direct`
- Homebrew：TUNA API / bottles / git remote

注意：Homebrew cask 的实际安装包往往仍来自应用作者自己的上游地址，因此 GUI 下载只能做到“尽力加速”，无法保证每个 App 都有国内镜像。

## 故障排查

### 1. 首次 `nix run` 报 `nix-command` / `flakes` 未启用

Determinate 一般已经启用这些能力。如果只是当前 shell 还找不到 `nix`，优先直接用仓库脚本或绝对路径：

```bash
./scripts/darwin-rebuild.sh switch
```

### 2. 报 `cannot connect to socket at /nix/var/nix/daemon-socket/socket`

这通常表示 Determinate 的后台服务没有正常初始化。先检查：

```bash
determinate-nixd version
sudo determinate-nixd init
```

### 3. 报 `Unexpected files in /etc` 且目标是 `/etc/nix/nix.custom.conf`

这是 Determinate 安装器留下的未托管文件阻止了 nix-darwin 接管。仓库脚本会自动把它迁移成备份文件；直接执行：

```bash
./scripts/darwin-rebuild.sh switch
```
