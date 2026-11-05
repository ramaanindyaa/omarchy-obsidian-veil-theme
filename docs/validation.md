# Validasi — 5 November 2026 (Omarchy 4.5.0-2)

Status: **LULUS** = diperiksa dan sesuai · **GAGAL** · **BELUM DIUJI** (dengan alasan).

## Statis (`scripts/validate.sh --installed`)

| Pemeriksaan | Status | Catatan |
| --- | --- | --- |
| `colors.toml` diparse `tomllib` | LULUS | 24 nilai hex valid, semua key dikenal `omarchy-theme-color` |
| Resolusi ANSI/cursor/mode | LULUS | color0 = `#101216` (aturan Omarchy), color1–15 = tabel spesifikasi, cursor `#EEF1F5`, mode dark |
| `shell.*.toml` (6 file) diparse | LULUS | key datar, hex valid |
| `vscode-theme.json` JSON valid, tanpa placeholder | LULUS | 786 nilai warna; key penting dicek (editor/sidebar/status/selection/gutter/error/warning/terminal/komentar) |
| `hyprland.lua` | LULUS | `luac -p` + `hyprctl configerrors` kosong setelah apply |
| `bash -n` semua skrip | LULUS | ShellCheck tidak terpasang → BELUM DIUJI (tidak dipasang otomatis) |
| Wallpaper dapat didekode | LULUS | 4× 3840×2160 JPEG, 1× 1400×933 PNG |
| Salinan terpasang = proyek | LULUS | `diff -rq` |
| Diff fungsional | LULUS | Satu-satunya perubahan di luar tema/state Omarchy: `settings.json` VS Code baris `workbench.colorTheme` (`Tokyo Night` → `Omarchy`), oleh mekanisme Omarchy |

### Kontras WCAG (dihitung, bukan disalin)

| Pasangan | Rasio |
| --- | --- |
| foreground / background | 13.59:1 |
| muted / background | 6.60:1 |
| foreground / surface | 12.38:1 |
| muted / surface | 6.01:1 |
| foreground / hover `#20242B` | 11.29:1 |
| muted (placeholder) / hover | 5.48:1 |
| bright_fg / selection (teks terpilih) | 11.74:1 |
| foreground / selection | 9.65:1 |
| accent / background (fokus) | 8.92:1 |
| accent / wallpaper_base (border aktif) | 9.48:1 |
| red (urgent) / bar | 6.53:1 |
| debug fg / debug bg (status bar VS Code) | 6.90:1 |
| nomor baris `#6E7580` / background | ≥3:1 (informasi sekunder) |
| semua warna semantik / background dan / surface | 5.95–8.35:1 |

ANSI (informasi saja — tidak diklaim semua kombinasi lolos): ANSI 0 di atas background 1.00:1 (tak terlihat), putih di atas blue 1.73:1, bright white di atas red 2.53:1. Kombinasi teks-di-atas-latar-berwarna seperti ini rendah pada palet pastel; bergantung pada aplikasi.

## Sesi desktop

| Pemeriksaan | Status | Catatan |
| --- | --- | --- |
| `omarchy theme set stealth-black` | LULUS | `OMARCHY_THEME_WAIT=1`; `theme-set.log` kosong (tidak ada retint gagal) |
| Error baru vs baseline | LULUS | `hyprctl configerrors` kosong sebelum & sesudah |
| Nilai Hyprland live | LULUS | border 1, active `ffa9b4c2`, inactive `ff30353d`, rounding 5, gaps 5/10 tidak berubah, blur off, animasi windows 1.8 ds |
| Opacity foot | LULUS | `hyprctl getprop … opacity` = 1 (aktif & tidak aktif) |
| Screenshot desktop (eDP-1, scale 1.25) | LULUS | border silver 1 px terlihat, sudut membulat, bar 28 px utuh tanpa teks terpotong, workspace aktif ditandai, wallpaper cover tanpa stretch. Screenshot hanya di scratchpad sesi, tidak disimpan di proyek |
| Notifikasi | LULUS | Notifikasi uji: surface `#191C21`, border silver tipis, teks terbaca |
| foot (terminal aktif) | LULUS | Warna dari `foot.ini` tema; Claude Code berjalan dan terbaca |
| VS Code ekstensi tema | LULUS (statis) | `~/.vscode/extensions/omarchy-theme/themes/omarchy-color-theme.json` identik dengan `theme/vscode-theme.json`; `colorTheme` = `Omarchy` |
| VS Code visual (editor, sidebar, diff, squiggle, terminal terintegrasi) | BELUM DIUJI | VS Code tidak sedang terbuka; tidak dibuka agar tidak mengganggu pekerjaan. Buka VS Code dan periksa |
| Brave chrome | LULUS (statis) | Kebijakan `BrowserThemeColor #101216` tertulis oleh Omarchy. Konten situs tidak ikut tema |
| GTK/Nautilus | LULUS (statis) | `prefer-dark`, ikon `Yaru-blue` (default Omarchy tanpa `icons.theme`). Visual Nautilus BELUM DIUJI |
| Launcher/menu, OSD, tooltip | BELUM DIUJI visual | Override section terpasang di `shell.toml` aktif; buka `Super+Space`/menu untuk memeriksa |
| Lock screen | BELUM DIUJI | Tidak mengunci sesi saat pengguna bekerja; periksa manual saat lock berikutnya |
| btop, Neovim, tmux, lazygit, Obsidian | BELUM DIUJI visual | Dihasilkan template Omarchy dari palet |
| Wallpaper per monitor | LULUS | Hanya 1 monitor |
| Tema lain tetap bisa dipilih | LULUS | `omarchy theme list` memuat semua tema bawaan + "Stealth Black"; override Hyprland bersifat per-tema |
| Install ulang tanpa perubahan | LULUS | "sudah identik; tidak ada perubahan", tidak ada backup baru |
| Rollback | LULUS (dry-run) | `rollback.sh --dry-run` merencanakan `omarchy theme set tokyo-night`, verifikasi background `2-quattro.webp`, hapus direktori tema bila hash cocok. **End-to-end belum dijalankan** agar tema tetap aktif |

## Tipografi

Lihat `docs/typography.md`. Ringkasan: font terdaftar dan ter-resolve ke varian yang tepat (LULUS); shell memuat IBM Plex Sans Regular/Medium untuk menu (LULUS); glyph Nerd Font tersedia (LULUS); rollback tipografi diuji end-to-end hingga identik byte-per-byte (LULUS); visual VS Code dan jendela foot baru BELUM DIUJI.

Tidak ada klaim performa atau baterai.
