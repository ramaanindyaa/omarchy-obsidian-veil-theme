#!/usr/bin/env bash
# Build unlock.png (Plymouth LUKS unlock / boot logo) and a real preview
# rendered by Omarchy's own `omarchy plymouth preview`.
# Source mark: the Omarchy wordmark shipped with the stock matte-black theme
# (Omarchy, MIT), recoloured to a brushed-silver ramp: #EEF1F5 -> #A9B4C2 -> #7E8794.
# No glow, no new logo. Usage: build_unlock.sh [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need magick
[[ -n ${OMARCHY_PATH:-} ]] || OMARCHY_PATH=/usr/share/omarchy

SRC="$OMARCHY_PATH/themes/matte-black/unlock.png"
OUT="$THEME_SRC/unlock.png"
PREVIEW="$THEME_SRC/preview-unlock.png"
[[ -f $SRC ]] || die "Wordmark sumber tidak ada: $SRC"

if (( DRY_RUN )); then
  log "[dry-run] $SRC -> $OUT (silver ramp), preview -> $PREVIEW"; exit 0
fi

read -r w h < <(magick identify -format '%w %h\n' "$SRC")
tmp="$(mktemp --suffix=.png)"; trap 'rm -f "$tmp"' EXIT
# Gradient fill clipped by the wordmark's own alpha.
magick -size "${w}x${h}" gradient:'#EEF1F5'-'#7E8794' \
  \( "$SRC" -alpha extract \) -alpha off -compose CopyOpacity -composite \
  -define png:color-type=6 -strip "$tmp"
chmod 644 "$tmp"; mv -f "$tmp" "$OUT"
log "unlock.png ${w}x${h}"

if command -v omarchy-plymouth-preview >/dev/null; then
  ptmp="$(mktemp --suffix=.png)"
  omarchy-plymouth-preview '#101216' '#D7DCE2' "$OUT" "$ptmp" >/dev/null
  chmod 644 "$ptmp"; mv -f "$ptmp" "$PREVIEW"
  log "preview-unlock.png dirender oleh omarchy-plymouth-preview"
fi
