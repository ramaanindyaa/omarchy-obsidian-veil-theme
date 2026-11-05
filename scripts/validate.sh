#!/usr/bin/env bash
# Static validation of the project (and, with --installed, of the installed copy
# and the live session state). Writes nothing. Usage: validate.sh [--installed]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
need python3
need omarchy-theme-color

INSTALLED=0
for a in "$@"; do [[ $a == --installed ]] && INSTALLED=1; done
status=0

log "Sintaks Bash"
for s in "$PROJECT_DIR"/scripts/*.sh; do
  if bash -n "$s"; then echo "  LULUS  bash -n $(basename "$s")"; else echo "  GAGAL  $(basename "$s")"; status=1; fi
done
if command -v shellcheck >/dev/null; then
  shellcheck -x "$PROJECT_DIR"/scripts/*.sh || status=1
else
  echo "  INFO   shellcheck tidak terpasang; dilewati (tidak dipasang otomatis)"
fi

log "Sintaks Lua (hyprland.lua)"
if command -v luac >/dev/null; then
  luac -p "$THEME_SRC/hyprland.lua" && echo "  LULUS  luac -p" || status=1
elif command -v luajit >/dev/null; then
  luajit -bl "$THEME_SRC/hyprland.lua" >/dev/null && echo "  LULUS  luajit parse" || status=1
else
  echo "  INFO   tidak ada luac/luajit; parse Lua diverifikasi lewat hyprctl configerrors saat apply"
fi

log "Palet, override shell, VS Code, kontras"
tsv="$(mktemp)"; trap 'rm -f "$tsv"' EXIT
omarchy-theme-color --file "$THEME_SRC/colors.toml" --all >"$tsv"
python3 -I "$PROJECT_DIR/scripts/validate_static.py" "$THEME_SRC" "$tsv" || status=1

log "Wallpaper"
shopt -s nullglob
bgs=("$THEME_SRC"/backgrounds/*.{jpg,jpeg,png,webp})
(( ${#bgs[@]} > 0 )) || { echo "  GAGAL  tidak ada wallpaper"; status=1; }
for f in "${bgs[@]}"; do
  mime="$(file -b --mime-type "$f")"
  dims="$(magick identify -format '%wx%h' "$f[0]" 2>/dev/null)" || { echo "  GAGAL  $f tidak bisa didekode"; status=1; continue; }
  echo "  LULUS  $(basename "$f") $mime $dims"
done

log "Unlock (Plymouth)"
if [[ -f $THEME_SRC/unlock.png ]]; then
  info="$(magick identify -format '%m %wx%h %[channels]' "$THEME_SRC/unlock.png" 2>/dev/null)" || info=""
  if [[ $info == PNG* && $info == *srgba* ]]; then
    echo "  LULUS  unlock.png $info (transparan)"
  else
    echo "  GAGAL  unlock.png bukan PNG RGBA: $info"; status=1
  fi
  [[ -f $THEME_SRC/preview-unlock.png ]] && echo "  LULUS  preview-unlock.png ada" || echo "  INFO   preview-unlock.png belum dibuat"
else
  echo "  INFO   tidak ada unlock.png (Plymouth memakai default Omarchy)"
fi

if (( INSTALLED )); then
  log "Salinan terpasang"
  if [[ -d $THEME_TARGET ]]; then
    if diff -rq --exclude=.stealth-black-owned "$THEME_SRC" "$THEME_TARGET" >/dev/null; then
      echo "  LULUS  $THEME_TARGET identik dengan proyek"
    else
      echo "  GAGAL  $THEME_TARGET berbeda dari proyek"; status=1
    fi
  else
    echo "  GAGAL  tema belum terpasang"; status=1
  fi
  if command -v hyprctl >/dev/null && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    errs="$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d')"
    if [[ -z $errs ]]; then echo "  LULUS  hyprctl configerrors kosong"; else echo "  GAGAL  $errs"; status=1; fi
  fi
  echo "  INFO   tema aktif: $(current_theme_name); background: $(current_background)"
fi

exit "$status"
