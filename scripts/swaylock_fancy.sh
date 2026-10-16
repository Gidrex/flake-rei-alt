#!/usr/bin/env bash
set -euo pipefail

image=$(mktemp --suffix=.png)
trap 'rm -f "$image"' EXIT

# Blurred screenshot as lock background; plain swaylock if capture fails
# (a failed lock must still lock, never silently exit unlocked).
if grim "$image" 2>/dev/null && magick "$image" -filter Gaussian \
    -resize 20% \
    -define "filter:sigma=2.0" \
    -resize 500.5% \
    -gravity center \
    "$image" 2>/dev/null; then
    swaylock -i "$image" --hide-keyboard-layout
else
    swaylock
fi
