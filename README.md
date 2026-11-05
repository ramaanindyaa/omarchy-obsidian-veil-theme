# Stealth Black — Graphite & Silver

Tema Omarchy pribadi (`stealth-black`): desktop hitam matte berlapis dengan aksen graphite–silver untuk coding di VS Code, foot, Claude Code, dan Codex. Dibuat dan diuji untuk **Omarchy 4.5.0-2** (Hyprland Lua + Omarchy shell). Spesifikasi: `CLAUDE.md`.

## Struktur

```text
Backgrounds/              (tidak di-commit) wallpaper asli lokal + source/ hasil unduhan
theme/                    isi tema yang dipasang
  colors.toml             palet kanonik Omarchy
  hyprland.lua            border, rounding, animasi, opacity terminal (hanya saat tema aktif)
  shell.*.toml            override section bar/popup/notifikasi/tooltip/launcher/menu
  vscode-theme.json       dihasilkan build.sh
  backgrounds/            turunan wallpaper (dihasilkan build.sh; di repo hanya Black Ribbons & Black Dune)
  unlock.png              logo layar unlock Plymouth (LUKS/boot), dibuat build_unlock.sh
  preview-unlock.png      render nyata dari `omarchy plymouth preview`
scripts/                  build, install, apply, rollback, validate, fetch-wallpaper, typography
docs/                     device-audit, design, wallpaper-sources, validation, typography
```

## Dari GitHub (clone baru)

```bash
git clone https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme.git ~/obsidian-veil
cd ~/obsidian-veil
scripts/fetch-wallpaper.sh --all   # Pilulae, Discus, Cubus (Resend) tidak ada di repo
scripts/build.sh && scripts/validate.sh
scripts/install.sh && scripts/apply.sh
```

Repo ini tidak bisa dipasang dengan `omarchy theme install`. Tema berada di subfolder `theme/`, dan Omarchy membuang `*.lua` dari tema hasil clone git, sehingga dekorasi Hyprland dan font menu akan hilang. Pakai `scripts/install.sh`.

## Pemakaian

```bash
cd ~/obsidian-veil
scripts/fetch-wallpaper.sh     # opsional: Black Ribbons 3840px (sudah diunduh)
scripts/build.sh               # wallpaper turunan + vscode-theme.json
scripts/validate.sh            # validasi statis
scripts/install.sh             # backup pre-install + pasang ke ~/.config/omarchy/themes/stealth-black
scripts/apply.sh               # omarchy theme set stealth-black + cek error
scripts/validate.sh --installed
```

Semua skrip yang mengubah sesuatu menerima `--dry-run`. Setelah tema terpasang, tema juga bisa dipilih dari Theme switcher Omarchy sebagai **Stealth Black** (Omarchy menurunkan nama tampilan dari slug; nama "Graphite & Silver" hanya di dokumentasi).

Saat apply, langkah browser Omarchy dapat meminta otorisasi untuk menulis kebijakan warna Brave — sama seperti mengganti tema dari menu. Membatalkannya tidak menggagalkan tema.

### Mengubah tema

Edit `theme/`, lalu `scripts/build.sh && scripts/install.sh && scripts/apply.sh`. Install mendeteksi edit langsung pada salinan terpasang dan membackupnya sebelum menimpa. Setelah upgrade Omarchy, jalankan ulang ketiga perintah agar `vscode-theme.json` dirender dari template terbaru.

### Mengganti wallpaper

- Siklus: `omarchy theme bg next`, atau pilih lewat `omarchy theme bg-switcher`.
- Tambah tanpa menyentuh proyek: taruh gambar (jpg/png/webp, **bukan** avif) di `~/.config/omarchy/backgrounds/stealth-black/`.
- Default tema = file pertama menurut nama di `theme/backgrounds/` (`1-black-ribbons.jpg`). Untuk mengubah default, ubah daftar `WALLPAPERS` di `scripts/build.sh`, lalu build/install/apply.

### Tipografi

```bash
scripts/typography.sh --dry-run    # rencana
scripts/typography.sh              # VS Code (JetBrains Mono 14/22, ligatures off) + foot 11 pt
scripts/typography.sh --rollback   # kembalikan hanya baris yang dipasang skrip
```

Font menu/launcher (IBM Plex Sans) diatur di `theme/hyprland.lua` dan aktif setelah `omarchy restart shell`. Paket yang dipasang: `ttf-jetbrains-mono`, `ttf-ibm-plex`. Lihat `docs/typography.md`.

