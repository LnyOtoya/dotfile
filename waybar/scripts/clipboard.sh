#!/usr/bin/env bash
set -euo pipefail

selection="$(cliphist list | fuzzel --dmenu --prompt='CLIP > ' --width=80)"
[[ -n "$selection" ]] || exit 0
printf '%s\n' "$selection" | cliphist decode | wl-copy
