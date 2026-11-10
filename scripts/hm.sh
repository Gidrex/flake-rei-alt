#!/usr/bin/env bash
set -euo pipefail
. "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/log.sh"

# Real home-manager switch. Requires FLAKE_MACHINE (icelake|tigerlake).
# Usage:
#   export FLAKE_MACHINE=<machine name>  # icelake | tigerlake
#   ./scripts/hm.sh [extra home-manager args...]
# Called by `just hm` and the fish `hm` function (single source of truth).

[ -n "${FLAKE_MACHINE:-}" ] || {
  error "FLAKE_MACHINE is not set"
  warn "Run: export FLAKE_MACHINE=icelake|tigerlake"
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$(dirname -- "$SCRIPT_DIR")"

# NOTE: --impure is required: identity.nix filters sessionPath with
# builtins.pathExists (/home/...), which is always false under pure eval,
# silently dropping the entire PATH (see generations <=353 with no PATH export).
exec home-manager switch --impure --flake "$FLAKE_DIR#$FLAKE_MACHINE" -b backup "$@"
