#!/usr/bin/env bash
# Undo Obsidian Veil: restore the previous theme and wallpaper through Omarchy's
# own switcher (which also re-themes VS Code, terminals, GTK, browser, ...),
# remove the hook, the generated user wallpapers and the theme clone — each only
# when it is still exactly what this project installed — and undo typography.
# Runs from a TTY too. Never deletes backups.
#
# Usage: rollback.sh [--to <theme>] [--keep-theme-files] [--keep-typography] [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"

KEEP_FILES=0 KEEP_TYPO=0 TO=""
args=("$@")
for i in "${!args[@]}"; do
  case "${args[$i]}" in
    --keep-theme-files) KEEP_FILES=1 ;;
    --keep-typography) KEEP_TYPO=1 ;;
    --to) TO="${args[$((i + 1))]:-}" ;;
  esac
done

BACKUP_DIR=""
PREV_THEME="" PREV_BACKGROUND="" PREV_BACKGROUND_NAME=""
if [[ -e $SB_FIRST_BACKUP_LINK ]]; then
  BACKUP_DIR="$(readlink -f "$SB_FIRST_BACKUP_LINK")"
  # shellcheck disable=SC1091
  source "$BACKUP_DIR/state.env"
fi
[[ -n $TO ]] && PREV_THEME="$TO"
[[ -n $PREV_THEME ]] || die "Tema tujuan tidak diketahui (tidak ada backup). Pakai --to <tema>, mis. --to tokyo-night."
TS="$(date +%Y%m%d-%H%M%S)"

log "Backup: ${BACKUP_DIR:-tidak ada}"
log "Tema tujuan: $PREV_THEME; background awal: ${PREV_BACKGROUND_NAME:-tidak tercatat}"

# 1. Theme + everything Omarchy themes.
if [[ $(current_theme_name) == "$THEME_SLUG" ]]; then
  log "omarchy theme set $PREV_THEME"
  if (( DRY_RUN )); then
    echo "   [dry-run] OMARCHY_THEME_WAIT=1 omarchy theme set $PREV_THEME"
  else
    OMARCHY_THEME_WAIT=1 omarchy theme set "$PREV_THEME" </dev/null || die "Gagal mengembalikan tema $PREV_THEME."
  fi
else
  log "Tema aktif bukan $THEME_SLUG ($(current_theme_name)); tema tidak diubah."
fi

# 2. Wallpaper: Omarchy remembers each theme's last background; verify and fix.
if [[ -n $PREV_BACKGROUND_NAME ]] && [[ $(current_theme_name) == "$PREV_THEME" || $DRY_RUN == 1 ]]; then
  want="$OMARCHY_CURRENT/theme/backgrounds/$PREV_BACKGROUND_NAME"
  [[ -f $want ]] || want="$PREV_BACKGROUND"
  if [[ -f $want && $(readlink -f "$(current_background)") != "$(readlink -f "$want")" ]]; then
    log "omarchy theme bg set $want"
    run omarchy theme bg set "$want"
  else
    log "Background sudah sesuai."
  fi
fi

# 3. Hook: remove only our unmodified copy.
if [[ -f $HOOK_TARGET ]]; then
  if cmp -s "$HOOK_TARGET" "$PROJECT_DIR/extras/theme-set-hook.sh" || grep -q 'Obsidian Veil theme-set hook' "$HOOK_TARGET"; then
    log "Hapus hook $HOOK_TARGET"
    run rm -f -- "$HOOK_TARGET"
  else
    warn "$HOOK_TARGET bukan hook Obsidian Veil; dibiarkan."
  fi
fi

if [[ -f $POSTBOOT_HOOK_TARGET ]]; then
  if grep -q 'Obsidian Veil theme-set hook' "$POSTBOOT_HOOK_TARGET"; then
    log "Hapus hook $POSTBOOT_HOOK_TARGET"
    run rm -f -- "$POSTBOOT_HOOK_TARGET"
  else
    warn "$POSTBOOT_HOOK_TARGET bukan hook Obsidian Veil; dibiarkan."
  fi
