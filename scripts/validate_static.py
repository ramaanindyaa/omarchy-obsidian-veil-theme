#!/usr/bin/env python3
"""Static checks for the Stealth Black theme directory.
Usage: validate_static.py <theme-dir> <resolved-colors.tsv>
Exit status is nonzero when any check fails."""

import json
import pathlib
import re
import sys
import tomllib

theme = pathlib.Path(sys.argv[1])
resolved_path = pathlib.Path(sys.argv[2])
failures = 0
HEX = re.compile(r"^#[0-9A-Fa-f]{6}$")


def ok(msg):
    print(f"  LULUS  {msg}")


def fail(msg):
    global failures
    failures += 1
    print(f"  GAGAL  {msg}")


# Keys omarchy-theme-color (Omarchy 4.5) reads or derives.
KNOWN = {
    "mode", "theme_type", "accent", "selection", "selection_background",
    "selection_foreground", "muted", "background", "dark_background",
    "darker_background", "lighter_background", "foreground", "dark_foreground",
    "light_foreground", "bright_foreground", "red", "orange", "yellow", "green",
    "cyan", "blue", "magenta", "purple", "brown", "bright_red", "bright_yellow",
    "bright_green", "bright_cyan", "bright_blue", "bright_magenta",
    "bright_purple", "hyprland_active_border", "hyprland_inactive_border",
}

print("colors.toml")
colors = tomllib.loads((theme / "colors.toml").read_text())
ok("parse tomllib")
unknown = sorted(set(colors) - KNOWN)
fail(f"key tidak dikenal: {unknown}") if unknown else ok("semua key dibaca Omarchy 4.5")
bad = [k for k, v in colors.items() if k != "mode" and not HEX.match(v)]
fail(f"hex tidak valid: {bad}") if bad else ok(f"{len(colors) - 1} nilai hex valid")

resolved = dict(
    line.split("\t", 1) for line in resolved_path.read_text().splitlines() if "\t" in line
)
expect_ansi = {
    "color0": "#101216", "color1": "#D08484", "color2": "#91AD95", "color3": "#C3AA7A",
    "color4": "#92AAC7", "color5": "#AE9FBD", "color6": "#8FAEB2", "color7": "#D7DCE2",
    "color8": "#929AA5", "color9": "#DDA0A0", "color10": "#A8C2AC", "color11": "#D4BD91",
    "color12": "#ACC0D9", "color13": "#C1B3CE", "color14": "#A6C4C8", "color15": "#EEF1F5",
    "cursor": "#EEF1F5", "selection_foreground": "#EEF1F5", "theme_type": "dark",
}
mism = {k: (resolved.get(k), v) for k, v in expect_ansi.items() if resolved.get(k, "").lower() != v.lower()}
fail(f"resolusi ANSI berbeda: {mism}") if mism else ok("resolusi ANSI/cursor/mode sesuai (color0 = background, aturan Omarchy)")

print("shell.*.toml")
for f in sorted(theme.glob("shell.*.toml")):
    try:
        data = tomllib.loads(f.read_text())
    except tomllib.TOMLDecodeError as e:
        fail(f"{f.name}: {e}")
        continue
    if any(isinstance(v, dict) for v in data.values()):
        fail(f"{f.name}: berisi tabel; override section harus key datar")
        continue
    badv = [k for k, v in data.items() if isinstance(v, str) and v.startswith("#") and not HEX.match(v)]
    fail(f"{f.name}: hex tidak valid {badv}") if badv else ok(f"{f.name} ({len(data)} key)")

print("vscode-theme.json")
vs_text = (theme / "vscode-theme.json").read_text()
vs = json.loads(vs_text)
ok("parse JSON")
fail("placeholder {{ }} tersisa") if "{{" in vs_text else ok("tidak ada placeholder tersisa")
c = vs["colors"]
for key, want in {
    "editor.background": "#101216", "sideBar.background": "#191C21",
    "editor.foreground": "#D7DCE2", "editor.selectionBackground": "#2A3038",
    "statusBar.background": "#0C0E11", "editorGutter.addedBackground": "#91AD95",
    "editorGutter.deletedBackground": "#D08484", "editorError.foreground": "#D08484",
    "editorWarning.foreground": "#C3AA7A", "terminal.background": "#101216",
}.items():
    got = c.get(key, "")
    fail(f"{key} = {got}, harap {want}") if got.lower() != want.lower() else ok(f"{key} = {want}")
