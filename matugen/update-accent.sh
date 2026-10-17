#!/usr/bin/env bash
set -euo pipefail

css="$HOME/.config/matugen/generated/colors.css"
mako_config="$HOME/.config/mako/config"

get_color() {
    sed -n "s/^@define-color $1 #\\([[:xdigit:]]\\{6\\}\\);/\\1/p" "$css" | head -n1
}

primary=$(get_color primary)
surface_container=$(get_color surface_container)
on_surface=$(get_color on_surface)

if [[ ! "$primary" =~ ^[[:xdigit:]]{6}$ ||
      ! "$surface_container" =~ ^[[:xdigit:]]{6}$ ||
      ! "$on_surface" =~ ^[[:xdigit:]]{6}$ ]]; then
    echo "无法读取 Matugen 颜色：$css" >&2
    exit 1
fi

r=$((16#${primary:0:2}))
g=$((16#${primary:2:2}))
b=$((16#${primary:4:2}))

accent=$(awk -v r="$r" -v g="$g" -v b="$b" \
    'BEGIN { printf "%.3f,%.3f,%.3f", r/255, g/255, b/255 }')

# 更新 XDG Portal 全局强调色
systemctl --user set-environment "XDP_GENERIC_ACCENT_COLOR=$accent"
systemctl --user restart xdg-desktop-portal-generic
systemctl --user restart xdg-desktop-portal

# 更新 Mako 通知配色
if [[ -f "$mako_config" ]]; then
    set_mako_color() {
        local key="$1"
        local value="$2"

        if grep -q "^${key}=" "$mako_config"; then
            sed -i "s|^${key}=.*|${key}=${value}|" "$mako_config"
        else
            printf '%s=%s\n' "$key" "$value" >> "$mako_config"
        fi
    }

    set_mako_color background-color "#$surface_container"
    set_mako_color text-color "#$on_surface"
    set_mako_color border-color "#$primary"
    set_mako_color progress-color "over #$primary"

    makoctl reload
fi

# 刷新 Waybar
pkill -SIGUSR2 waybar 2>/dev/null || true

echo "Matugen colors updated:"
echo "Primary: #$primary"
echo "Mako background: #$surface_container"
echo "Portal accent: $accent"
