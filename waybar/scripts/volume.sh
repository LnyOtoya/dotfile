#!/usr/bin/env bash
set -euo pipefail

raw="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
if [[ -z "$raw" ]]; then
  printf '{"text":"VOL [ unavailable ]","tooltip":"WirePlumber unavailable"}\n'
  exit 0
fi

vol="$(awk '{for(i=1;i<=NF;i++) if($i=="Volume:"){print $(i+1); exit}}' <<< "$raw")"
muted=0
grep -q 'MUTED' <<< "$raw" && muted=1
percent="$(awk -v v="$vol" 'BEGIN {p=int(v*100+0.5); if(p<0)p=0; if(p>150)p=150; print p}')"

# Read Matugen palette values so the filled and empty blocks follow wallpaper colors.
palette="$HOME/.config/matugen/generated/colors.css"
# primary="$(sed -n 's/^@define-color primary[[:space:]]\\+#\\([[:xdigit:]]\\{6\\}\\);/\\1/p' "$palette" 2>/dev/null | head -n1)"
# surface_container="$(sed -n 's/^@define-color surface_container[[:space:]]\\+#\\([[:xdigit:]]\\{6\\}\\);/\\1/p' "$palette" 2>/dev/null | head -n1)"
primary="$(sed -n 's/^@define-color primary[[:space:]]\+#\([[:xdigit:]]\{6\}\);/\1/p' "$palette" | head -n1)"
surface_container="$(sed -n 's/^@define-color surface_container[[:space:]]\+#\([[:xdigit:]]\{6\}\);/\1/p' "$palette" | head -n1)"
primary="${primary:-a4c9fe}"
surface_container="${surface_container:-1d2024}"
# if [[ -z "$primary" || -z "$surface_container" ]]; then
#   echo "Failed to read Matugen colors" >&2
#   exit 1
# fi

blocks=16
filled="$(awk -v p="$percent" -v n="$blocks" 'BEGIN {f=int(p*n/100+0.5); if(f<0)f=0; if(f>n)f=n; print f}')"
printf -v bar '%*s' "$filled" ''
bar="${bar// /█}"
printf -v empty '%*s' "$((blocks-filled))" ''
empty="${empty// /░}"
meter="<span foreground='#${primary}'>${bar}</span><span foreground='#${surface_container}'>${empty}</span>"

if (( muted )); then
  text="VOL [${meter}] MUTED"
  tooltip="Muted · ${percent}% (click to unmute; scroll to adjust)"
else
  text="VOL [${meter}] ${percent}%"
  tooltip="Volume: ${percent}% (scroll ±2%; click to mute)"
fi

# Escape markup's ampersand/quotes for JSON string use.
text="${text//\\/\\\\}"
text="${text//\"/\\\"}"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$([[ $muted -eq 1 ]] && echo muted || echo normal)"
