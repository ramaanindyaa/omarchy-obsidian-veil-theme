#!/usr/bin/env bash
# Back up, then install theme/ as ~/.config/omarchy/themes/stealth-black.
# Does NOT activate the theme (see apply.sh). Idempotent: an unchanged reinstall
# writes nothing and creates no backup.
# Usage: install.sh [--dry-run] [--force]
#   --force  replace an existing stealth-black directory that this project did
#            not create (it is backed up first).

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
FORCE=0
for a in "$@"; do [[ $a == --force ]] && FORCE=1; done

[[ -f $THEME_SRC/colors.toml ]] || die "theme/colors.toml tidak ada."
[[ -f $THEME_SRC/vscode-theme.json ]] || die "Jalankan scripts/build.sh dulu."
[[ -d $THEME_SRC/backgrounds ]] || die "theme/backgrounds kosong; jalankan scripts/build.sh."

OWNED_MARK=".stealth-black-owned"
TS="$(date +%Y%m%d-%H%M%S)"

# --- Backup -----------------------------------------------------------------

record_path() { # <manifest> <path>
  local m="$1" p="$2"
  if [[ -L $p ]]; then
    printf 'symlink\t%s\t%s\n' "$p" "$(readlink "$p")" >>"$m"
  elif [[ -f $p ]]; then
    printf 'file\t%s\t%s\n' "$p" "$(sha_of "$p")" >>"$m"
  elif [[ -d $p ]]; then
    printf 'dir\t%s\t-\n' "$p" >>"$m"
  else
    printf 'absent\t%s\t-\n' "$p" >>"$m"
  fi
}

# One "pre-install" snapshot of what the theme switch will change. Created on
# the first install only, so repeated installs never multiply backups.
make_pre_install_backup() {
  local dir="$SB_BACKUP_ROOT/$TS-pre-install" prev
  prev="$(current_theme_name)"
  if [[ $prev == "$THEME_SLUG" ]]; then
    die "Tema aktif sudah $THEME_SLUG tetapi tidak ada backup pre-install; tidak bisa merekam tema awal."
  fi
  log "Backup pre-install -> $dir"
  if (( DRY_RUN )); then
    printf '   [dry-run] simpan tema=%s background=%s, settings VS Code, gsettings\n' "$prev" "$(current_background)"
    return
  fi
  local old_umask; old_umask="$(umask)"
  umask 077
  mkdir -p "$dir"
  {
    printf 'PREV_THEME=%q\n' "$prev"
    printf 'PREV_BACKGROUND=%q\n' "$(current_background)"
    printf 'PREV_BACKGROUND_NAME=%q\n' "$(basename "$(current_background)")"
    printf 'PREV_ICON_THEME=%q\n' "$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)"
    printf 'PREV_COLOR_SCHEME=%q\n' "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"
    printf 'PREV_VSCODE_COLOR_THEME=%q\n' "$(grep -oE '"workbench.colorTheme"[[:space:]]*:[[:space:]]*"[^"]*"' "$VSCODE_SETTINGS" 2>/dev/null | sed -E 's/.*:[[:space:]]*"(.*)"/\1/' || true)"
    printf 'CREATED=%q\n' "$TS"
  } >"$dir/state.env"
  : >"$dir/files.manifest"
  for p in "$VSCODE_SETTINGS" "$THEME_TARGET" "$OMARCHY_CURRENT/theme.name" "$OMARCHY_CURRENT/background"; do
    record_path "$dir/files.manifest" "$p"
  done
  [[ -f $VSCODE_SETTINGS ]] && cp -a -- "$VSCODE_SETTINGS" "$dir/vscode-settings.json"
  cp -a -- "$OMARCHY_CURRENT/theme.name" "$dir/theme.name" 2>/dev/null || true
  if [[ -e $THEME_TARGET ]]; then
    cp -a -- "$THEME_TARGET" "$dir/existing-stealth-black"
  fi
  ln -sfn -- "$dir" "$SB_FIRST_BACKUP_LINK"
  umask "$old_umask"
}

backup_target_dir() { # <reason>
  local dir="$SB_BACKUP_ROOT/$TS-$1"
  log "Backup $THEME_TARGET -> $dir"
  if (( ! DRY_RUN )); then
    ( umask 077; mkdir -p "$dir" )
    cp -a -- "$THEME_TARGET" "$dir/stealth-black"
    tree_manifest "$THEME_TARGET" >"$dir/stealth-black.sha256"
  fi
}

# --- Decide ------------------------------------------------------------------

[[ -d $SB_STATE_DIR ]] || run mkdir -p "$SB_STATE_DIR"
[[ -e $SB_FIRST_BACKUP_LINK ]] || make_pre_install_backup

if [[ -L $THEME_TARGET ]]; then
  die "$THEME_TARGET adalah symlink ($(readlink "$THEME_TARGET")); tidak menulis menembus symlink."
fi

if [[ -d $THEME_TARGET ]]; then
  if [[ ! -f $THEME_TARGET/$OWNED_MARK ]]; then
    (( FORCE )) || die "$THEME_TARGET sudah ada dan bukan buatan proyek ini. Periksa isinya, lalu jalankan ulang dengan --force (akan dibackup)."
    backup_target_dir foreign
  elif diff -rq --exclude="$OWNED_MARK" "$THEME_SRC" "$THEME_TARGET" >/dev/null 2>&1; then
    log "Tema terpasang sudah identik dengan proyek; tidak ada perubahan."
    exit 0
  elif [[ -f $SB_INSTALL_MANIFEST ]] && [[ "$(tree_manifest "$THEME_TARGET")" == "$(cat "$SB_INSTALL_MANIFEST")" ]]; then
    log "Memperbarui tema terpasang (tidak ada edit pengguna sejak install terakhir)."
  else
    warn "Tema terpasang diedit setelah install; edit tersebut dibackup sebelum diganti."
    backup_target_dir user-edited
  fi
fi

# --- Install (stage + atomic swap on the same filesystem) ---------------------

log "Pasang $THEME_SRC -> $THEME_TARGET"
if (( DRY_RUN )); then
  ( cd "$THEME_SRC" && find . -type f | sort | sed 's|^\./|   [dry-run] + |' )
  exit 0
fi

mkdir -p "$OMARCHY_USER_THEMES"
stage="$(mktemp -d "$OMARCHY_USER_THEMES/.stealth-black.new.XXXXXX")"
old=""
cleanup() { rm -rf -- "$stage"; [[ -z $old ]] || rm -rf -- "$old"; }
trap cleanup EXIT

cp -a -- "$THEME_SRC/." "$stage/"
printf 'Installed by %s on %s. Rollback removes this directory only if unmodified.\n' \
  "$PROJECT_DIR/scripts/install.sh" "$TS" >"$stage/$OWNED_MARK"
chmod 755 "$stage"

if [[ -d $THEME_TARGET ]]; then
  old="$OMARCHY_USER_THEMES/.stealth-black.old.$$"
  mv -- "$THEME_TARGET" "$old"
fi
mv -- "$stage" "$THEME_TARGET"
stage=""
tree_manifest "$THEME_TARGET" >"$SB_INSTALL_MANIFEST"

log "Terpasang. Aktifkan dengan: $PROJECT_DIR/scripts/apply.sh"
