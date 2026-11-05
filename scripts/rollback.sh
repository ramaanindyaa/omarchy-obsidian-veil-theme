#!/usr/bin/env bash
# Restore the theme and wallpaper that were active before the first install,
# using Omarchy's own switcher (which also re-themes VS Code, terminals, GTK,
# browser, etc.), then remove the installed theme only if it is unmodified.
# Runs from a TTY too. Never deletes backups.
# Usage: rollback.sh [--dry-run] [--keep-theme-files]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
KEEP_FILES=0
for a in "$@"; do [[ $a == --keep-theme-files ]] && KEEP_FILES=1; done

[[ -e $SB_FIRST_BACKUP_LINK ]] || die "Tidak ada backup pre-install di $SB_FIRST_BACKUP_LINK."
BACKUP_DIR="$(readlink -f "$SB_FIRST_BACKUP_LINK")"
# shellcheck disable=SC1091
source "$BACKUP_DIR/state.env"
[[ -n ${PREV_THEME:-} ]] || die "state.env tidak berisi PREV_THEME."
TS="$(date +%Y%m%d-%H%M%S)"

log "Backup: $BACKUP_DIR"
log "Tema awal: $PREV_THEME; background awal: $PREV_BACKGROUND_NAME"

# 1. Theme + everything Omarchy themes (VS Code colorTheme, terminals, GTK, ...).
if [[ $(current_theme_name) == "$THEME_SLUG" ]]; then
  log "omarchy theme set $PREV_THEME"
  if (( DRY_RUN )); then
    echo "   [dry-run] OMARCHY_THEME_WAIT=1 omarchy theme set $PREV_THEME"
  else
    OMARCHY_THEME_WAIT=1 omarchy theme set "$PREV_THEME" || die "Gagal mengembalikan tema $PREV_THEME."
  fi
else
  log "Tema aktif bukan $THEME_SLUG ($(current_theme_name)); tema tidak diubah."
fi

# 2. Wallpaper: Omarchy remembers each theme's last background; verify and fix.
if [[ -n ${PREV_BACKGROUND_NAME:-} ]] && [[ $(current_theme_name) == "$PREV_THEME" || $DRY_RUN == 1 ]]; then
  want="$OMARCHY_CURRENT/theme/backgrounds/$PREV_BACKGROUND_NAME"
  [[ -f $want ]] || want="$PREV_BACKGROUND"
  if [[ $(readlink -f "$(current_background)") != "$(readlink -f "$want")" && -f $want ]]; then
    log "omarchy theme bg set $want"
    run omarchy theme bg set "$want"
  else
    log "Background sudah sesuai."
  fi
fi

# 3. VS Code settings: Omarchy rewrote only workbench.colorTheme. Report, never overwrite.
if [[ -f $BACKUP_DIR/vscode-settings.json && -f $VSCODE_SETTINGS ]]; then
  if cmp -s "$BACKUP_DIR/vscode-settings.json" "$VSCODE_SETTINGS"; then
    log "VS Code settings.json identik dengan backup."
  else
    warn "VS Code settings.json berbeda dari backup (kemungkinan edit pengguna). Tidak ditimpa. Diff:"
    diff -u "$BACKUP_DIR/vscode-settings.json" "$VSCODE_SETTINGS" >&2 || true
  fi
fi

# 4. Installed theme directory: remove only if unchanged since install.
if (( KEEP_FILES )); then
  log "Direktori tema dipertahankan (--keep-theme-files)."
elif [[ -d $THEME_TARGET && ! -L $THEME_TARGET ]]; then
  if [[ ! -f $THEME_TARGET/.stealth-black-owned ]]; then
    warn "$THEME_TARGET bukan buatan proyek; tidak disentuh."
  elif [[ -f $SB_INSTALL_MANIFEST ]] && [[ "$(tree_manifest "$THEME_TARGET")" == "$(cat "$SB_INSTALL_MANIFEST")" ]]; then
    if [[ -d $BACKUP_DIR/existing-stealth-black ]]; then
      log "Memulihkan direktori stealth-black yang ada sebelum install."
      run rm -rf -- "$THEME_TARGET"
      run cp -a -- "$BACKUP_DIR/existing-stealth-black" "$THEME_TARGET"
    else
      log "Menghapus $THEME_TARGET (tidak diubah sejak install)."
      run rm -rf -- "$THEME_TARGET"
    fi
    run rm -f -- "$SB_INSTALL_MANIFEST"
  else
    dest="$SB_BACKUP_ROOT/$TS-rollback-user-edited"
    warn "$THEME_TARGET diedit setelah install; dipindah ke $dest, tidak dihapus."
    run mkdir -p "$dest"
    run mv -- "$THEME_TARGET" "$dest/stealth-black"
  fi
fi

if (( ! DRY_RUN )); then
  errs="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
  log "Tema aktif: $(current_theme_name); background: $(current_background)"
  log "hyprctl configerrors: ${errs:-kosong}"
fi
log "Selesai. Backup tetap di $SB_BACKUP_ROOT."
