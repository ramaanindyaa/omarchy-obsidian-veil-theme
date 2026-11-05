# shellcheck shell=bash
# Shared helpers for Obsidian Veil scripts. Source, don't execute.

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
THEME_SLUG="obsidian-veil"
# The repository root is the Omarchy theme (what `omarchy theme install` clones).
THEME_SRC="$PROJECT_DIR"
DEFAULT_REPO_URL="https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme.git"

SB_STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}"
SB_CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"

# omarchy-theme-set hard-codes these under $HOME (Omarchy 4.5.0); mirror it.
OMARCHY_USER_THEMES="$HOME/.config/omarchy/themes"
OMARCHY_CURRENT="$HOME/.local/state/omarchy/current"
OMARCHY_HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
THEME_TARGET="$OMARCHY_USER_THEMES/$THEME_SLUG"
USER_BACKGROUNDS="$HOME/.config/omarchy/backgrounds/$THEME_SLUG"
HOOK_NAME="50-obsidian-veil-extras"
HOOK_TARGET="$OMARCHY_HOOK_DIR/$HOOK_NAME"

SB_STATE_DIR="$SB_STATE_ROOT/obsidian-veil"
SB_BACKUP_ROOT="$SB_STATE_DIR/backups"
SB_FIRST_BACKUP_LINK="$SB_STATE_DIR/pre-install"
SB_WALLPAPER_CACHE="$SB_CACHE_ROOT/obsidian-veil/wallpapers"

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

current_theme_name() {
  cat "$OMARCHY_CURRENT/theme.name" 2>/dev/null || true
}

current_background() {
  readlink "$OMARCHY_CURRENT/background" 2>/dev/null || true
}

# Is $1 an unmodified git clone of this theme (safe for us to remove)?
clean_theme_clone() {
  local dir="$1"
  [[ -d $dir/.git && ! -L $dir ]] || return 1
  [[ -z $(git -C "$dir" status --porcelain --untracked-files=all 2>/dev/null) ]] || return 1
  git -C "$dir" ls-files --error-unmatch colors.toml extras/theme-set-hook.sh >/dev/null 2>&1
}
