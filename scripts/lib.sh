# shellcheck shell=bash
# Shared helpers for Stealth Black scripts. Source, don't execute.

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
THEME_SLUG="stealth-black"
THEME_SRC="$PROJECT_DIR/theme"

SB_CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
SB_STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}"

# omarchy-theme-set hard-codes these under $HOME (Omarchy 4.5.0); mirror it.
OMARCHY_USER_THEMES="$HOME/.config/omarchy/themes"
OMARCHY_CURRENT="$HOME/.local/state/omarchy/current"
THEME_TARGET="$OMARCHY_USER_THEMES/$THEME_SLUG"

SB_STATE_DIR="$SB_STATE_ROOT/stealth-black"
SB_BACKUP_ROOT="$SB_STATE_DIR/backups"
SB_INSTALL_MANIFEST="$SB_STATE_DIR/installed.manifest"
SB_FIRST_BACKUP_LINK="$SB_STATE_DIR/pre-install"

VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"

DRY_RUN=0

log()  { printf '\033[1;37m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# Run a mutating command, or print it under --dry-run.
run() {
  if (( DRY_RUN )); then
    printf '   [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

parse_common_flags() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=1 ;;
    esac
  done
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "Perintah '$1' tidak ditemukan."
}

sha_of() {
  sha256sum -- "$1" | cut -d' ' -f1
}

# Hash every regular file of a directory tree as "<sha>  <relative path>".
tree_manifest() {
  local dir="$1"
  ( cd "$dir" && find . -type f ! -name '.stealth-black-owned' -print0 | sort -z | xargs -0 -r sha256sum )
}

current_theme_name() {
  cat "$OMARCHY_CURRENT/theme.name" 2>/dev/null || true
}

current_background() {
  readlink "$OMARCHY_CURRENT/background" 2>/dev/null || true
}
