{ ... }:
{
  homebrew.brews = [
    "bun"
    "go"
    "node"
    "pnpm"
    "python"
    "rust"
  ];

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
}
