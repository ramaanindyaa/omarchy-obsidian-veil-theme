#!/usr/bin/env bash
# Re-apply an installed Obsidian Veil through Omarchy's own switcher and check
# for new Hyprland config errors (auto-rollback when they appear).
# `omarchy theme set obsidian-veil` from the menu does the same without checks.
# Usage: apply.sh [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need omarchy

[[ -d $THEME_TARGET ]] || die "Tema belum terpasang; jalankan scripts/install.sh."

baseline="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
if (( DRY_RUN )); then
  log "[dry-run] omarchy theme set $THEME_SLUG (tema sekarang: $(current_theme_name))"
  exit 0
fi

log "omarchy theme set $THEME_SLUG"
OMARCHY_THEME_WAIT=1 omarchy theme set "$THEME_SLUG" </dev/null

sleep 1
now="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
if [[ -n $now && $now != "$baseline" ]]; then
  warn "Hyprland melaporkan error konfigurasi baru:"; printf '%s\n' "$now" >&2
  warn "Rollback otomatis..."
  "$PROJECT_DIR/scripts/rollback.sh" --keep-theme-files
  exit 1
fi
[[ $(current_theme_name) == "$THEME_SLUG" ]] || die "Tema aktif bukan $THEME_SLUG setelah apply."
log "Aktif: $(current_theme_name); background: $(current_background)"
if [[ -s $HOME/.local/state/omarchy/theme-set.log ]]; then
  warn "theme-set.log:"; cat "$HOME/.local/state/omarchy/theme-set.log" >&2
fi
log "hyprctl configerrors: ${now:-kosong}"
