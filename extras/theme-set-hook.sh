#!/bin/bash
# Obsidian Veil theme-set hook (installed by scripts/enable-extras.sh as
# ~/.config/omarchy/hooks/theme-set.d/50-obsidian-veil-extras).
# Omarchy drops Lua from git-installed themes; when obsidian-veil is applied
# this appends the theme's own extras/hyprland-extras.lua to the generated
# current theme hyprland.lua and reloads Hyprland. Other themes: no-op.
#
# Resend wallpapers (not in the repo): fetched in the background when
# obsidian-veil is applied and they are missing; removed again once the theme
# itself has been removed (`omarchy theme remove` has no hook, so this runs on
# the next theme switch and, via the post-boot copy of this file
# ~/.config/omarchy/hooks/post-boot.d/50-obsidian-veil-cleanup, at login).
# Opt out of the download: touch ~/.local/state/obsidian-veil/no-auto-wallpapers

STATE="$HOME/.local/state/omarchy/current"
THEME_DIR="$HOME/.config/omarchy/themes/obsidian-veil"
USER_BG="$HOME/.config/omarchy/backgrounds/obsidian-veil"
OV_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/obsidian-veil"
OV_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/obsidian-veil/wallpapers"
MANIFEST="$OV_STATE/user-backgrounds.sha256"   # written by scripts/build.sh
RESEND_BG=(2-pilulae.jpg 3-discus.jpg 4-cubus.jpg)   # = build.sh --user-backgrounds
RESEND_CACHE=(pilulae.jpg discus.jpg cubus.jpg)      # = fetch-wallpaper.sh --resend

# Theme gone: delete only the wallpapers we generated and the user has not
# changed. The one currently on screen is kept (and retried next time).
cleanup_removed_theme() {
  [[ ! -d $THEME_DIR && -f $MANIFEST ]] || return 0
  [[ $(cat "$STATE/theme.name" 2>/dev/null) != "obsidian-veil" ]] || return 0
  local current sum path keep="" f
  current="$(readlink -f "$STATE/background" 2>/dev/null || true)"
  while read -r sum path; do
    [[ -f $path ]] || continue
    [[ $(sha256sum -- "$path" | cut -d' ' -f1) == "$sum" ]] || continue
    if [[ $(readlink -f "$path") == "$current" ]]; then
      keep+="$sum  $path"$'\n'
    else
      rm -f -- "$path"
    fi
  done <"$MANIFEST"
  if [[ -n $keep ]]; then
    printf '%s' "$keep" >"$MANIFEST"
    return 0
  fi
  rm -f -- "$MANIFEST" "$OV_STATE/auto-wallpapers.failed"
  rmdir --ignore-fail-on-non-empty -- "$USER_BG" 2>/dev/null || true
  for f in "${RESEND_CACHE[@]}"; do rm -f -- "$OV_CACHE/$f"; done
  rmdir --ignore-fail-on-non-empty -- "$OV_CACHE" 2>/dev/null || true
}

# Theme applied: fetch + build missing Resend wallpapers, detached so the
# theme switch is never held up. After a failure, wait an hour before retrying.
fetch_missing_wallpapers() {
  local f missing=0 script="$THEME_DIR/scripts/enable-extras.sh"
  [[ -f $script && ! -e $OV_STATE/no-auto-wallpapers ]] || return 0
  for f in "${RESEND_BG[@]}"; do [[ -f $USER_BG/$f ]] || missing=1; done
  (( missing )) || return 0
  [[ -n $(find "$OV_STATE/auto-wallpapers.failed" -mmin -60 2>/dev/null) ]] && return 0
  mkdir -p "$OV_STATE" || return 0
  setsid -f bash -c '
    exec 9>"$1/auto-wallpapers.lock"; flock -n 9 || exit 0
    if bash "$2" --wallpapers; then rm -f "$1/auto-wallpapers.failed"
    else touch "$1/auto-wallpapers.failed"; fi
  ' _ "$OV_STATE" "$script" </dev/null >>"$OV_STATE/auto-wallpapers.log" 2>&1 7>&- || true
}

cleanup_removed_theme
[[ ${1:-} == "obsidian-veil" ]] || exit 0
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

# Graphite folder icons (built by scripts/build-icons.sh). Omarchy's GNOME step
# has already applied icons.theme (Yaru-sage fallback) in this same batch.
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons/ObsidianVeil-Graphite"
if [[ -f $ICONS/index.theme && -n ${DBUS_SESSION_BUS_ADDRESS:-} ]] &&
   [[ $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null) != "'ObsidianVeil-Graphite'" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "ObsidianVeil-Graphite" 2>/dev/null || true
fi
exec 7>&-

fetch_missing_wallpapers

# The menu/launcher font is read once, when the Omarchy shell starts.
want="$(sed -n 's/^hl\.env("OMARCHY_MENU_FONT", "\(.*\)")$/\1/p' "$EXTRAS" | head -1)"
pid="$(pgrep -x quickshell | head -1)"
if [[ -n $want && -n $pid ]] && ! tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | grep -qxF "OMARCHY_MENU_FONT=$want"; then
  (sleep 2; omarchy-restart-shell >/dev/null 2>&1) &
fi
exit 0
