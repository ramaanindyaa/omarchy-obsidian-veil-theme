# Audit perangkat — 5 November 2026

Ringkasan temuan sebelum perubahan. Tidak berisi rahasia atau dump konfigurasi penuh.

## Sistem

| Item | Temuan |
| --- | --- |
| Omarchy | `4.5.0-2` (`omarchy version`), CLI `omarchy <grup> <aksi>` di `/usr/share/omarchy/bin` |
| Kernel | `7.2.15-1-omarchy` |
| Sesi | Wayland aktif (`wayland-1`), Hyprland berjalan |
| Pengguna / XDG | `rama`; `XDG_CONFIG_HOME=~/.config`, `XDG_STATE_HOME=~/.local/state`, `XDG_DATA_HOME=~/.local/share` |
| Monitor | 1 monitor `eDP-1` 1920×1080 @ 60 Hz, scale 1.25 |
| Font | `JetBrainsMono Nerd Font` (`omarchy font current`), foot size 9 |

## Mekanisme tema (Omarchy 4.5)

- Tema bawaan: `/usr/share/omarchy/themes/` (milik paket, tidak diedit). Tema pengguna: `~/.config/omarchy/themes/<slug>/` (sebelumnya kosong).
- `omarchy-theme-set` menyalin tema bawaan (jika ada) lalu tema pengguna ke `~/.local/state/omarchy/current/next-theme`, merender `$OMARCHY_PATH/default/themed/*.tpl` **hanya untuk file yang tidak dikirim tema**, lalu menukarnya ke `current/theme`.
- Palet: `colors.toml` dengan nama kanonik (`accent`, `background`, `dark_background`, `darker_background`, `lighter_background`, `foreground`, `dark/light/bright_foreground`, `selection`, `muted`, warna dan `bright_*`). `omarchy-theme-color` menurunkan ANSI: **color0 = background**, color7 = foreground, color8 = muted, color15 = bright_foreground; `cursor` = bright_foreground. Key `colorN` tidak perlu diisi.
- Hyprland memakai **Lua** (`~/.config/hypr/hyprland.lua` → `default.hypr.omarchy` → `omarchy.current.theme.hyprland`). Tema boleh mengirim `hyprland.lua`; nilainya hilang saat ganti tema.
- Bar/notifikasi/launcher/OSD/lock: **Omarchy shell (Quickshell)**, bukan Waybar/Walker. Warna dari `shell.toml` (template) dan override per-section `shell.<section>.toml` dari tema.
- Wallpaper: `current/background` symlink; ekstensi yang dibaca: jpg/jpeg/png/gif/bmp/webp + video. **AVIF tidak dibaca.** Background terakhir per tema diingat di `~/.local/state/omarchy/theme-backgrounds/<tema>`.
- VS Code: `omarchy-theme-set-vscode` memasang `vscode-theme.json` sebagai ekstensi lokal `~/.vscode/extensions/omarchy-theme` (label "Omarchy") dan mengganti hanya `workbench.colorTheme` di `settings.json` (edit sed in-place, aman untuk JSONC). Tidak ada `vscode.json` → tidak ada instalasi Marketplace.
- Retint lain otomatis: foot, tmux, btop, opencode, GTK/ikon (gsettings), Claude Code (`~/.claude/themes/omarchy.json`), Brave (kebijakan warna terkelola, butuh otorisasi), Obsidian, fcitx5, keyboard RGB.

## Aplikasi terpasang yang relevan

foot (terminal default via `xdg-terminal-exec`), VS Code (`code`), Brave, Obsidian, Nautilus, btop, Neovim, tmux, lazygit, Claude Code, Codex, opencode. Tidak terpasang: alacritty, kitty, ghostty, VSCodium, Cursor, Helix, Chromium, Firefox, shellcheck.

## Baseline sebelum perubahan

| Item | Nilai |
| --- | --- |
| Tema aktif | `tokyo-night` |
| Background | `current/theme/backgrounds/2-quattro.webp` |
| VS Code colorTheme | `Tokyo Night` |
| GTK icon theme | `Yaru-magenta`, color-scheme `prefer-dark` |
| Hyprland | border 2, gaps_in 5, gaps_out 10, rounding 0, blur off, shadow off, dim off, opacity terminal 0.985/0.96 (default Omarchy) |
| `hyprctl configerrors` | kosong |
| Override pengguna | `~/.config/hypr/looknfeel.lua` seluruhnya komentar; `~/.config/omarchy/themed/` hanya berisi `.sample` (tidak ada template override aktif) |
| Symlink dotfiles | tidak ditemukan pada path yang disentuh |
