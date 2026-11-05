#!/usr/bin/env bash
# Obsidian Veil typography: minimal, reversible edits to user configs.
#   VS Code   ~/.config/Code/User/settings.json   (only the keys below; JSONC kept)
#   foot      ~/.config/foot/foot.ini             (only the `font=` line)
# The menu/launcher font (OMARCHY_MENU_FONT) lives in extras/hyprland-extras.lua.
#
# Usage: typography.sh [--dry-run]            apply
#        typography.sh --rollback [--dry-run] undo only what this script changed

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_common_flags "$@"
MODE=apply
for a in "$@"; do [[ $a == --rollback ]] && MODE=rollback; done

FOOT_INI="$HOME/.config/foot/foot.ini"
TYPO_STATE="$SB_STATE_DIR/typography"
TYPO_BACKUP_LINK="$TYPO_STATE/pre-typography"

FOOT_FONT_LINE='font=JetBrainsMono Nerd Font:size=11'

# key<TAB>JSON value. Order is the order inserted.
VSCODE_KEYS=(
  $'editor.fontFamily\t"\'JetBrains Mono\', \'JetBrainsMono Nerd Font\', monospace"'
  $'editor.fontSize\t14'
  $'editor.lineHeight\t22'
  $'editor.fontWeight\t"400"'
  $'editor.fontLigatures\tfalse'
  $'terminal.integrated.fontFamily\t"\'JetBrainsMono Nerd Font\'"'
  $'terminal.integrated.fontSize\t14'
)

# awk always ends output with a newline; keep the original file's last byte.
keep_eof() { [[ -n $(tail -c1 -- "$1") ]] && truncate -s -1 -- "$2"; return 0; }

vscode_line() { printf '    "%s": %s,' "$1" "$2"; }

require_fonts() {
  local fam got
  for fam in "JetBrains Mono" "JetBrainsMono Nerd Font" "IBM Plex Sans"; do
    got="$(fc-match -f '%{family[0]}' "$fam")"
    [[ $got == "$fam" ]] || die "Font '$fam' tidak terpasang (fc-match: $got)."
  done
}