### Layar unlock (Plymouth)

`theme/unlock.png` berisi wordmark Omarchy (dari tema bawaan matte-black, lisensi MIT) dengan gradasi silver `#EEF1F5` → `#7E8794` tanpa glow. Latarnya `#101216` dan teks/kotak password `#D7DCE2`, diambil otomatis dari `colors.toml`. Pratinjaunya ada di `theme/preview-unlock.png`.

Layar unlock boot **tidak diterapkan otomatis**, karena butuh sudo dan mengubah tampilan boot/dekripsi. Untuk menerapkannya, jalankan di terminal:

```bash
omarchy plymouth set by theme stealth-black   # minta password sudo
omarchy plymouth reset                        # kembali ke default Omarchy
```

Lock screen sesi (Super+Ctrl+L) adalah komponen lain, yaitu Omarchy shell. Warnanya sudah mengikuti tema lewat section `[lock]`.

### Rollback

```bash
scripts/rollback.sh --dry-run   # lihat rencana
scripts/rollback.sh             # kembali ke tema & wallpaper awal, hapus tema jika tidak diedit
```

Bisa dijalankan dari TTY (`Ctrl+Alt+F3`, login, lalu jalankan skrip) bila desktop tidak bisa dipakai. Rollback memanggil `omarchy theme set tokyo-night` (tema awal yang tercatat), yang juga mengembalikan VS Code ke "Tokyo Night", terminal, GTK, Brave, dsb. `settings.json` VS Code tidak pernah ditimpa; jika berbeda dari backup, diff ditampilkan. Backup tidak pernah dihapus.

Rollback darurat manual: `omarchy theme set tokyo-night`.

## Lokasi

| Apa | Path |
| --- | --- |
| Proyek | `~/obsidian-veil` |
| Tema terpasang | `~/.config/omarchy/themes/stealth-black/` (penanda `.stealth-black-owned`) |
| Tema aktif (dikelola Omarchy) | `~/.local/state/omarchy/current/theme/` |
| Backup pre-install | `~/.local/state/stealth-black/pre-install` → `backups/<waktu>-pre-install/` (mode 700) |
| Manifest instalasi | `~/.local/state/stealth-black/installed.manifest` |

## File yang disentuh

Langsung oleh skrip proyek: `~/.config/omarchy/themes/stealth-black/`, `~/.local/state/stealth-black/`.

Oleh `omarchy theme set` (mekanisme resmi, dipulihkan saat ganti tema): `~/.local/state/omarchy/current/*`, `~/.local/state/omarchy/theme-backgrounds/*`, `~/.config/Code/User/settings.json` (hanya `workbench.colorTheme`), `~/.vscode/extensions/omarchy-theme/`, `~/.claude/themes/omarchy.json`, gsettings (color-scheme, icon-theme), kebijakan warna Brave di `/etc/brave/policies/managed/color.json`, konfigurasi tema Obsidian/fcitx5.

Oleh `scripts/typography.sh`: 7 key font di `~/.config/Code/User/settings.json` dan baris `font=` di `~/.config/foot/foot.ini` (backup di `~/.local/state/stealth-black/typography/`).

Tidak disentuh: `~/.config/hypr/*`, `~/.config/omarchy/shell.json`, alias `monospace` fontconfig, keybinding, monitor, input, idle/lock.

## Opsional

- **Claude Code**: palet "Omarchy" sudah ditulis ke `~/.claude/themes/omarchy.json`, tetapi Claude Code masih memakai tema `dark`. Untuk memakai palet tema: pilih `custom:omarchy` lewat `/theme`, atau `omarchy-theme-set-claude --activate`.
- **Codex** mengikuti warna ANSI terminal (foot) tanpa konfigurasi tambahan.

## Keterbatasan

- Bergantung pada internal Omarchy 4.5 (override `shell.<section>.toml`, `hyprland.lua` tema, path state). Versi lain bisa berbeda; jalankan `validate.sh --installed` setelah upgrade.
- ANSI slot 0 = background (aturan Omarchy), bukan `#20242B` dari tabel spesifikasi.
- Black Dune hanya 1400×933 → diperbesar saat cover pada 1920×1080.
- Belum ada `preview.png` — tidak dibuat preview palsu.
- Lihat `docs/validation.md` untuk bagian yang belum diuji secara visual.
