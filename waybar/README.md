# Waybar for Niri + Matugen

Draft setup: two independent Waybar instances, flat styling, Matugen colors.

## Install packages (Arch)

```bash
sudo pacman -S waybar fuzzel wl-clipboard cliphist wireplumber pipewire \
  bluez bluez-utils blueman kitty
```

Enable Bluetooth if used:

```bash
sudo systemctl enable --now bluetooth
```

## Setup

Copy this directory's files into `~/.config/waybar/`, preserving `scripts/`.
Make scripts executable:

```bash
chmod +x ~/.config/waybar/scripts/*.sh
```

Make sure the Matugen file exists at:
`/home/otoya/.config/matugen/generated/colors.css`

## Clipboard history daemon

Start the text clipboard watcher in your Niri session (e.g. a startup command):

```bash
wl-paste --type text --watch cliphist store
```

Optional image history watcher:

```bash
wl-paste --type image --watch cliphist store
```

These are separate long-running processes; start them with `spawn-at-startup`.

## Launch Waybar instances from Niri

Use the shell wrapper so `$HOME` expands:

```kdl
spawn-at-startup "sh" "-c" "waybar -c $HOME/.config/waybar/top.jsonc -s $HOME/.config/waybar/top.css"
spawn-at-startup "sh" "-c" "waybar -c $HOME/.config/waybar/bottom.jsonc -s $HOME/.config/waybar/bottom.css"
spawn-at-startup "sh" "-c" "wl-paste --type text --watch cliphist store"
```

Optional image watcher (beware clipboard image history can consume disk space):

```kdl
spawn-at-startup "sh" "-c" "wl-paste --type image --watch cliphist store"
```

## Notes

- The recording module currently checks process names `wf-recorder`, `obs`, and `gpu-screen-recorder`. Adjust to your recorder.
- Network click launches `kitty -e nmtui`; change `kitty` if you use another terminal.
- Bluetooth click launches `blueman-manager`.
- Volume is a custom script to render a block meter. Scroll commands use WirePlumber's `wpctl`.
- The date is Gregorian for now; lunar calendar and solar-term additions can be integrated later.
- These are starter configs; test with `waybar -c ... -s ...` in a terminal before adding startup commands.
