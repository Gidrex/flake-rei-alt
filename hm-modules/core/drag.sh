# drag FILE...: blobdrop window that follows the focused niri workspace.
# niri has no sticky windows, so we move it on every WorkspaceActivated event.
# Window placement/size: dotfiles/niri/generic/rules.kdl (title "Blobdrop").

# catppuccin mocha base; the pink accent is hardcoded in blobdrop's QML, env can't override it.
export QT_QUICK_CONTROLS_MATERIAL_BACKGROUND='#1e1e2e'

blobdrop -f gui "$@" &
pid=$!

coproc ES { exec niri msg -j event-stream; }
exec {events}<&"${ES[0]}"
trap 'kill "$ES_PID" 2>/dev/null || true' EXIT

while kill -0 "$pid" 2>/dev/null; do
  # timeout (>128) just rechecks blobdrop; EOF means niri is gone.
  read -r -t 1 ev <&"$events" || { (($? > 128)) && continue; break; }
  ws=$(jq -r '.WorkspaceActivated | select(.focused) | .id' <<<"$ev")
  [[ -n $ws ]] || continue
  # shortcut: idx resolves on the focused output; fine for one monitor, use workspace names for multi-monitor.
  idx=$(niri msg -j workspaces | jq ".[] | select(.id == $ws) | .idx")
  win=$(niri msg -j windows | jq ".[] | select(.pid == $pid) | .id")
  [[ -n $win ]] && niri msg action move-window-to-workspace --window-id "$win" --focus false "$idx" || true
done
