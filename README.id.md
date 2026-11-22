# Obsidian Veil — Graphite & Silver

[English](README.md)

Tema Omarchy pribadi (`obsidian-veil`): desktop hitam matte berlapis dengan aksen graphite–silver untuk coding di VS Code, foot, Claude Code, dan Codex. Paletnya bernama "Stealth Black". Dibuat dan diuji untuk **Omarchy 4.5.0-2** (Hyprland Lua + Omarchy shell). Spesifikasinya ada di `CLAUDE.md`.

## Pasang

```bash
omarchy theme install https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme
```

Perintah ini memasang tema dan langsung menerapkannya: warna, bar, menu, notifikasi, terminal, VS Code, dan wallpaper. Repo ini hanya berisi file tema dan tidak menjalankan apa pun.

### Extras opsional

Omarchy membuang file `*.lua` dari tema hasil clone git, dan tema tidak boleh memasang hook. Karena itu sentuhan tambahan ada di repo terpisah, [obsidian-veil-extras](https://github.com/ramaanindyaa/obsidian-veil-extras): border 1 px, sudut 5 px, dan animasi singkat lewat hook `theme-set` Omarchy, ikon folder graphite, font menu IBM Plex Sans, wallpaper Resend, font VS Code dan foot, backup dengan rollback otomatis, serta alat validasi. Tema tetap berjalan tanpa extras.

## Struktur

```text
colors.toml              palet kanonik Omarchy (+ warna border Hyprland)
shell.*.toml             override section bar/popup/notifikasi/tooltip/launcher/menu
vscode-theme.json        tema VS Code (dirender dari template Omarchy)
backgrounds/             Black Ribbons (default) & Black Dune — Unsplash License
preview.png              screenshot asli untuk theme switcher (Neovim, btop, terminal, Nautilus)
unlock.png               logo layar unlock Plymouth (LUKS/boot)
preview-unlock.png       render nyata `omarchy plymouth preview`
docs/                    device-audit, design, typography, wallpaper-sources, validation
```

Wallpaper asli disimpan di luar repo, di `~/Pictures/obsidian-veil/` (bisa diganti lewat variabel `SB_ORIGINALS_DIR`). Folder itu dan tiga turunan Resend tidak di-commit; lihat `docs/wallpaper-sources.md`.

## Ikon folder

`icons.theme` berisi `Yaru-sage` sebagai fallback netral, yang selalu ada di Omarchy. [Extras](https://github.com/ramaanindyaa/obsidian-veil-extras) opsional (`enable-extras.sh --hook`) membangun tema ikon lokal **ObsidianVeil-Graphite** di `~/.local/share/icons/` (`scripts/build-icons.sh`). Tema ini dibuat dengan mewarnai ulang 263 ikon aksen Yaru-blue milik sistem (folder, places) ke rentang graphite `#2A3038` → `#C9D0D9`; ikon lain diwarisi dari Yaru. Hook memilih ikon ini hanya selama Obsidian Veil aktif. Saat pindah tema, ikon tema itu yang dipakai. Turunan dari Yaru (CC BY-SA 4.0) dibuat lokal dan tidak di-commit.

## Memakai

- Pilih tema: menu Omarchy → Theme → **Obsidian Veil**, atau `omarchy theme set obsidian-veil`.
- Ganti wallpaper: `omarchy theme bg next` atau `omarchy theme bg-switcher`. Wallpaper tambahan (jpg/png/webp, **bukan** avif) bisa diletakkan di `~/.config/omarchy/backgrounds/obsidian-veil/`.
- Update dari GitHub: `omarchy theme update`.

### Tipografi

| Area | Font | Ukuran |
| --- | --- | --- |
| VS Code editor | JetBrains Mono (fallback ikon JetBrainsMono Nerd Font) | 14 px / line height 22, weight 400, ligatures off |
| VS Code terminal | JetBrainsMono Nerd Font | 14 px |
| foot (Claude Code, Codex) | JetBrainsMono Nerd Font | 11 pt |
| Launcher/menu | IBM Plex Sans (Medium untuk judul baris) | default shell |
| Bar, jam, notifikasi | tetap alias `monospace` / Liberation Sans (keterbatasan shell) | — |

Paket font: `sudo pacman -S --needed ttf-jetbrains-mono ttf-ibm-plex`. Font VS Code dan foot dipasang oleh [extras](https://github.com/ramaanindyaa/obsidian-veil-extras) opsional (`typography.sh`), yang menolak berjalan bila font belum terpasang. Detail lengkap ada di `docs/typography.md`.

### Layar unlock (Plymouth)

`unlock.png` berisi wordmark Omarchy (dari tema bawaan matte-black, lisensi MIT) dengan gradasi silver `#EEF1F5` → `#7E8794`, tanpa glow. Latarnya `#101216` dan teks/kotak password `#D7DCE2`, diambil dari `colors.toml`. Layar ini **tidak diterapkan otomatis** karena butuh sudo dan mengubah tampilan boot/dekripsi:

```bash
omarchy plymouth set by theme obsidian-veil   # terapkan (minta password sudo)
omarchy plymouth reset                        # kembali ke default Omarchy
```

Lock screen sesi adalah komponen lain (Omarchy shell). Warnanya sudah mengikuti tema lewat section `[lock]`.

## Opsional

- **Claude Code**: palet "Omarchy" sudah tersedia. Untuk memakainya, pilih `custom:omarchy` lewat `/theme` atau jalankan `omarchy-theme-set-claude --activate`.
- **Codex** mengikuti warna ANSI terminal.

## Keterbatasan

- Bergantung pada internal Omarchy 4.5: override `shell.<section>.toml`, `OMARCHY_MENU_FONT`, template `hyprland.lua`, dan path state. [Extras](https://github.com/ramaanindyaa/obsidian-veil-extras) menyediakan `validate.sh --installed` dan `check-compat.sh` untuk memeriksanya setelah upgrade Omarchy.
- ANSI slot 0 = background (aturan Omarchy).
- Black Dune hanya 1400×933, jadi diperbesar saat ditampilkan *cover*.
- `preview.png` adalah screenshot asli 1920×1080 (layar perangkat ini, tanpa upscaling), sementara tema bawaan memakai 2560×1440. Terminal di pratinjau memakai 8 pt agar btop muat di panel seperempat layar; ukuran harian foot tetap 11 pt.
