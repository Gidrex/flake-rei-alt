#!/usr/bin/env bash
set -euo pipefail
. "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/lib/log.sh"

if [ "$#" -ne 2 ]; then
    error "usage: toggle_output.sh focus|move OUTPUT"
    exit 1
fi
ACTION="$1" # "focus" or "move"
TARGET="$2"
case "$ACTION" in
    focus | move) ;;
    *)
        error "toggle_output.sh: ACTION must be focus|move, got '$ACTION'"
        exit 1
        ;;
esac
PRIMARY="DP-2"

CURRENT=$(niri msg -j focused-output 2>/dev/null | jq -r .name)

DEST="$TARGET"
if [ "$CURRENT" = "$TARGET" ]; then
    DEST="$PRIMARY"
fi

if [ "$ACTION" = "focus" ]; then
    niri msg action focus-monitor "$DEST"
else
    niri msg action move-column-to-monitor "$DEST"
fi
