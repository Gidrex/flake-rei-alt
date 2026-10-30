#!/usr/bin/env bash
# TUI panel for background daemons (niri Mod+O). Status is live on every open.
# Add a daemon:  1 entry in DAEMONS + label_/is_on_/start_/stop_ functions (copy phone_audio).
# Add an action (one-shot): 1 entry in ACTIONS + label_/run_ functions (copy lightstrip_wallpaper).
set -euo pipefail

RUNTIME="${XDG_RUNTIME_DIR:-/tmp}/daemons"
PIDFILE="$RUNTIME/scrcpy-audio.pid"

DAEMONS=(phone_audio float_sticky)
ACTIONS=(lightstrip_wallpaper)

label_phone_audio() { echo "Phone audio (scrcpy)"; }
is_on_phone_audio() { ([ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null) || pgrep -f "scrcpy .*--audio-source" >/dev/null; }
start_phone_audio() {
  command -v scrcpy >/dev/null || {
    notify-send "Phone audio" "scrcpy not found"
    return 1
  }
  adb devices 2>/dev/null | grep -q $'\tdevice$' || {
    notify-send "Phone audio" "no adb device"
    return 1
  }
  mkdir -p "$RUNTIME"
  setsid scrcpy --no-window --no-video --no-control --audio-source=output </dev/null >/dev/null 2>&1 &
  echo $! >"$PIDFILE"
  notify-send "Phone audio" "ON"
}
stop_phone_audio() {
  [ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null || true
  pkill -f "scrcpy .*--audio-source" 2>/dev/null || true # only matches our flag, not plain mirroring
  rm -f "$PIDFILE"
  notify-send "Phone audio" "OFF"
}

label_float_sticky() { echo "Float sticky (Picture-in-Picture)"; }
is_on_float_sticky() { pgrep -f "niri-float-sticky" >/dev/null; }
start_float_sticky() {
  command -v niri-float-sticky >/dev/null || {
    notify-send "Float sticky" "niri-float-sticky not found"
    return 1
  }
  setsid niri-float-sticky -app-id glide-glide -title '^Picture-in-Picture$' </dev/null >/dev/null 2>&1 &
  notify-send "Float sticky" "ON"
}
stop_float_sticky() {
  pkill -f "niri-float-sticky" 2>/dev/null || true
  notify-send "Float sticky" "OFF"
}

label_lightstrip_wallpaper() { echo "Light-strip: paint LEDs from wallpaper (DP-2)"; }
run_lightstrip_wallpaper() {
  local wall
  wall=$(noctalia msg wallpaper-get DP-2 2>/dev/null) || {
    notify-send "light-strip" "wallpaper-get failed"
    return 1
  }
  [ -n "$wall" ] || {
    notify-send "light-strip" "no wallpaper for DP-2"
    return 1
  }
  light-strip wallpaper "$wall" && notify-send "light-strip" "painted: $(basename "$wall")" || notify-send "light-strip" "failed"
}

status_line() { # $1 = id -> "● label [ON]" / "○ label [off]"
  if "is_on_$1"; then
    echo "● $(label_"$1") [ON]"
  else echo "○ $(label_"$1") [off]"; fi
}
toggle() { # $1 = id
  if "is_on_$1"; then "stop_$1"; else "start_$1"; fi
}

case "${1:-}" in
status)
  for d in "${DAEMONS[@]}"; do status_line "$d"; done
  exit 0
  ;;
picklist) # id|display lines for tv --source-command
  for d in "${DAEMONS[@]}"; do echo "$d|$(status_line "$d")"; done
  for a in "${ACTIONS[@]}"; do echo "$a|▷ $(label_"$a") [oneshot]"; done
  exit 0
  ;;
toggle)
  toggle "${2:?usage: scripts_menu.sh toggle <id>}"
  exit 0
  ;;
"") ;;
*)
  echo "usage: scripts_menu.sh [status|picklist|toggle <id>]" >&2
  exit 1
  ;;
esac

command -v tv >/dev/null || {
  echo "television (tv) not found" >&2
  exit 1
}
SCRIPT="${BASH_SOURCE[0]}"
while true; do
  pick=$(tv --source-command "\"$SCRIPT\" picklist" --source-display '{split:|:1}' --source-output '{split:|:0}' --no-sort --no-preview --no-remote --input-prompt "daemons (Enter=toggle/run, Esc=close) > ") || exit 0
  [ -z "$pick" ] && exit 0
  # toggle/run failures must not kill the panel (set -e): swallow, reloop.
  for a in "${ACTIONS[@]}"; do if [ "$pick" = "$a" ]; then "run_$pick" || true; fi; done
  for d in "${DAEMONS[@]}"; do if [ "$pick" = "$d" ]; then toggle "$pick" || true; fi; done
done
