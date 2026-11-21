#!/usr/bin/env bash
set -euo pipefail

choice="$(printf 'LOCK\nSUSPEND\nLOG OUT\nREBOOT\nSHUT DOWN' | fuzzel --dmenu --prompt='PWR > ' --width=24)"
case "$choice" in
  LOCK) loginctl lock-session ;;
  SUSPEND) systemctl suspend ;;
  "LOG OUT") niri msg action quit ;;
  REBOOT) systemctl reboot ;;
  "SHUT DOWN") systemctl poweroff ;;
  *) exit 0 ;;
esac
