#!/usr/bin/env bash
set -euo pipefail
options="Shutdown\nReboot\nLogout\nSuspend\nHibernate\nLock\nExit\nTurn off monitor"
chosen=$(printf '%b' "$options" | wofi --dmenu --prompt "Power Menu" --width 10% --height 30% || true)

# Empty = user pressed Esc, not a choice
[ -z "$chosen" ] && exit 0

case $chosen in
  "Shutdown") systemctl poweroff ;;
  "Reboot")   systemctl reboot ;;
  "Logout")   niri msg action quit --skip-confirmation ;;
  "Suspend")  systemctl suspend ;;
  "Hibernate") systemctl hibernate ;;
  "Lock")     swaylock ;;
  "Exit")     exit 0 ;;
  "Turn off monitor") niri msg action power-off-monitors ;; 
  *)          exit 1 ;;
esac