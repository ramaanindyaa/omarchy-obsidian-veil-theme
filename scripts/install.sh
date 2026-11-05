#!/usr/bin/env bash
# Full install of Obsidian Veil with every feature:
#   1. backup of the current theme/wallpaper/VS Code state (first run only)
#   2. theme-set hook for the Lua extras (installed before the theme is set)
#   3. `omarchy theme install <repo>` — Omarchy's own installer
#   4. Resend wallpapers + typography (scripts/enable-extras.sh)
#   5. Black Ribbons as the initial wallpaper, error check, auto-rollback
#
# Usage: install.sh [--local] [--url <git-url>] [--no-extras] [--dry-run]
#   --local      clone from this working copy (file://; committed HEAD only)
#   --url        clone from another URL (default: this repo's origin, else GitHub)
#   --no-extras  skip wallpapers and typography (the hook is always installed)

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need omarchy
need git

URL="" EXTRAS=1
args=("$@")
for i in "${!args[@]}"; do
  case "${args[$i]}" in
    --local) URL="file://$PROJECT_DIR" ;;
    --url) URL="${args[$((i + 1))]:-}" ;;
    --no-extras) EXTRAS=0 ;;
  esac
done
if [[ -z $URL ]]; then
  URL="$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null || true)"
  [[ -n $URL ]] || URL="$DEFAULT_REPO_URL"
fi
[[ $(basename -- "${URL%/}" .git | sed -E 's/^omarchy-//; s/-theme$//') == "$THEME_SLUG" ]] ||
  die "URL $URL tidak menghasilkan nama tema '$THEME_SLUG' di omarchy theme install."

TS="$(date +%Y%m%d-%H%M%S)"
DRYFLAG=(); (( DRY_RUN )) && DRYFLAG=(--dry-run)

# --- 1. Backup -----------------------------------------------------------------
if [[ ! -e $SB_FIRST_BACKUP_LINK ]]; then
  prev="$(current_theme_name)"
  [[ $prev != "$THEME_SLUG" ]] || die "Tema aktif sudah $THEME_SLUG tetapi tidak ada backup pre-install."
  dir="$SB_BACKUP_ROOT/$TS-pre-install"
  log "Backup pre-install -> $dir (tema=$prev)"
  if (( ! DRY_RUN )); then
    ( umask 077; mkdir -p "$dir" )
    {
      printf 'PREV_THEME=%q\n' "$prev"
      printf 'PREV_BACKGROUND=%q\n' "$(current_background)"
      printf 'PREV_BACKGROUND_NAME=%q\n' "$(basename "$(current_background)")"
      printf 'PREV_ICON_THEME=%q\n' "$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)"
      printf 'PREV_COLOR_SCHEME=%q\n' "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"
      printf 'CREATED=%q\n' "$TS"
    } >"$dir/state.env"
    [[ -f $VSCODE_SETTINGS ]] && cp -a -- "$VSCODE_SETTINGS" "$dir/vscode-settings.json"
    [[ -e $THEME_TARGET ]] && cp -a -- "$THEME_TARGET" "$dir/existing-$THEME_SLUG"
    [[ -e $HOOK_TARGET ]] && cp -a -- "$HOOK_TARGET" "$dir/existing-hook"
    ln -sfn -- "backups/$TS-pre-install" "$SB_FIRST_BACKUP_LINK"
  fi
fi

# omarchy theme install deletes the target directory first; keep anything
# that is not a clean clone of this theme.
if [[ -e $THEME_TARGET ]] && ! clean_theme_clone "$THEME_TARGET"; then
  dest="$SB_BACKUP_ROOT/$TS-replaced-$THEME_SLUG"
  warn "$THEME_TARGET berisi perubahan/berkas lain; dibackup ke $dest sebelum diganti."
  if (( ! DRY_RUN )); then
    ( umask 077; mkdir -p "$dest" )
    cp -a -- "$THEME_TARGET" "$dest/"
  fi
fi

# --- 2. Hook (before the theme is set, so the first switch already has it) ------
"$PROJECT_DIR/scripts/enable-extras.sh" --hook "${DRYFLAG[@]}"

# --- 3. Omarchy's installer ----------------------------------------------------
# Re-setting the active theme makes Omarchy advance to its next wallpaper;
# remember the current one so a reinstall keeps it.
keep_bg=""
[[ $(current_theme_name) == "$THEME_SLUG" ]] && keep_bg="$(basename "$(current_background)")"
baseline="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
log "omarchy theme install $URL"
if (( DRY_RUN )); then
  echo "   [dry-run] OMARCHY_THEME_WAIT=1 omarchy theme install $URL"
else
  OMARCHY_THEME_WAIT=1 omarchy theme install "$URL" </dev/null
fi

# --- 4. Extras -------------------------------------------------------------------
if (( EXTRAS )); then
  "$PROJECT_DIR/scripts/enable-extras.sh" --wallpapers --typography "${DRYFLAG[@]}"
fi

(( DRY_RUN )) && exit 0

# --- 5. Wallpaper + checks -------------------------------------------------------
ribbons="$OMARCHY_CURRENT/theme/backgrounds/1-black-ribbons.jpg"
if [[ -n $keep_bg ]]; then
  for cand in "$OMARCHY_CURRENT/theme/backgrounds/$keep_bg" "$USER_BACKGROUNDS/$keep_bg"; do
    if [[ -f $cand && $(basename "$(current_background)") != "$keep_bg" ]]; then
      omarchy theme bg set "$cand" >/dev/null 2>&1 || true; break
    fi
  done
elif [[ $(basename "$(current_background)") != 1-black-ribbons.jpg && -f $ribbons ]] &&
   [[ ! -f $HOME/.local/state/omarchy/theme-backgrounds/$THEME_SLUG ]]; then
  omarchy theme bg set "$ribbons" >/dev/null 2>&1 || warn "Gagal memasang Black Ribbons sebagai wallpaper awal."
fi

sleep 1
now="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d' || true)"
if [[ -n $now && $now != "$baseline" ]]; then
  warn "Hyprland melaporkan error konfigurasi baru:"; printf '%s\n' "$now" >&2
  warn "Rollback otomatis..."
  "$PROJECT_DIR/scripts/rollback.sh"
  exit 1
fi
[[ $(current_theme_name) == "$THEME_SLUG" ]] || die "Tema aktif bukan $THEME_SLUG setelah install."
log "Aktif: $THEME_SLUG; background: $(current_background)"
log "Cek: $PROJECT_DIR/scripts/validate.sh --installed"
