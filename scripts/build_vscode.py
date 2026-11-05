#!/usr/bin/env python3
"""Render Omarchy's stock vscode-theme.json.tpl with the Stealth Black palette,
then apply targeted overrides for layer hierarchy (surface sidebar/popups,
graphite hover/selection) that the generic template cannot express.

Usage: build_vscode.py <template.tpl> <resolved-colors.tsv> <output.json>
The TSV is the output of `omarchy-theme-color --file colors.toml --all`.
"""

import json
import re
import sys

tpl_path, colors_path, out_path = sys.argv[1:4]

colors = {}
with open(colors_path, encoding="utf-8") as fh:
    for line in fh:
        key, _, value = line.rstrip("\n").partition("\t")
        if key:
            colors[key] = value


def mix(a: str, b: str, amount: float) -> str:
    a, b = a.lstrip("#"), b.lstrip("#")
    out = []
    for i in (0, 2, 4):
        x, y = int(a[i:i + 2], 16), int(b[i:i + 2], 16)
        out.append(int(x * (1 - amount) + y * amount + 0.5))
    return "#%02x%02x%02x" % tuple(out)


def render(match: re.Match) -> str:
    parts = match.group(1).split()
    if parts[0] in ("mix", "mix_strip", "mix_rgb") and len(parts) == 4:
        amt = parts[3]
        amount = float(amt.rstrip("%")) / 100 if amt.endswith("%") else float(amt)
        value = mix(colors[parts[1]], colors[parts[2]], amount)
        if parts[0] == "mix_strip":
            return value[1:]
        if parts[0] == "mix_rgb":
            v = value[1:]
            return ",".join(str(int(v[i:i + 2], 16)) for i in (0, 2, 4))
        return value
    token = parts[0]
    if len(parts) == 1:
        if token in colors:
            return colors[token]
        if token.endswith("_strip") and token[:-6] in colors:
            return colors[token[:-6]].lstrip("#")
        if token.endswith("_rgb") and token[:-4] in colors:
            v = colors[token[:-4]].lstrip("#")
            return ",".join(str(int(v[i:i + 2], 16)) for i in (0, 2, 4))
    raise SystemExit(f"unresolved template token: {match.group(0)}")


with open(tpl_path, encoding="utf-8") as fh:
    rendered = re.sub(r"\{\{\s*([^}]+?)\s*\}\}", render, fh.read())

theme = json.loads(rendered)

BG = "#101216"          # background: editor, terminal
FRAME = "#0C0E11"       # dark_background: title/status/activity bars
SURFACE = "#191C21"     # surface: sidebar, popups, widgets
SURFACE_HIGH = "#20242B"
SELECTION = "#2A3038"
BORDER = "#30353D"
ACCENT = "#A9B4C2"
FG = "#D7DCE2"
MUTED = "#929AA5"
BRIGHT = "#EEF1F5"

theme["name"] = "Omarchy"  # Omarchy's generated extension label; keep it.