comment = [t for t in vs.get("tokenColors", []) if "comment" in str(t.get("scope", ""))]
cfg = comment[0]["settings"].get("foreground", "") if comment else ""
fail(f"warna komentar {cfg}") if cfg.lower() != "#929aa5" else ok("komentar = muted #929AA5")
vs_hex = re.findall(r'"(#[0-9A-Fa-f]+)"', vs_text)
badhex = sorted({h for h in vs_hex if len(h) not in (4, 7, 9)})
fail(f"hex VS Code tidak valid: {badhex}") if badhex else ok(f"{len(vs_hex)} nilai warna VS Code valid")

print("Kontras WCAG 2.x (sRGB relative luminance)")


def lum(h):
    h = h.lstrip("#")
    out = []
    for i in (0, 2, 4):
        v = int(h[i:i + 2], 16) / 255
        out.append(v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def ratio(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


pairs = [
    ("foreground / background", "#D7DCE2", "#101216", 4.5),
    ("muted / background", "#929AA5", "#101216", 4.5),
    ("foreground / surface", "#D7DCE2", "#191C21", 4.5),
    ("muted / surface", "#929AA5", "#191C21", 4.5),
    ("foreground / surface_high (hover)", "#D7DCE2", "#20242B", 4.5),
    ("muted / surface_high (placeholder hover)", "#929AA5", "#20242B", 4.5),
    ("bright_fg / selection (teks terpilih)", "#EEF1F5", "#2A3038", 4.5),
    ("foreground / selection", "#D7DCE2", "#2A3038", 4.5),
    ("accent / background (fokus)", "#A9B4C2", "#101216", 3.0),
    ("accent / wallpaper_base (border aktif)", "#A9B4C2", "#08090B", 3.0),
    ("border / wallpaper_base (border tidak aktif, non-teks)", "#30353D", "#08090B", 1.0),
    ("foreground / bar (#101216)", "#D7DCE2", "#101216", 4.5),
    ("red / bar (urgent)", "#D08484", "#101216", 4.5),
    ("debug fg / debug bg", "#D4BD91", "#3A3226", 4.5),
    ("line number / background", "#6E7580", "#101216", 3.0),
    ("cursor bright_fg / background", "#EEF1F5", "#101216", 3.0),
]
for name in ("red", "orange", "yellow", "green", "cyan", "blue", "magenta"):
    pairs.append((f"{name} / background", colors[name], "#101216", 4.5))
    pairs.append((f"{name} / surface", colors[name], "#191C21", 4.5))
for label, fg, bg, target in pairs:
    r = ratio(fg, bg)
    (ok if r >= target else fail)(f"{label}: {r:.2f}:1 (target {target}:1)")

print("ANSI lazim (informasi, bukan klaim seluruh kombinasi)")
for label, fg, bg in [
    ("ANSI 0 (=background) di atas background", "#101216", "#101216"),
    ("ANSI 8 bright black / background", "#929AA5", "#101216"),
    ("ANSI 7 white / ANSI 4 blue (bg biru)", "#D7DCE2", "#92AAC7"),
    ("ANSI 0 / ANSI 7 (teks hitam di atas putih)", "#101216", "#D7DCE2"),
    ("ANSI 15 / ANSI 1 (statusline merah)", "#EEF1F5", "#D08484"),
]:
    print(f"  INFO   {label}: {ratio(fg, bg):.2f}:1")

print()
print("HASIL: " + ("LULUS" if failures == 0 else f"{failures} GAGAL"))
sys.exit(1 if failures else 0)
