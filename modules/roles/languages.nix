{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bun
    cargo
    go
    nodejs
    pnpm
    python3
    rustc
  ];
}
