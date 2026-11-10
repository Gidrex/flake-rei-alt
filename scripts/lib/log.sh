# shellcheck shell=bash
# Pastel (catppuccin mocha) log levels for scripts/*. Source it:
#   . "$(dirname -- "${BASH_SOURCE[0]}")/lib/log.sh"
# error/warn -> stderr, green -> stdout. Colour only on a tty and without NO_COLOR.

_log() { # fd r g b msg...
  local fd=$1 rgb="$2;$3;$4"
  shift 4
  if [ -t "$fd" ] && [ -z "${NO_COLOR:-}" ]; then
    printf '\033[38;2;%sm%s\033[0m\n' "$rgb" "$*" >&"$fd"
  else
    printf '%s\n' "$*" >&"$fd"
  fi
}

error() { _log 2 243 139 168 "$@"; } # red    #f38ba8
warn() { _log 2 249 226 175 "$@"; }  # yellow #f9e2af
green() { _log 1 166 227 161 "$@"; } # green  #a6e3a1
