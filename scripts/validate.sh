#!/usr/bin/env bash
# Static validation of the repository (and, with --installed, of the installed
# clone, hook and live session state). Writes nothing.
# Usage: validate.sh [--installed]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
need python3
need omarchy-theme-color

INSTALLED=0
for a in "$@"; do [[ $a == --installed ]] && INSTALLED=1; done
status=0
pass() { echo "  LULUS  $*"; }
fail() { echo "  GAGAL  $*"; status=1; }
info() { echo "  INFO   $*"; }

log "Sintaks Bash"
for s in "$PROJECT_DIR"/scripts/*.sh "$PROJECT_DIR"/extras/*.sh; do
  if bash -n "$s"; then pass "bash -n ${s#"$PROJECT_DIR"/}"; else fail "${s#"$PROJECT_DIR"/}"; fi
done
if command -v shellcheck >/dev/null; then
  shellcheck -x "$PROJECT_DIR"/scripts/*.sh "$PROJECT_DIR"/extras/*.sh || status=1
else
  info "shellcheck tidak terpasang; dilewati (tidak dipasang otomatis)"
fi

log "Lua extras"
if command -v luac >/dev/null; then
  luac -p "$PROJECT_DIR/extras/hyprland-extras.lua" && pass "luac -p extras/hyprland-extras.lua" || fail "luac"
else
  info "luac tidak ada; parse Lua diverifikasi lewat hyprctl configerrors"
fi

log "Kesiapan untuk omarchy theme install"
[[ -f $THEME_SRC/colors.toml ]] && pass "colors.toml di root repo" || fail "colors.toml tidak di root"
shopt -s nullglob
lua_root=("$THEME_SRC"/*.lua)
(( ${#lua_root[@]} == 0 )) && pass "tidak ada *.lua di root (akan dibuang Omarchy)" || fail "ada *.lua di root: ${lua_root[*]##*/}"
for f in alacritty.toml foot.ini ghostty.conf kitty.conf vscode.json; do
  [[ -e $THEME_SRC/$f ]] && fail "$f di root akan dibuang Omarchy"
done
pass "tidak ada file yang ditolak Omarchy (terminal config, vscode.json)"
name="$(basename -- "${DEFAULT_REPO_URL%/}" .git | sed -E 's/^omarchy-//; s/-theme$//')"
[[ $name == "$THEME_SLUG" ]] && pass "nama repo -> slug '$name'" || fail "nama repo menghasilkan '$name'"

log "Palet, override shell, VS Code, kontras"
tsv="$(mktemp)"; trap 'rm -f "$tsv"' EXIT
omarchy-theme-color --file "$THEME_SRC/colors.toml" --all >"$tsv"
python3 -I "$PROJECT_DIR/scripts/validate_static.py" "$THEME_SRC" "$tsv" || status=1

log "Wallpaper"
bgs=("$THEME_SRC"/backgrounds/*.{jpg,jpeg,png,webp})
(( ${#bgs[@]} > 0 )) || fail "tidak ada wallpaper di backgrounds/"
for f in "${bgs[@]}"; do
  dims="$(magick identify -format '%wx%h' "$f[0]" 2>/dev/null)" || { fail "$f tidak bisa didekode"; continue; }
  pass "backgrounds/$(basename "$f") $(file -b --mime-type "$f") $dims"
done

log "Unlock (Plymouth)"
if [[ -f $THEME_SRC/unlock.png ]]; then
  i="$(magick identify -format '%m %wx%h %[channels]' "$THEME_SRC/unlock.png" 2>/dev/null)" || i=""
  [[ $i == PNG* && $i == *srgba* ]] && pass "unlock.png $i (transparan)" || fail "unlock.png bukan PNG RGBA: $i"
  [[ -f $THEME_SRC/preview-unlock.png ]] && pass "preview-unlock.png ada" || info "preview-unlock.png belum dibuat"
fi

if (( INSTALLED )); then
  log "Instalasi"
  if [[ -d $THEME_TARGET/.git ]]; then
    pass "$THEME_TARGET adalah clone git ($(git -C "$THEME_TARGET" remote get-url origin))"
    clean_theme_clone "$THEME_TARGET" && pass "clone bersih" || fail "clone berisi perubahan"
    if [[ -d $PROJECT_DIR/.git && $PROJECT_DIR != "$THEME_TARGET" ]]; then
      a="$(git -C "$THEME_TARGET" rev-parse HEAD)"; b="$(git -C "$PROJECT_DIR" rev-parse HEAD)"
      [[ $a == "$b" ]] && pass "commit terpasang = commit proyek (${a:0:7})" || info "commit terpasang ${a:0:7} ≠ proyek ${b:0:7}"
    fi
  else
    fail "tema belum terpasang sebagai clone git di $THEME_TARGET"
  fi
  if [[ -f $HOOK_TARGET ]] && cmp -s "$HOOK_TARGET" "$PROJECT_DIR/extras/theme-set-hook.sh"; then
    pass "hook $HOOK_NAME terpasang"
  else
    fail "hook $HOOK_NAME tidak terpasang/berbeda (scripts/enable-extras.sh --hook)"
  fi
  if [[ -f $ICON_TARGET/.obsidian-veil ]]; then
    pass "ikon $ICON_THEME_NAME terpasang ($(find "$ICON_TARGET" -name '*.png' | wc -l) PNG)"
    broken="$(find -L "$ICON_TARGET" -type l | wc -l)"
    (( broken == 0 )) && pass "tidak ada symlink ikon yang rusak" || fail "$broken symlink ikon rusak"
  else
    fail "ikon $ICON_THEME_NAME belum dibangun (scripts/enable-extras.sh --hook)"
  fi
  if [[ -f $COMPAT_HOOK_TARGET ]]; then
    cmp -s "$COMPAT_HOOK_TARGET" "$PROJECT_DIR/scripts/check-compat.sh" && pass "hook post-update (opsional) terpasang" || info "hook post-update berbeda dari scripts/check-compat.sh"
  else
    info "hook post-update opsional tidak terpasang (enable-extras.sh --update-check)"
  fi
  if [[ $(current_theme_name) == "$THEME_SLUG" ]]; then
    [[ $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null) == "'$ICON_THEME_NAME'" ]] &&
      pass "ikon GTK aktif: $ICON_THEME_NAME" || fail "ikon GTK bukan $ICON_THEME_NAME"
    grep -qF -- '-- >>> obsidian-veil extras' "$OMARCHY_CURRENT/theme/hyprland.lua" &&
      pass "extras Lua aktif di current/theme/hyprland.lua" || fail "extras Lua belum aktif"
    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
      for o in general:border_size decoration:rounding; do
        info "$o = $(hyprctl -j getoption "$o" | jq -c '.int')"
      done
      pid="$(pgrep -x quickshell | head -1 || true)"
      if [[ -n $pid ]] && tr '\0' '\n' <"/proc/$pid/environ" | grep -qx 'OMARCHY_MENU_FONT=IBM Plex Sans'; then
        pass "Omarchy shell memakai OMARCHY_MENU_FONT=IBM Plex Sans"
      else
        fail "Omarchy shell belum memakai font menu"
      fi
      errs="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d')"
      [[ -z $errs ]] && pass "hyprctl configerrors kosong" || fail "$errs"
    fi
  fi
  info "tema aktif: $(current_theme_name); background: $(current_background)"
fi

exit "$status"
