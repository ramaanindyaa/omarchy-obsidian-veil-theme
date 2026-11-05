#!/usr/bin/env bash
# Build generated assets.
#   (default)            repository files: backgrounds/1-black-ribbons.jpg,
#                        backgrounds/5-black-dune.png, 6..8 (user-supplied),
#                        vscode-theme.json
#                        (rendered from Omarchy's own template + overrides).
#                        Development only: needs the local originals.
#   --user-backgrounds   Resend wallpapers -> ~/.config/omarchy/backgrounds/obsidian-veil/
#                        (Omarchy's per-theme user background folder; never the repo)
# Derivatives are at most 3840x2160, no crop for 16:9, no upscaling, no hue
# changes. AVIF is converted because Omarchy 4.5 only lists
# jpg/jpeg/png/gif/bmp/webp backgrounds.
# Usage: build.sh [--user-backgrounds] [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need magick
[[ -n ${OMARCHY_PATH:-} ]] || OMARCHY_PATH=/usr/share/omarchy

USER_BG=0
for a in "$@"; do [[ $a == --user-backgrounds ]] && USER_BG=1; done

LOCAL_SRC="$PROJECT_DIR/Backgrounds"   # originals supplied locally (git-ignored)
CACHE_SRC="$SB_WALLPAPER_CACHE"        # fetch-wallpaper.sh downloads
VSCODE_TPL="$OMARCHY_PATH/default/themed/vscode-theme.json.tpl"

# name | candidates "path:op,..." (absolute paths; first existing wins)
if (( USER_BG )); then
  OUT="$USER_BACKGROUNDS"
  WALLPAPERS=(
    "2-pilulae.jpg|$LOCAL_SRC/bg2.jpg:resize,$CACHE_SRC/pilulae.jpg:resize"
    "3-discus.jpg|$LOCAL_SRC/bg3.jpg:resize,$CACHE_SRC/discus.jpg:resize"
    "4-cubus.jpg|$LOCAL_SRC/bg4.jpg:resize,$CACHE_SRC/cubus.jpg:resize"
  )
else
  OUT="$PROJECT_DIR/backgrounds"
  WALLPAPERS=(
    "1-black-ribbons.jpg|$CACHE_SRC/black-ribbons-3840.jpg:copy,$LOCAL_SRC/source/black-ribbons-3840.jpg:copy,$LOCAL_SRC/bg1.avif:convert"
    "5-black-dune.png|$LOCAL_SRC/bg5.avif:convert"
    "6-black-arc.jpg|$LOCAL_SRC/bg6.jpg:copy"
    "7-silver-wave.jpg|$LOCAL_SRC/bg7.jpg:resize"
    "8-graphite-curve.jpg|$LOCAL_SRC/bg8.png:resize"
  )
fi

build_wallpaper() {
  local name="$1" cands="$2" dest="$OUT/$1" tmp cand src="" op=""
  IFS=',' read -ra list <<<"$cands"
  for cand in "${list[@]}"; do
    if [[ -f ${cand%:*} ]]; then src="${cand%:*}"; op="${cand##*:}"; break; fi
  done
  if [[ -z $src ]]; then
    [[ -f $dest ]] || warn "Lewati $name: sumber tidak ada (jalankan scripts/fetch-wallpaper.sh --all)."
    return 0
  fi
  if [[ -f $dest && $dest -nt $src ]]; then
    return 0
  fi
  if (( DRY_RUN )); then
    printf '   [dry-run] %s %s -> %s\n' "$op" "$src" "$dest"; return 0
  fi
  mkdir -p "$OUT"
  tmp="$(mktemp "$OUT/.tmp.XXXXXX").${name##*.}"
  case "$op" in
    copy)    cp -- "$src" "$tmp" ;;
    resize)  magick "$src" -resize '3840x2160>' -strip -quality 92 "$tmp" ;;
    convert) magick "$src[0]" -strip -quality 95 "$tmp" ;;
  esac
  chmod 644 -- "$tmp"
  mv -f -- "$tmp" "$dest"
  rm -f -- "${tmp%.*}"
  log "wallpaper $dest ($(magick identify -format '%wx%h' "$dest"))"
}

for entry in "${WALLPAPERS[@]}"; do
  build_wallpaper "${entry%%|*}" "${entry#*|}"
done

if (( USER_BG )); then
  # Record what we generated so rollback.sh removes only untouched files.
  if (( ! DRY_RUN )) && [[ -d $OUT ]]; then
    mkdir -p "$SB_STATE_DIR"
    for entry in "${WALLPAPERS[@]}"; do
      f="$OUT/${entry%%|*}"
      if [[ -f $f ]]; then printf '%s  %s\n' "$(sha_of "$f")" "$f"; fi
    done >"$SB_STATE_DIR/user-backgrounds.sha256"
  fi
  exit 0
fi

need python3
need omarchy-theme-color
[[ -f $VSCODE_TPL ]] || die "Template VS Code Omarchy tidak ditemukan: $VSCODE_TPL"
if (( DRY_RUN )); then
  log "[dry-run] render $VSCODE_TPL -> $THEME_SRC/vscode-theme.json"
else
  tsv="$(mktemp)"; out="$(mktemp "$THEME_SRC/.vscode.XXXXXX")"
  trap 'rm -f "$tsv" "$out"' EXIT
  omarchy-theme-color --file "$THEME_SRC/colors.toml" --all >"$tsv"
  python3 -I "$PROJECT_DIR/scripts/build_vscode.py" "$VSCODE_TPL" "$tsv" "$out" 2>/dev/null
  chmod 644 "$out"
  if cmp -s "$out" "$THEME_SRC/vscode-theme.json"; then
    rm -f "$out"
  else
    mv -f -- "$out" "$THEME_SRC/vscode-theme.json"
    log "vscode-theme.json dirender dari $(basename "$VSCODE_TPL")"
  fi
  # Lets check-compat.sh notice when Omarchy changes the VS Code template.
  printf 'vscode-theme.json.tpl=%s\n' "$(sha_of "$VSCODE_TPL")" >"$PROJECT_DIR/extras/omarchy-compat.sha256"
fi
