#!/usr/bin/env bash
# Dir jumper: pick a zoxide dir via tv, print it (fish Alt+Z jumps via `z`;
# niri Mod+T spawns foot that stays in the picked dir).
# Ctrl+T narrows the list to the selected entry's parent (recursive); Enter
# picks; Esc aborts (no output, exit 1).
# NOTE: Shift+Left/Right cannot be the narrow key: tv 0.15.9 drops CSI
# modifiers without kitty keyboard protocol, so Shift+Left arrives as plain
# Left and would hijack cursor movement (verified in a pty).
set -euo pipefail

command -v tv >/dev/null || {
  echo "ztv: television (tv) not found" >&2
  exit 1
}

pick() { # $1 = input filter (parent scope, empty on first run)
  local -a out
  mapfile -t out < <(tv --source-command "zoxide query -l" \
    --preview-command "eza --color=always --icons=always --group-directories-first \"{}\"" \
    --preview-size 60 --layout landscape --input "${1:-}" --expect=ctrl-t)
  if ((${#out[@]} == 0)); then
    return 1
  fi
  if [[ ${out[0]} == ctrl-t ]] && ((${#out[@]} >= 2)); then
    local parent
    parent=$(dirname -- "${out[1]}")
    if [[ $parent == "${out[1]}" ]]; then
      return 1
    fi
    pick "$parent"
  else
    printf '%s\n' "${out[-1]}"
  fi
}

pick "${1:-}"
