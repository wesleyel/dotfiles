# POSIX shell environment — the non-fish half of the cache/PATH contract.
#
# Fish sets the same variables in
# stow/fish/.config/fish/conf.d/10-environment.fish; keep the two in step.
# config/defaults.sh sources this file, so the install scripts agree too.
#
# Wired into ~/.zshenv, ~/.profile and ~/.bashrc by scripts/install-shell-env.sh.
# Must stay POSIX sh and side-effect free: it runs in every zsh, including
# non-interactive ones.

# The volume root is the single override knob (local/env.sh, or the environment).
# The cache root is always derived from it: these variables are exported, so a
# `:-` default there would let a stale inherited value outrank a new volume root.
DOTFILES_VOLUME_ROOT="${DOTFILES_VOLUME_ROOT:-/Volumes/APFS}"
DOTFILES_CACHE_ROOT="${DOTFILES_VOLUME_ROOT}/cache"
export DOTFILES_VOLUME_ROOT DOTFILES_CACHE_ROOT

# CARGO_HOME has to be exported in *every* shell, not just fish. rustup's
# $CARGO_HOME/env only prepends $CARGO_HOME/bin to PATH — it never exports
# CARGO_HOME — so a shell that misses this line runs the right cargo against
# the wrong home: `cargo install` lands in ~/.cargo/bin (shadowed by the older
# copy in $CARGO_HOME/bin, which comes first on PATH), the registry cache is
# downloaded a second time under ~/.cargo, and $CARGO_HOME/config.toml — the
# crates.io mirror — is never read.
export CARGO_HOME="${DOTFILES_CACHE_ROOT}/cargo"
# Toolchains are ~1.7G and the internal disk is the scarce one. A missing
# RUSTUP_HOME breaks cargo outright ("no default toolchain") rather than
# silently duplicating like CARGO_HOME does, so apply-stow.sh also leaves a
# ~/.rustup symlink pointing here — contexts with no shell env still work.
export RUSTUP_HOME="${DOTFILES_CACHE_ROOT}/rustup"
export GOMODCACHE="${DOTFILES_CACHE_ROOT}/go"
export HOMEBREW_CACHE="${DOTFILES_CACHE_ROOT}/homebrew"
export PNPM_HOME="${DOTFILES_VOLUME_ROOT}/pnpm"

# Prepend in reverse of the order you want, then drop later duplicates. Doing it
# in that order — rather than skipping entries already on PATH — means this file
# decides the precedence even though rustup's $CARGO_HOME/env line above it in
# ~/.zshenv has already prepended $CARGO_HOME/bin. Two dirs holding the same
# binary (a cargo-installed tool also copied to ~/.local/bin) then resolve the
# same way in every shell. Dropping duplicates also makes re-sourcing — a login
# shell inside a login shell, tmux — a no-op instead of growing PATH.
_dotfiles_prepend_path() {
  if [ -d "$1" ]; then
    PATH="$1:${PATH}"
  fi
  return 0
}

# Walk PATH by trimming the string rather than `for x in $PATH` with IFS=: —
# zsh does not word-split unquoted parameters, so the IFS version is a silent
# no-op there. Keeps the first occurrence of each entry; drops empty ones.
_dotfiles_dedupe_path() {
  _dotfiles_rest="${PATH}:"
  _dotfiles_out=""
  while [ -n "${_dotfiles_rest}" ]; do
    _dotfiles_entry="${_dotfiles_rest%%:*}"
    _dotfiles_rest="${_dotfiles_rest#*:}"
    if [ -z "${_dotfiles_entry}" ]; then
      continue
    fi
    case ":${_dotfiles_out}:" in
      *:"${_dotfiles_entry}":*) continue ;;
    esac
    if [ -z "${_dotfiles_out}" ]; then
      _dotfiles_out="${_dotfiles_entry}"
    else
      _dotfiles_out="${_dotfiles_out}:${_dotfiles_entry}"
    fi
  done
  PATH="${_dotfiles_out}"
  unset _dotfiles_rest _dotfiles_out _dotfiles_entry
  return 0
}

_dotfiles_prepend_path "${HOME}/.local/bin"
_dotfiles_prepend_path "${PNPM_HOME}"
_dotfiles_prepend_path "${CARGO_HOME}/bin"
_dotfiles_dedupe_path
export PATH

unset -f _dotfiles_prepend_path _dotfiles_dedupe_path
