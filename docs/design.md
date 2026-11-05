# Desain — Obsidian Veil (palet Stealth Black, Graphite & Silver)

## Hierarki lapisan

| Lapisan | Hex | Dipakai pada |
| --- | --- | --- |
| wallpaper_base / `darker_background` | `#08090B` | acuan wallpaper, `misc:background_color`, scrim menu |
| `dark_background` | `#0C0E11` | title bar, activity bar, status bar, tab tidak aktif (VS Code) |
| `background` | `#101216` | terminal, editor, panel terminal VS Code, bar Omarchy |
| `lighter_background` (surface) | `#191C21` | sidebar, popup, notifikasi, launcher/menu, tooltip, widget VS Code |
| surface_high | `#20242B` | hover (VS Code) |
| `selection` | `#2A3038` | seleksi teks/item, item terpilih menu/launcher |
| border | `#30353D` | border tidak aktif Hyprland, garis pemisah VS Code, tooltip/menu |
| `accent` | `#A9B4C2` | border aktif, fokus, indikator aktif |

Warna semantik (red/orange/yellow/green/cyan/blue/magenta + varian bright) mengikuti tabel `CLAUDE.md` tanpa perubahan.

## Pemetaan ke Omarchy 4.5

- `colors.toml` hanya berisi key kanonik yang dibaca `omarchy-theme-color`. Neutral ramp memakai kandidat spesifikasi apa adanya.
- **ANSI**: Omarchy memaksa `color0 = background` dan menurunkan slot lain dari nama kanonik. Mengikuti aturan spesifikasi ("ikuti format kanonik, jangan isi dua skema"), slot 0 menjadi `#101216`, **bukan** `#20242B` seperti tabel ANSI. Slot 1–15 identik dengan tabel. Konsekuensi: teks "hitam" eksplisit tidak terlihat di atas latar — memang tidak boleh diandalkan untuk teks penting.
- Template Omarchy dipakai untuk semua aplikasi lain (foot, tmux, btop, Neovim, Claude Code, Obsidian, Brave, GTK, fcitx5, lock screen) agar tetap ikut perbaikan Omarchy.

## File override tema

Warna border juga ada di `colors.toml` (`hyprland_active_border`, `hyprland_inactive_border`), sehingga tetap benar walaupun hook belum dipasang.


| File | Isi | Cakupan |
| --- | --- | --- |
| `extras/hyprland-extras.lua` (via hook) | border 1 px (aktif accent, tidak aktif border), rounding 5, warna groupbar, `background_color`, animasi 120–180 ms (speed 1.2–1.8 ds), terminal & Nautilus opacity 1.0 | Hanya saat tema aktif: hook `theme-set` menambahkannya ke `current/theme/hyprland.lua`, yang dibuat ulang saat ganti tema. Gaps (5/10 → jarak 10 px), layout, binding, monitor, input tidak disentuh. Blur/shadow tetap mati (default). Toggle Glassy tetap bisa menimpa. |
| `shell.bar.toml` | bar `#101216`, urgent red, tinggi 28 (default 26) | Section `[bar]` saja |
| `shell.popups/notifications.toml` | surface, border aktif 1 px | Section terkait |
| `shell.tooltip.toml` | surface, border `#30353D` | — |
| `shell.launcher/menu.toml` | surface solid (alpha 1.0), seleksi `#2A3038`, teks terpilih `#EEF1F5` | — |
| `vscode-theme.json` | dirender dari template VS Code Omarchy + override lapisan | Lihat di bawah |

Lock screen memakai section `[lock]` hasil template (input `#101216` alpha 0.8, border accent, error red); backend, timeout, dan autentikasi tidak diubah.

## VS Code

Template generik Omarchy memakai `background` untuk semua permukaan dan `muted` (di tema ini terang, `#929AA5`) sebagai isi solid pada beberapa tombol/hover. `scripts/build_vscode.py` merender template resmi lalu menimpa ±120 key: sidebar/widget/menu/quick input = surface, frame = `#0C0E11`, hover = `#20242B`, seleksi = `#2A3038`, active line `#171A1F` tanpa border, status bar tanpa blok terang (remote/prominent graphite; debugging tetap kuning redup `#3A3226`/`#D4BD91`), komentar `#929AA5` italic, Git gutter/diff, error/warning, find match, bracket match tetap semantik.

Tradeoff: file dikirim tema sehingga perubahan template VS Code Omarchy di masa depan tidak otomatis masuk; jalankan ulang `scripts/build.sh` + `install.sh` setelah upgrade Omarchy untuk mengambilnya.

## Font

Ditetapkan di bagian **Tipografi** `CLAUDE.md`, diimplementasikan oleh `scripts/typography.sh` dan `hl.env("OMARCHY_MENU_FONT", …)` di `extras/hyprland.lua`. Ringkasnya: VS Code memakai JetBrains Mono 14/22 tanpa ligature; terminal (foot dan VS Code) memakai JetBrainsMono Nerd Font (foot 11 pt); launcher/menu memakai IBM Plex Sans; bar, jam, dan notifikasi tetap memakai alias `monospace`/Liberation Sans karena keterbatasan shell. Detail dan validasi: `docs/typography.md`.

## Yang sengaja tidak diubah

Brightness/profil warna monitor, alias `monospace` sistem, layout tiling, binding, gaps, idle/lock/suspend, susunan bar dan modulnya, ikon GTK (default Omarchy `Yaru-blue` karena tema tidak mengirim `icons.theme`), ekstensi browser.
