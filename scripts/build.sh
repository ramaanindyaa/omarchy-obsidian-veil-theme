#!/usr/bin/env bash
# Build generated theme assets inside the project (never in the live theme):
#   theme/vscode-theme.json  (rendered from Omarchy's own template + overrides)
#   theme/backgrounds/*      (fill-ready derivatives; originals stay in Backgrounds/)
# Usage: build.sh [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need magick
need python3
need omarchy-theme-color
[[ -n ${OMARCHY_PATH:-} ]] || OMARCHY_PATH=/usr/share/omarchy

SRC="$PROJECT_DIR/Backgrounds"
OUT="$THEME_SRC/backgrounds"
VSCODE_TPL="$OMARCHY_PATH/default/themed/vscode-theme.json.tpl"

# name | candidates "path:op,path:op" (first existing wins; paths relative to Backgrounds/)
# Derivatives are 3840 px wide at most (panel is 1920x1080 physical, scale 1.25)
# with no crop for 16:9 sources; AVIF is converted because Omarchy 4.5 only
# lists jpg/jpeg/png/gif/bmp/webp backgrounds. No upscaling, no hue changes.
# A fresh clone has no Backgrounds/: committed derivatives are kept as they are,
# and the Resend ones come from `scripts/fetch-wallpaper.sh --all`.
declare -a WALLPAPERS=(
  "1-black-ribbons.jpg|source/black-ribbons-3840.jpg:copy,bg1.avif:convert"
  "2-pilulae.jpg|bg2.jpg:resize,source/pilulae.jpg:resize"
  "3-discus.jpg|bg3.jpg:resize,source/discus.jpg:resize"
  "4-cubus.jpg|bg4.jpg:resize,source/cubus.jpg:resize"
  "5-black-dune.png|bg5.avif:convert"
)

build_wallpaper() {
  local name="$1" cands="$2" dest="$OUT/$1" tmp cand src="" op=""
  IFS=',' read -ra list <<<"$cands"
  for cand in "${list[@]}"; do
    if [[ -f $SRC/${cand%%:*} ]]; then src="${cand%%:*}"; op="${cand##*:}"; break; fi
  done
  if [[ -z $src ]]; then
    [[ -f $dest ]] || warn "Lewati $name: sumber tidak ada (jalankan scripts/fetch-wallpaper.sh --all)."
    return 0
  fi
  if [[ -f $dest && $dest -nt $SRC/$src ]]; then
    return 0
  fi
  if (( DRY_RUN )); then
    printf '   [dry-run] %s %s -> %s\n' "$op" "$src" "$dest"; return 0
  fi
  tmp="$(mktemp "$OUT/.tmp.XXXXXX").${name##*.}"
  case "$op" in
    copy)    cp -- "$SRC/$src" "$tmp" ;;
    resize)  magick "$SRC/$src" -resize '3840x2160>' -strip -quality 92 "$tmp" ;;
    convert) magick "$SRC/$src[0]" -strip -quality 95 "$tmp" ;;
  esac
  chmod 644 -- "$tmp"
  mv -f -- "$tmp" "$dest"
  rm -f -- "${tmp%.*}"
  log "wallpaper $name ($(magick identify -format '%wx%h' "$dest"))"
}

if (( ! DRY_RUN )); then mkdir -p "$OUT"; fi
for entry in "${WALLPAPERS[@]}"; do
  build_wallpaper "${entry%%|*}" "${entry#*|}"
done

[[ -f $VSCODE_TPL ]] || die "Template VS Code Omarchy tidak ditemukan: $VSCODE_TPL"
if (( DRY_RUN )); then
  log "[dry-run] render $VSCODE_TPL -> $THEME_SRC/vscode-theme.json"
else
  tsv="$(mktemp)"; out="$(mktemp "$THEME_SRC/.vscode.XXXXXX")"
  trap 'rm -f "$tsv" "$out"' EXIT
  omarchy-theme-color --file "$THEME_SRC/colors.toml" --all >"$tsv"
  python3 -I "$PROJECT_DIR/scripts/build_vscode.py" "$VSCODE_TPL" "$tsv" "$out"
  chmod 644 "$out"
  mv -f -- "$out" "$THEME_SRC/vscode-theme.json"
  log "vscode-theme.json dirender dari $(basename "$VSCODE_TPL")"
fi
