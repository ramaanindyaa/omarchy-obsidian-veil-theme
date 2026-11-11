# Render docs/images/palette.png from colors.toml.
# Usage: python3 -I scripts/build_palette.py colors.toml docs/images/palette.png
import subprocess, sys, tomllib
c = tomllib.load(open(sys.argv[1], 'rb'))
rows = [
  ("Neutrals", [("darker_bg", c["darker_background"]), ("dark_bg", c["dark_background"]), ("background", c["background"]),
                ("surface", c["lighter_background"]), ("selection", c["selection"]), ("border", c["hyprland_inactive_border"]),
                ("muted", c["muted"]), ("accent", c["accent"]), ("foreground", c["foreground"]), ("bright_fg", c["bright_foreground"])]),
  ("Colors", [(n, c[n]) for n in ["red","orange","yellow","green","cyan","blue","magenta"]]),
  ("Bright", [(n.replace("bright_","")+" +", c[n]) for n in ["bright_red","bright_yellow","bright_green","bright_cyan","bright_blue","bright_magenta"]]),
]
W, pad, sw, sh, gap = 1600, 56, 136, 96, 14
H = pad + 64 + sum(28 + sh + 62 for _ in rows) + pad - 20
sans = "/usr/share/fonts/TTF/IBMPlexSans-Medium.ttf"; sansr = "/usr/share/fonts/TTF/IBMPlexSans-Regular.ttf"
mono = "/usr/share/fonts/TTF/JetBrainsMono-Regular.ttf"
cmd = ["magick", "-size", f"{W}x{H}", "xc:#08090B",
       "-font", sans, "-pointsize", "30", "-fill", "#EEF1F5", "-annotate", f"+{pad}+{pad+26}", "Obsidian Veil",
       "-font", sansr, "-pointsize", "20", "-fill", "#929AA5", "-annotate", f"+{pad+200}+{pad+26}", "Stealth Black — Graphite & Silver"]
y = pad + 64
for title, sw_list in rows:
    cmd += ["-font", sans, "-pointsize", "17", "-fill", "#929AA5", "-annotate", f"+{pad}+{y+16}", title.upper()]
    y += 28
    for i, (name, hexv) in enumerate(sw_list):
        x = pad + i * (sw + gap)
        cmd += ["-fill", hexv, "-stroke", "#30353D", "-strokewidth", "1", "-draw", f"roundrectangle {x},{y} {x+sw},{y+sh} 6,6", "-stroke", "none",
                "-font", sansr, "-pointsize", "17", "-fill", "#D7DCE2", "-annotate", f"+{x}+{y+sh+24}", name,
                "-font", mono, "-pointsize", "15", "-fill", "#929AA5", "-annotate", f"+{x}+{y+sh+46}", hexv.upper()]
    y += sh + 62
cmd += ["-strip", sys.argv[2]]
subprocess.run(cmd, check=True)
