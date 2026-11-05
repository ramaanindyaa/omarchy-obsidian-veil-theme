#!/bin/bash
# Obsidian Veil theme-set hook (installed by scripts/enable-extras.sh as
# ~/.config/omarchy/hooks/theme-set.d/50-obsidian-veil-extras).
# Omarchy drops Lua from git-installed themes; when obsidian-veil is applied
# this appends the theme's own extras/hyprland-extras.lua to the generated
# current theme hyprland.lua and reloads Hyprland. Other themes: no-op.

[[ ${1:-} == "obsidian-veil" ]] || exit 0

THEME_DIR="$HOME/.config/omarchy/themes/obsidian-veil"
EXTRAS="$THEME_DIR/extras/hyprland-extras.lua"
CURRENT="$HOME/.local/state/omarchy/current/theme/hyprland.lua"
MARKER="-- >>> obsidian-veil extras"

[[ -f $EXTRAS && ! -L $EXTRAS ]] || exit 0
[[ -d ${CURRENT%/*} ]] || exit 0

if ! grep -qF "$MARKER" "$CURRENT" 2>/dev/null; then
  tmp="$(mktemp "${CURRENT%/*}/.hyprland.XXXXXX")" || exit 1
  { cat "$CURRENT" 2>/dev/null; printf '\n%s (%s)\n' "$MARKER" "$EXTRAS"; cat "$EXTRAS"; } >"$tmp"
  mv -f "$tmp" "$CURRENT"
  omarchy-restart-hyprctl >/dev/null 2>&1 || hyprctl reload >/dev/null 2>&1 || true
fi

# The menu/launcher font is read once, when the Omarchy shell starts.
want="$(sed -n 's/^hl\.env("OMARCHY_MENU_FONT", "\(.*\)")$/\1/p' "$EXTRAS" | head -1)"
pid="$(pgrep -x quickshell | head -1)"
if [[ -n $want && -n $pid ]] && ! tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qxF "OMARCHY_MENU_FONT=$want"; then
  (sleep 2; omarchy-restart-shell >/dev/null 2>&1) &
fi
exit 0
