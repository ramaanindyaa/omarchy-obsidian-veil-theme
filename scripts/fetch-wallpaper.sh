#!/usr/bin/env bash
# Download wallpaper originals as image data only (nothing is executed) into
# ~/.cache/obsidian-veil/wallpapers/ (outside the repository).
#   (default)  Black Ribbons 3840 px (Unsplash, Andrew Kliatskyi) — source of
#              the committed backgrounds/1-black-ribbons.jpg
#   --resend   Pilulae, Discus, Cubus (Raphael Fagundes for Resend); not in the
#              repository because their redistribution terms are unclear
#   --all      both
# Usage: fetch-wallpaper.sh [--resend|--all] [--dry-run]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need curl
need magick

RIBBONS=1 RESEND=0
for a in "$@"; do
  case "$a" in
    --resend) RIBBONS=0 RESEND=1 ;;
    --all) RIBBONS=1 RESEND=1 ;;
  esac
done

DEST_DIR="$SB_WALLPAPER_CACHE"
WALLS=()
(( RIBBONS )) && WALLS+=("black-ribbons-3840.jpg|https://images.unsplash.com/photo-1678366633407-7f49da199a42?auto=format&fit=max&w=3840&q=90")
(( RESEND )) && WALLS+=(
  "pilulae.jpg|https://cdn.resend.com/wallpapers/7-a.jpg"
  "discus.jpg|https://cdn.resend.com/wallpapers/2-a.jpg"
  "cubus.jpg|https://cdn.resend.com/wallpapers/6-a.jpg"
)

fetch_one() {
  local name="$1" url="$2" dest="$DEST_DIR/$1" tmp mime dims
  if [[ -f $dest ]]; then
    log "Sudah ada: $name ($(sha_of "$dest"))"; return 0
  fi
  if (( DRY_RUN )); then
    log "[dry-run] unduh $url -> $dest"; return 0
  fi
  mkdir -p "$DEST_DIR"
  tmp="$(mktemp "$DEST_DIR/.download.XXXXXX")"
  # Ask for JPEG explicitly so image CDNs do not negotiate AVIF.
  if ! curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
      --connect-timeout 15 --max-time 300 --retry 2 \
      -H 'Accept: image/jpeg' -A 'obsidian-veil-wallpaper-fetch' \
      -o "$tmp" "$url"; then
    rm -f "$tmp"; die "Unduhan gagal: $url"
  fi
  mime="$(file -b --mime-type "$tmp")"
  [[ $mime == image/* ]] || { rm -f "$tmp"; die "Respons bukan gambar ($mime): $url"; }
  dims="$(magick identify -format '%wx%h' "$tmp[0]")" || { rm -f "$tmp"; die "Gambar tidak bisa didekode: $url"; }
  chmod 644 "$tmp"
  mv -f "$tmp" "$dest"
  log "Tersimpan $name: MIME=$mime dimensi=$dims ukuran=$(stat -c %s "$dest") sha256=$(sha_of "$dest")"
}

for entry in "${WALLS[@]}"; do
  fetch_one "${entry%%|*}" "${entry#*|}"
done
