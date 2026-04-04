# nixconfig

从零重建的 `nix-darwin` 模板仓，目标是让这台 Apple Silicon Mac 在重置后能够用一套声明式配置恢复系统、CLI 工具、语言运行时和常用 GUI 应用。

## 设计边界

- `CLI / 语言运行时` 走 Nix
- `GUI / App` 走 Homebrew cask
- `home-manager` 只管理用户态配置和镜像设置
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
   sudo -H env HOME=/var/root \
     nix --extra-experimental-features "nix-command flakes" \
     run nix-darwin/master#darwin-rebuild -- switch --flake .#wesleydeMac-mini
   ```

3. 仅检查配置：

   ```bash
   nix --extra-experimental-features "nix-command flakes" flake check
   nix --extra-experimental-features "nix-command flakes" \
     run nix-darwin/master#darwin-rebuild -- build --flake .#wesleydeMac-mini
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
