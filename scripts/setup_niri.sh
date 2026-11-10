#!/usr/bin/env bash
set -euo pipefail
. "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/log.sh"

# Symlink niri config for the current machine.
# Usage:
#   export FLAKE_MACHINE=<machine name>  # icelake | tigerlake
#   ./scripts/setup_niri.sh

if [ -z "${FLAKE_MACHINE:-}" ]; then
    error "FLAKE_MACHINE environment variable not set."
    warn 'Run: export FLAKE_MACHINE=<machine name>  # icelake | tigerlake'
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$(dirname -- "$SCRIPT_DIR")"
NIRI_DIR="$HOME/.config/niri"

SRC_CONFIG="$FLAKE_DIR/dotfiles/niri/config_${FLAKE_MACHINE}.kdl"
SRC_GENERIC="$FLAKE_DIR/dotfiles/niri/generic"
SRC_MACHINE="$FLAKE_DIR/dotfiles/niri/${FLAKE_MACHINE}"

for src in "$SRC_CONFIG" "$SRC_GENERIC" "$SRC_MACHINE"; do
    if [ ! -e "$src" ]; then
        error "source not found: $src"
        warn "Check that FLAKE_MACHINE='$FLAKE_MACHINE' is correct."
        exit 1
    fi
done

# Backup existing config dir (or symlink) before overwriting
if [ -e "$NIRI_DIR" ] || [ -L "$NIRI_DIR" ]; then
    backup="$HOME/.config/niri.bak.$(date +%Y%m%d-%H%M%S)"
    warn "Backing up existing $NIRI_DIR -> $backup"
    mv -- "$NIRI_DIR" "$backup"
fi

mkdir -p -- "$NIRI_DIR"
ln -sfn -- "$SRC_CONFIG" "$NIRI_DIR/config.kdl"
ln -sfn -- "$SRC_GENERIC" "$NIRI_DIR/generic"
ln -sfn -- "$SRC_MACHINE" "$NIRI_DIR/$FLAKE_MACHINE"

green "Niri config linked for machine '$FLAKE_MACHINE':"
ls -l -- "$NIRI_DIR"