apply() {
  require_fonts
  [[ -f $VSCODE_SETTINGS ]] || die "$VSCODE_SETTINGS tidak ada."
  [[ -f $FOOT_INI ]] || die "$FOOT_INI tidak ada."
  [[ ! -L $VSCODE_SETTINGS && ! -L $FOOT_INI ]] || die "Salah satu target adalah symlink; tidak menulis menembus symlink."

  # Backup once; repeated runs reuse it so backups do not multiply.
  if [[ ! -e $TYPO_BACKUP_LINK ]]; then
    local dir="$SB_BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-typography" kv key
    log "Backup -> $dir"
    if (( ! DRY_RUN )); then
      ( umask 077; mkdir -p "$dir" "$TYPO_STATE" )
      cp -a -- "$VSCODE_SETTINGS" "$dir/vscode-settings.json"
      cp -a -- "$FOOT_INI" "$dir/foot.ini"
      {
        printf 'file\t%s\t%s\n' "$VSCODE_SETTINGS" "$(sha_of "$VSCODE_SETTINGS")"
        printf 'file\t%s\t%s\n' "$FOOT_INI" "$(sha_of "$FOOT_INI")"
      } >"$dir/files.manifest"
      # Original state of each touched key / line, for a surgical rollback.
      : >"$dir/vscode-keys.orig"
      for kv in "${VSCODE_KEYS[@]}"; do
        key="${kv%%$'\t'*}"
        if grep -qF "\"$key\"" "$VSCODE_SETTINGS"; then
          printf '%s\t%s\n' "$key" "$(grep -F "\"$key\"" "$VSCODE_SETTINGS" | head -1)" >>"$dir/vscode-keys.orig"
        else
          printf '%s\t<absent>\n' "$key" >>"$dir/vscode-keys.orig"
        fi
      done
      grep -m1 '^font=' "$FOOT_INI" >"$dir/foot-font.orig" || : >"$dir/foot-font.orig"
      ln -sfn -- "../backups/${dir##*/}" "$TYPO_BACKUP_LINK"
    fi
  fi

  # VS Code: replace existing key lines in place, insert missing ones after
  # the first "{". No JSON round-trip, so comments and formatting survive.
  local tmp kv key val line insert=()
  for kv in "${VSCODE_KEYS[@]}"; do
    key="${kv%%$'\t'*}"; val="${kv#*$'\t'}"
    line="$(vscode_line "$key" "$val")"
    if grep -qF "\"$key\"" "$VSCODE_SETTINGS"; then
      if grep -qxF "$line" "$VSCODE_SETTINGS"; then continue; fi
      if (( DRY_RUN )); then echo "   [dry-run] VS Code ganti $key -> $val"; continue; fi
      tmp="$(mktemp "$(dirname "$VSCODE_SETTINGS")/.settings.XXXXXX")"
      awk -v k="\"$key\"" -v l="$line" 'index($0, k) && !done { sub(/,?[[:space:]]*$/, "", l); print (match($0, /,[[:space:]]*$/) ? l "," : l); done=1; next } { print }' "$VSCODE_SETTINGS" >"$tmp"
      keep_eof "$VSCODE_SETTINGS" "$tmp"; chmod --reference="$VSCODE_SETTINGS" "$tmp"; mv -f -- "$tmp" "$VSCODE_SETTINGS"
    else
      insert+=("$line")
    fi
  done
  if (( ${#insert[@]} )); then
    if (( DRY_RUN )); then
      printf '   [dry-run] VS Code tambah: %s\n' "${insert[@]}"
    else
      tmp="$(mktemp "$(dirname "$VSCODE_SETTINGS")/.settings.XXXXXX")"
      awk -v block="$(printf '%s\n' "${insert[@]}")" '!done && /\{/ { print; print block; done=1; next } { print }' "$VSCODE_SETTINGS" >"$tmp"
      keep_eof "$VSCODE_SETTINGS" "$tmp"; chmod --reference="$VSCODE_SETTINGS" "$tmp"; mv -f -- "$tmp" "$VSCODE_SETTINGS"
    fi
  fi
  log "VS Code: $VSCODE_SETTINGS"

  # foot: only the font line. Running windows keep their font; new ones use it.
  if grep -qxF "$FOOT_FONT_LINE" "$FOOT_INI"; then
    log "foot: font sudah sesuai"
  elif (( DRY_RUN )); then
    echo "   [dry-run] foot: $(grep -m1 '^font=' "$FOOT_INI") -> $FOOT_FONT_LINE"
  else
    tmp="$(mktemp "$(dirname "$FOOT_INI")/.foot.XXXXXX")"
    awk -v l="$FOOT_FONT_LINE" '/^font=/ && !done { print l; done=1; next } { print }' "$FOOT_INI" >"$tmp"
    keep_eof "$FOOT_INI" "$tmp"; chmod --reference="$FOOT_INI" "$tmp"; mv -f -- "$tmp" "$FOOT_INI"
    log "foot: $FOOT_FONT_LINE"
  fi
  if (( ! DRY_RUN )); then
    foot --check-config >/dev/null 2>&1 || foot --check-config
  fi
}

rollback() {
  [[ -e $TYPO_BACKUP_LINK ]] || die "Tidak ada backup tipografi."
  local dir; dir="$(readlink -f "$TYPO_BACKUP_LINK")"
  log "Backup: $dir"
  local kv key val line orig tmp
  for kv in "${VSCODE_KEYS[@]}"; do
    key="${kv%%$'\t'*}"; val="${kv#*$'\t'}"
    line="$(vscode_line "$key" "$val")"
    orig="$(awk -F'\t' -v k="$key" '$1==k { sub(/^[^\t]*\t/, ""); print; exit }' "$dir/vscode-keys.orig")"
    if ! grep -qxF "$line" "$VSCODE_SETTINGS"; then
      warn "VS Code $key sudah diubah setelah apply; dibiarkan."
      continue
    fi
    if (( DRY_RUN )); then echo "   [dry-run] VS Code $key -> ${orig}"; continue; fi
    tmp="$(mktemp "$(dirname "$VSCODE_SETTINGS")/.settings.XXXXXX")"
    if [[ $orig == "<absent>" ]]; then
      awk -v l="$line" '$0 == l && !done { done=1; next } { print }' "$VSCODE_SETTINGS" >"$tmp"
    else
      awk -v l="$line" -v o="$orig" '$0 == l && !done { print o; done=1; next } { print }' "$VSCODE_SETTINGS" >"$tmp"
    fi
    keep_eof "$VSCODE_SETTINGS" "$tmp"; chmod --reference="$VSCODE_SETTINGS" "$tmp"; mv -f -- "$tmp" "$VSCODE_SETTINGS"
  done
  if (( ! DRY_RUN )) && cmp -s "$dir/vscode-settings.json" "$VSCODE_SETTINGS"; then
    log "VS Code settings.json kembali identik dengan backup."
  fi

  orig="$(cat "$dir/foot-font.orig")"
  if grep -qxF "$FOOT_FONT_LINE" "$FOOT_INI" && [[ -n $orig ]]; then
    if (( DRY_RUN )); then
      echo "   [dry-run] foot: -> $orig"
    else
      tmp="$(mktemp "$(dirname "$FOOT_INI")/.foot.XXXXXX")"
      awk -v l="$FOOT_FONT_LINE" -v o="$orig" '$0 == l && !done { print o; done=1; next } { print }' "$FOOT_INI" >"$tmp"
      keep_eof "$FOOT_INI" "$tmp"; chmod --reference="$FOOT_INI" "$tmp"; mv -f -- "$tmp" "$FOOT_INI"
      log "foot: $orig"
    fi
  else
    warn "Baris font foot sudah diubah setelah apply; dibiarkan."
  fi
  log "Font menu/launcher ikut hook tema (extras/hyprland-extras.lua); dilepas oleh rollback.sh."
  log "Paket font (ttf-jetbrains-mono, ttf-ibm-plex) tidak dihapus otomatis."
}

if [[ $MODE == rollback ]]; then rollback; else apply; fi
