#!/usr/bin/env bash
# Enable everything `omarchy theme install` cannot deliver on its own.
# Run once after installing the theme (from the installed clone or any clone):
#   ~/.config/omarchy/themes/obsidian-veil/scripts/enable-extras.sh --all
#
#   --hook        theme-set hook: Hyprland decoration (1 px border, 5 px corners,
#                 120-180 ms motion, solid terminals), IBM Plex Sans menu font and
#                 graphite folder icons (scripts/build-icons.sh)
#   --wallpapers  download the Resend wallpapers (not in the repo) into
#                 ~/.config/omarchy/backgrounds/obsidian-veil/ (once the hook is
#                 installed it also does this automatically on theme set and
#                 removes them after `omarchy theme remove`)
#   --typography  VS Code + foot fonts (scripts/typography.sh, backed up)
#   --all         all of the above (default when no option is given)
#   --update-check  opt-in, not part of --all: install scripts/check-compat.sh as
#                 an Omarchy post-update hook so every `omarchy update` ends with
#                 a compatibility check (notification only when something broke)
#   --dry-run     show the plan only
# Nothing here needs sudo. Undo with scripts/rollback.sh.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"

DO_HOOK=0 DO_WALL=0 DO_TYPO=0 DO_COMPAT=0
for a in "$@"; do
  case "$a" in
    --hook) DO_HOOK=1 ;;
    --wallpapers) DO_WALL=1 ;;
    --typography) DO_TYPO=1 ;;
    --all) DO_HOOK=1 DO_WALL=1 DO_TYPO=1 ;;
    --update-check) DO_COMPAT=1 ;;
  esac
done
(( DO_HOOK + DO_WALL + DO_TYPO + DO_COMPAT )) || { DO_HOOK=1 DO_WALL=1 DO_TYPO=1; }
DRYFLAG=(); (( DRY_RUN )) && DRYFLAG=(--dry-run)

if (( DO_HOOK )); then
  src="$PROJECT_DIR/extras/theme-set-hook.sh"
  [[ -f $src ]] || die "Hook sumber tidak ada: $src"
  if [[ -f $HOOK_TARGET ]] && cmp -s "$src" "$HOOK_TARGET"; then
    log "Hook sudah terpasang: $HOOK_TARGET"
  elif [[ -e $HOOK_TARGET ]] && ! grep -q 'Obsidian Veil theme-set hook' "$HOOK_TARGET"; then
    die "$HOOK_TARGET ada tetapi bukan hook Obsidian Veil; tidak ditimpa."
  else
    log "Pasang hook -> $HOOK_TARGET"
    if (( ! DRY_RUN )); then
      mkdir -p "$OMARCHY_HOOK_DIR"
      tmp="$(mktemp "$OMARCHY_HOOK_DIR/.ov-hook.XXXXXX")"
      cp -- "$src" "$tmp"; chmod 755 "$tmp"; mv -f -- "$tmp" "$HOOK_TARGET"
    fi
  fi
fi

if (( DO_HOOK )); then
  src="$PROJECT_DIR/extras/theme-set-hook.sh"
  if [[ -f $POSTBOOT_HOOK_TARGET ]] && cmp -s "$src" "$POSTBOOT_HOOK_TARGET"; then
    log "Hook post-boot sudah terpasang: $POSTBOOT_HOOK_TARGET"
  elif [[ -e $POSTBOOT_HOOK_TARGET ]] && ! grep -q 'Obsidian Veil theme-set hook' "$POSTBOOT_HOOK_TARGET"; then
    die "$POSTBOOT_HOOK_TARGET ada tetapi bukan hook Obsidian Veil; tidak ditimpa."
  else
    log "Pasang hook post-boot (bersihkan wallpaper setelah tema dihapus) -> $POSTBOOT_HOOK_TARGET"
    if (( ! DRY_RUN )); then
      mkdir -p "${POSTBOOT_HOOK_TARGET%/*}"
      tmp="$(mktemp "${POSTBOOT_HOOK_TARGET%/*}/.ov-hook.XXXXXX")"
      cp -- "$src" "$tmp"; chmod 755 "$tmp"; mv -f -- "$tmp" "$POSTBOOT_HOOK_TARGET"
    fi
  fi
fi

if (( DO_HOOK )); then
  "$PROJECT_DIR/scripts/build-icons.sh" "${DRYFLAG[@]}"
fi

if (( DO_COMPAT )); then
  src="$PROJECT_DIR/scripts/check-compat.sh"
  if [[ -f $COMPAT_HOOK_TARGET ]] && cmp -s "$src" "$COMPAT_HOOK_TARGET"; then
    log "Hook post-update sudah terpasang: $COMPAT_HOOK_TARGET"
  elif [[ -e $COMPAT_HOOK_TARGET ]] && ! grep -q 'Obsidian Veil' "$COMPAT_HOOK_TARGET"; then
    die "$COMPAT_HOOK_TARGET ada tetapi bukan milik Obsidian Veil; tidak ditimpa."
  else
    log "Pasang hook post-update -> $COMPAT_HOOK_TARGET"
    if (( ! DRY_RUN )); then
      mkdir -p "${COMPAT_HOOK_TARGET%/*}"
      tmp="$(mktemp "${COMPAT_HOOK_TARGET%/*}/.ov-hook.XXXXXX")"
      cp -- "$src" "$tmp"; chmod 755 "$tmp"; mv -f -- "$tmp" "$COMPAT_HOOK_TARGET"
    fi
  fi
fi

if (( DO_WALL )); then
  # Local originals (development copy) make the download unnecessary.
  if [[ -f $SB_ORIGINALS_DIR/bg2.jpg && -f $SB_ORIGINALS_DIR/bg3.jpg && -f $SB_ORIGINALS_DIR/bg4.jpg ]]; then
    log "Wallpaper Resend: memakai file lokal di $SB_ORIGINALS_DIR"
  else
    "$PROJECT_DIR/scripts/fetch-wallpaper.sh" --resend "${DRYFLAG[@]}"
  fi
  "$PROJECT_DIR/scripts/build.sh" --user-backgrounds "${DRYFLAG[@]}"
fi

if (( DO_TYPO )); then
  "$PROJECT_DIR/scripts/typography.sh" "${DRYFLAG[@]}"
fi

# Re-apply the theme (without changing the wallpaper) so the hook runs now.
if (( DO_HOOK )) && [[ $(current_theme_name) == "$THEME_SLUG" ]]; then
  log "omarchy theme refresh"
  if (( ! DRY_RUN )); then
    omarchy theme refresh
  fi
fi
log "Selesai."
