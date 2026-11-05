#!/usr/bin/env bash
# Check that every Omarchy internal Obsidian Veil depends on still exists, and
# (when the theme is active) that the live session matches. Read-only.
# Installed by enable-extras.sh as the post-update hook
# ~/.config/omarchy/hooks/post-update.d/50-obsidian-veil-compat, so it runs at
# the end of every `omarchy update`; there it notifies only on problems.
# Usage: check-compat.sh [--notify] [--quiet]

NOTIFY=0 QUIET=0
for a in "$@"; do
  case "$a" in --notify) NOTIFY=1 ;; --quiet) QUIET=1 ;; esac
done
# As a hook it is called with no flags.
[[ ${0##*/} == 50-obsidian-veil-compat ]] && NOTIFY=1 QUIET=1

P="${OMARCHY_PATH:-/usr/share/omarchy}"
THEME_DIR="$HOME/.config/omarchy/themes/obsidian-veil"
STATE="$HOME/.local/state/omarchy/current"
problems=()
ok() { (( QUIET )) || printf '  LULUS  %s\n' "$*"; }
bad() { problems+=("$*"); printf '  GAGAL  %s\n' "$*"; }
chk() { local desc="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$desc"; else bad "$desc"; fi; }

(( QUIET )) || echo ":: Titik integrasi Omarchy ($(omarchy version 2>/dev/null || echo '?'))"
chk "theme-set masih menjalankan hook theme-set"          grep -q 'omarchy-hook theme-set' "$(command -v omarchy-theme-set)"
chk "Hyprland memuat hyprland.lua tema aktif"             grep -q 'omarchy.current.theme.hyprland' "$P/default/hypr/omarchy.lua"
chk "template border membaca hyprland_active_border"       grep -q 'hyprland_active_border' "$P/default/themed/hyprland.lua.tpl"
chk "template border membaca hyprland_inactive_border"     grep -q 'hyprland_inactive_border' "$P/default/themed/hyprland.lua.tpl"
chk "override shell.<section>.toml masih didukung"         grep -q 'apply_shell_section_overrides' "$(command -v omarchy-theme-set-templates)"
for s in bar popups tooltip notifications launcher menu; do
  chk "section [$s] ada di shell.toml"                    grep -q "^\[$s\]" "$P/default/themed/shell.toml.tpl"
done
chk "shell membaca OMARCHY_MENU_FONT"                     grep -q 'OMARCHY_MENU_FONT' "$P/shell/Commons/Style.qml"
chk "VS Code memakai vscode-theme.json tema"               grep -q 'vscode-theme.json' "$(command -v omarchy-theme-set-vscode)"
chk "Yaru-blue (sumber ikon graphite) masih ada"          test -f /usr/share/icons/Yaru-blue/index.theme
chk "Omarchy masih menerapkan icons.theme lewat gsettings"  grep -q 'icons.theme' "$(command -v omarchy-theme-set-gnome)"
chk "hook Lua extras masih terpasang"                      test -x "$HOME/.config/omarchy/hooks/theme-set.d/50-obsidian-veil-extras"
chk "tema obsidian-veil masih terpasang"                   test -f "$THEME_DIR/colors.toml"

# Informational: Omarchy changed its VS Code template since vscode-theme.json was rendered.
want="$(sed -n 's/^vscode-theme.json.tpl=//p' "$THEME_DIR/extras/omarchy-compat.sha256" 2>/dev/null)"
have="$(sha256sum "$P/default/themed/vscode-theme.json.tpl" 2>/dev/null | cut -d' ' -f1)"
if [[ -n $want && $want != "$have" ]]; then
  (( QUIET )) || echo "  INFO   template VS Code Omarchy berubah; render ulang vscode-theme.json (scripts/build.sh) bila ingin perubahan terbaru"
fi

if [[ $(cat "$STATE/theme.name" 2>/dev/null) == obsidian-veil ]]; then
  (( QUIET )) || echo ":: Sesi aktif (Obsidian Veil)"
  chk "ikon graphite aktif"                                  test "$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null)" = "'ObsidianVeil-Graphite'"
  chk "extras Lua aktif di tema aktif"                      grep -qF -- '-- >>> obsidian-veil extras' "$STATE/theme/hyprland.lua"
  if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null; then
    chk "hyprctl configerrors kosong"                        test -z "$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d')"
    chk "border 1 px aktif"                                  test "$(hyprctl -j getoption general:border_size | jq '.int')" = 1
    chk "sudut 5 px aktif"                                   test "$(hyprctl -j getoption decoration:rounding | jq '.int')" = 5
  fi
fi

if (( ${#problems[@]} )); then
  if (( NOTIFY )); then
    msg="$(printf '• %s\n' "${problems[@]}")"
    omarchy-notification-send -u normal "Obsidian Veil: cek setelah update" \
      "$msg
Jalankan ~/.config/omarchy/themes/obsidian-veil/scripts/check-compat.sh. Darurat: omarchy theme set tokyo-night" >/dev/null 2>&1 ||
      notify-send "Obsidian Veil: cek setelah update" "$msg" >/dev/null 2>&1 || true
  fi
  exit 1
fi
(( QUIET )) || echo "HASIL: LULUS"
exit 0
