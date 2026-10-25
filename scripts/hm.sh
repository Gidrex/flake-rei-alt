#!/usr/bin/env bash
set -euo pipefail

# Real home-manager switch. Requires FLAKE_MACHINE (icelake|tigerlake).
# Usage:
#   export FLAKE_MACHINE=<machine name>  # icelake | tigerlake
#   ./scripts/hm.sh [extra home-manager args...]
# Called by `just hm` and the fish `hm` function (single source of truth).

: "${FLAKE_MACHINE:?Set FLAKE_MACHINE=icelake|tigerlake}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$(dirname -- "$SCRIPT_DIR")"

# Local nixvim-rei checkout wins over the remote flake input when present
# (mirrors the justfile nixvim_override; path input needs committed files).
override_args=()
if [ -f "$HOME/Projects/nixvim-rei/flake.nix" ]; then
    override_args=(--override-input nixvim-rei "$HOME/Projects/nixvim-rei")
fi

# NOTE: --impure is required: identity.nix filters sessionPath with
# builtins.pathExists (/home/...), which is always false under pure eval,
# silently dropping the entire PATH (see generations <=353 with no PATH export).
exec home-manager switch --impure --flake "$FLAKE_DIR#$FLAKE_MACHINE" "${override_args[@]}" -b backup "$@"