fi

if [[ -f $COMPAT_HOOK_TARGET ]]; then
  if grep -q 'Obsidian Veil' "$COMPAT_HOOK_TARGET"; then
    log "Hapus hook $COMPAT_HOOK_TARGET"
    run rm -f -- "$COMPAT_HOOK_TARGET"
  else
    warn "$COMPAT_HOOK_TARGET bukan milik Obsidian Veil; dibiarkan."
  fi
fi

# 4. Generated user wallpapers: remove only files whose hash we recorded.
manifest="$SB_STATE_DIR/user-backgrounds.sha256"
if [[ -f $manifest ]]; then
  while read -r sum path; do
    [[ -f $path ]] || continue
    if [[ $(sha_of "$path") == "$sum" ]]; then run rm -f -- "$path"; else warn "$path diubah; dibiarkan."; fi
  done <"$manifest"
  run rm -f -- "$manifest"
  [[ -d $USER_BACKGROUNDS ]] && (( ! DRY_RUN )) && rmdir --ignore-fail-on-non-empty -- "$USER_BACKGROUNDS"
fi

# 5. Typography (VS Code + foot), surgical.
if (( ! KEEP_TYPO )) && [[ -e $SB_STATE_DIR/typography/pre-typography ]]; then
  flags=(--rollback); (( DRY_RUN )) && flags+=(--dry-run)
  "$PROJECT_DIR/scripts/typography.sh" "${flags[@]}" || warn "Rollback tipografi tidak lengkap."
fi

# 6. VS Code settings: report differences, never overwrite.
if [[ -n $BACKUP_DIR && -f $BACKUP_DIR/vscode-settings.json && -f $VSCODE_SETTINGS ]] && (( ! DRY_RUN )); then
  if cmp -s "$BACKUP_DIR/vscode-settings.json" "$VSCODE_SETTINGS"; then
    log "VS Code settings.json identik dengan backup."
  else
    warn "VS Code settings.json berbeda dari backup (tidak ditimpa):"
    diff -u "$BACKUP_DIR/vscode-settings.json" "$VSCODE_SETTINGS" >&2 || true
  fi
fi

# Graphite icon theme (only our generated copy).
if [[ -f $ICON_TARGET/.obsidian-veil ]]; then
  log "Hapus ikon $ICON_TARGET"
  run rm -rf -- "$ICON_TARGET"
fi

# 7. Theme clone — last, so this script also works when run from the clone.
if (( KEEP_FILES )); then
  log "Direktori tema dipertahankan (--keep-theme-files)."
elif [[ -d $THEME_TARGET && ! -L $THEME_TARGET ]]; then
  if clean_theme_clone "$THEME_TARGET"; then
    log "Hapus $THEME_TARGET (clone bersih)."
    run rm -rf -- "$THEME_TARGET"
    if [[ -n $BACKUP_DIR && -d $BACKUP_DIR/existing-$THEME_SLUG ]]; then
      log "Pulihkan direktori $THEME_SLUG yang ada sebelum install."
      run cp -a -- "$BACKUP_DIR/existing-$THEME_SLUG" "$THEME_TARGET"
    fi
  else
    dest="$SB_BACKUP_ROOT/$TS-rollback-modified"
    warn "$THEME_TARGET berisi perubahan; dipindah ke $dest, tidak dihapus."
    run mkdir -p "$dest"
    run mv -- "$THEME_TARGET" "$dest/$THEME_SLUG"
  fi
fi

if (( ! DRY_RUN )); then
  errs="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
  log "Tema aktif: $(current_theme_name); background: $(current_background)"
  log "hyprctl configerrors: ${errs:-kosong}"
  log "Font menu IBM Plex Sans tetap ada di lingkungan Hyprland sampai login ulang."
fi
log "Selesai. Backup tetap di $SB_BACKUP_ROOT."
