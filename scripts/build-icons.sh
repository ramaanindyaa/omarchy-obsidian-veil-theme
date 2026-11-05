#!/usr/bin/env bash
# Build the local icon theme "ObsidianVeil-Graphite" in ~/.local/share/icons/.
# It recolours the accent icons of the system's Yaru-blue (folders, places, a
# few apps/actions/devices: 263 files) into a cool graphite ramp
# #2A3038 -> #C9D0D9 and inherits everything else from Yaru. Generated locally
# from the installed Yaru (CC BY-SA 4.0); nothing is downloaded or committed.
# The theme-set hook selects it while Obsidian Veil is active.
# Usage: build-icons.sh [--dry-run] [--force]

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
need magick
need python3
FORCE=0
for a in "$@"; do [[ $a == --force ]] && FORCE=1; done

SRC="/usr/share/icons/Yaru-blue"
LO="#2A3038" HI="#C9D0D9" LEVEL="0%,65%"
[[ -f $SRC/index.theme ]] || die "Yaru-blue tidak ditemukan di $SRC."

stamp="src=$(sha256sum "$SRC/index.theme" | cut -c1-16) map=$LO,$HI,$LEVEL v=1"
if [[ -f $ICON_TARGET/.obsidian-veil && $(cat "$ICON_TARGET/.obsidian-veil") == "$stamp" ]] && (( ! FORCE )); then
  log "Ikon $ICON_THEME_NAME sudah terbaru."
  exit 0
fi
if [[ -e $ICON_TARGET && ! -f $ICON_TARGET/.obsidian-veil ]]; then
  die "$ICON_TARGET ada tetapi bukan buatan Obsidian Veil; tidak ditimpa."
fi
if (( DRY_RUN )); then
  log "[dry-run] bangun $ICON_TARGET dari $SRC ($(find "$SRC" -type f | wc -l) file, pemetaan $LO→$HI)"
  exit 0
fi

mkdir -p "${ICON_TARGET%/*}"
stage="$(mktemp -d "${ICON_TARGET%/*}/.ov-icons.XXXXXX")"
trap 'rm -rf "$stage"' EXIT

# Directory layout and symlinks exactly as in Yaru-blue.
( cd "$SRC" && find . -type d -print0 ) | ( cd "$stage" && xargs -0 mkdir -p )
( cd "$SRC" && find . -type l -print0 ) | while IFS= read -r -d '' l; do
  ln -s "$(readlink "$SRC/$l")" "$stage/$l"
done

# PNG: luminance -> graphite ramp, alpha preserved.
n=0
while IFS= read -r -d '' f; do
  magick "$SRC/$f" -alpha set \( +clone -alpha extract \) \
    \( -clone 0 -alpha off -colorspace sRGB -grayscale Rec709Luminance -colorspace sRGB \
       -level "$LEVEL" +level-colors "$LO","$HI" \) \
    -delete 0 +swap -compose CopyOpacity -composite "$stage/$f"
  n=$((n + 1))
done < <(cd "$SRC" && find . -type f -name '*.png' -printf '%P\0')

# SVG: map every hex colour through the same ramp.
python3 -I - "$SRC" "$stage" "$LO" "$HI" <<'PY'
import pathlib, re, sys
src, dst, lo, hi = sys.argv[1:5]
lo = [int(lo[i:i + 2], 16) for i in (1, 3, 5)]
hi = [int(hi[i:i + 2], 16) for i in (1, 3, 5)]
def lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def enc(c):
    c = c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
    return c
def conv(m):
    h = m.group(1)
    if len(h) == 3:
        h = "".join(ch * 2 for ch in h)
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    y = enc(0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b))
    y = min(1.0, y / 0.65)
    return "#%02x%02x%02x" % tuple(round(l + (h_ - l) * y) for l, h_ in zip(lo, hi))
for p in pathlib.Path(src).rglob("*.svg"):
    if p.is_symlink():
        continue
    out = pathlib.Path(dst) / p.relative_to(src)
    out.write_text(re.sub(r"#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b", conv, p.read_text()))
PY

sed -e "s/^Name=.*/Name=$ICON_THEME_NAME/" \
    -e "s/^Comment=.*/Comment=Obsidian Veil graphite accents, generated from Yaru-blue (CC BY-SA 4.0)/" \
    "$SRC/index.theme" >"$stage/index.theme"
printf '%s\n' "$stamp" >"$stage/.obsidian-veil"
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -f -t "$stage" 2>/dev/null || true
chmod -R u+rwX,go+rX "$stage"

old=""
if [[ -d $ICON_TARGET ]]; then old="$ICON_TARGET.old.$$"; mv -- "$ICON_TARGET" "$old"; fi
mv -- "$stage" "$ICON_TARGET"
trap - EXIT
[[ -z $old ]] || rm -rf -- "$old"
log "Ikon $ICON_THEME_NAME dibangun: $n PNG + SVG di $ICON_TARGET"