overrides = {
    # Layers
    "titleBar.activeBackground": FRAME,
    "titleBar.inactiveBackground": FRAME,
    "titleBar.border": BORDER,
    "activityBar.background": FRAME,
    "activityBar.border": BORDER,
    "activityBar.activeBackground": SURFACE_HIGH,
    "sideBar.background": SURFACE,
    "sideBar.border": BORDER,
    "sideBarSectionHeader.background": SURFACE,
    "sideBarSectionHeader.border": BORDER,
    "sideBarStickyScroll.background": SURFACE,
    "editorGroupHeader.tabsBackground": FRAME,
    "editorGroupHeader.noTabsBackground": BG,
    "editorGroupHeader.tabsBorder": BORDER,
    "editorGroup.border": BORDER,
    "tab.inactiveBackground": FRAME,
    "tab.border": FRAME,
    "tab.activeBackground": BG,
    "tab.unfocusedActiveBackground": BG,
    "tab.hoverBackground": SURFACE_HIGH,
    "tab.unfocusedHoverBackground": SURFACE_HIGH,
    "panel.background": BG,
    "panel.border": BORDER,
    "statusBar.background": FRAME,
    "statusBar.border": BORDER,
    "statusBar.noFolderBackground": FRAME,
    "statusBar.noFolderBorder": BORDER,
    "breadcrumb.background": BG,
    "breadcrumbPicker.background": SURFACE,
    # Floating surfaces
    "editorWidget.background": SURFACE,
    "editorWidget.border": BORDER,
    "editorSuggestWidget.background": SURFACE,
    "editorSuggestWidget.border": BORDER,
    "editorSuggestWidget.selectedBackground": SELECTION,
    "editorHoverWidget.background": SURFACE,
    "editorHoverWidget.border": BORDER,
    "editorHoverWidget.statusBarBackground": SURFACE_HIGH,
    "quickInput.background": SURFACE,
    "quickInputTitle.background": SURFACE_HIGH,
    "quickInputList.focusBackground": SELECTION,
    "menu.background": SURFACE,
    "menu.border": BORDER,
    "menu.separatorBackground": BORDER,
    "menu.selectionBackground": SELECTION,
    "menubar.selectionBackground": SELECTION,
    "notifications.background": SURFACE,
    "notifications.border": BORDER,
    "notificationCenter.border": BORDER,
    "notificationCenterHeader.background": SURFACE_HIGH,
    "notificationToast.border": BORDER,
    "dropdown.background": SURFACE,
    "dropdown.listBackground": SURFACE,
    "dropdown.border": BORDER,
    "input.background": BG,
    "input.border": BORDER,
    "peekViewResult.background": SURFACE,
    "peekViewTitle.background": SURFACE_HIGH,
    "debugToolBar.background": SURFACE,
    "debugToolBar.border": BORDER,
    "widget.shadow": "#00000066",
    "commandCenter.background": SURFACE,
    "commandCenter.border": BORDER,
    "commandCenter.inactiveBorder": BORDER,
    "commandCenter.activeBackground": SURFACE_HIGH,
    # Hover / selection on graphite steps instead of light `muted` fills
    "list.hoverBackground": SURFACE_HIGH,
    "list.activeSelectionBackground": SELECTION,
    "list.inactiveSelectionBackground": SURFACE_HIGH,
    "list.focusBackground": SELECTION,
    "list.inactiveFocusBackground": SURFACE_HIGH,
    "list.inactiveFocusOutline": BORDER,
    "toolbar.hoverBackground": SURFACE_HIGH,
    "toolbar.activeBackground": SELECTION,
    "inputOption.hoverBackground": SURFACE_HIGH,
    "button.secondaryBackground": SELECTION,
    "button.secondaryHoverBackground": BORDER,
    "extensionButton.background": SELECTION,
    "extensionButton.hoverBackground": BORDER,
    "button.hoverBackground": BRIGHT,
    "statusBarItem.activeBackground": SELECTION,
    "statusBarItem.hoverBackground": SURFACE_HIGH,
    "statusBarItem.compactHoverBackground": SURFACE_HIGH,
    # No bright blocks in the status bar; debugging stays distinct.
    "statusBarItem.remoteBackground": SELECTION,
    "statusBarItem.remoteForeground": BRIGHT,
    "statusBarItem.remoteHoverBackground": BORDER,
    "statusBarItem.remoteHoverForeground": BRIGHT,
    "statusBarItem.prominentBackground": SELECTION,
    "statusBarItem.prominentForeground": BRIGHT,
    "statusBarItem.prominentHoverBackground": BORDER,
    "statusBarItem.prominentHoverForeground": BRIGHT,
    "statusBar.debuggingBackground": "#3A3226",
    "statusBar.debuggingForeground": "#D4BD91",
    "statusBar.debuggingBorder": "#C3AA7A",
    "commandCenter.debuggingBackground": "#3A3226",
    # Editor: calm active line, palette selection, silver focus
    "focusBorder": ACCENT + "99",
    "editor.lineHighlightBackground": "#171A1F",
    "editor.lineHighlightBorder": "#00000000",
    "editor.selectionBackground": SELECTION,
    "editor.inactiveSelectionBackground": SELECTION + "99",
    "editor.selectionHighlightBackground": ACCENT + "1F",
    "editor.selectionHighlightBorder": ACCENT + "40",
    "terminal.selectionBackground": SELECTION,
    "terminal.inactiveSelectionBackground": SELECTION + "99",
    "terminal.border": BORDER,
    "editorIndentGuide.background1": BORDER,
    "editorIndentGuide.activeBackground1": "#4A515C",
    "editorRuler.foreground": BORDER,
    "editorLineNumber.foreground": "#6E7580",
    "editorLineNumber.activeForeground": FG,
    "editorWhitespace.foreground": "#3A404A",
    "editorOverviewRuler.border": BORDER,
    "scrollbarSlider.background": MUTED + "26",
    "scrollbarSlider.hoverBackground": MUTED + "40",
    "scrollbarSlider.activeBackground": ACCENT + "66",
    "keybindingLabel.background": SURFACE_HIGH,
    "keybindingLabel.border": BORDER,
    "keybindingLabel.bottomBorder": BORDER,
    "welcomePage.tileBackground": SURFACE,
    "welcomePage.tileHoverBackground": SURFACE_HIGH,
    "welcomePage.tileBorder": BORDER,
    "pickerGroup.border": BORDER,
    "checkbox.border": BORDER,
    "panelInput.border": BORDER,
    "panelSection.border": BORDER,
    "panelSectionHeader.border": BORDER,
    "panelSectionHeader.background": SURFACE,
}

unknown = [k for k in overrides if k not in theme["colors"]]
theme["colors"].update(overrides)

with open(out_path, "w", encoding="utf-8") as fh:
    json.dump(theme, fh, indent=4, ensure_ascii=False)
    fh.write("\n")

if unknown:
    print("added keys not in stock template: " + ", ".join(sorted(unknown)), file=sys.stderr)
