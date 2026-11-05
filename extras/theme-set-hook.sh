#!/bin/bash
# Obsidian Veil theme-set hook (installed by scripts/enable-extras.sh as
# ~/.config/omarchy/hooks/theme-set.d/50-obsidian-veil-extras).
# Omarchy drops Lua from git-installed themes; when obsidian-veil is applied
# this appends the theme's own extras/hyprland-extras.lua to the generated
# current theme hyprland.lua and reloads Hyprland. Other themes: no-op.

[[ ${1:-} == "obsidian-veil" ]] || exit 0

STATE="$HOME/.local/state/omarchy/current"
THEME_DIR="$HOME/.config/omarchy/themes/obsidian-veil"
EXTRAS="$THEME_DIR/extras/hyprland-extras.lua"
CURRENT="$STATE/theme/hyprland.lua"
MARKER="-- >>> obsidian-veil extras"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/omarchy-theme-set.lock"

[[ -f $EXTRAS && ! -L $EXTRAS ]] || exit 0

# Omarchy runs theme-set hooks even when a newer switch already replaced this
# theme (a quick obsidian-veil -> other switch). Take the same lock
# omarchy-theme-set holds while it swaps the current theme, then act only if
# obsidian-veil is still the current theme.
exec 7>"$LOCK"
flock -w 15 7 || exit 0
[[ $(cat "$STATE/theme.name" 2>/dev/null) == "obsidian-veil" ]] || exit 0
[[ -d $STATE/theme ]] || exit 0

if ! grep -qF -- "$MARKER" "$CURRENT" 2>/dev/null; then
  tmp="$(mktemp "$STATE/theme/.hyprland.XXXXXX")" || exit 1
  { cat "$CURRENT" 2>/dev/null; printf '\n%s (%s)\n' "$MARKER" "$EXTRAS"; cat "$EXTRAS"; } >"$tmp"
  mv -f "$tmp" "$CURRENT"
  omarchy-restart-hyprctl >/dev/null 2>&1 || hyprctl reload >/dev/null 2>&1 || true
fi
exec 7>&-

# The menu/launcher font is read once, when the Omarchy shell starts.
want="$(sed -n 's/^hl\.env("OMARCHY_MENU_FONT", "\(.*\)")$/\1/p' "$EXTRAS" | head -1)"
pid="$(pgrep -x quickshell | head -1)"
if [[ -n $want && -n $pid ]] && ! tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qxF "OMARCHY_MENU_FONT=$want"; then
  (sleep 2; omarchy-restart-shell >/dev/null 2>&1) &
fi
exit 0
