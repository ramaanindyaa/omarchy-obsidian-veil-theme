# Obsidian Veil — Graphite & Silver

Tema Omarchy pribadi (`obsidian-veil`): desktop hitam matte berlapis dengan aksen graphite–silver untuk coding di VS Code, foot, Claude Code, dan Codex. Paletnya bernama "Stealth Black". Dibuat dan diuji untuk **Omarchy 4.5.0-2** (Hyprland Lua + Omarchy shell). Spesifikasinya ada di `CLAUDE.md`.

## Pasang

### Cara 1 — `omarchy theme install` + extras (semua fitur)

```bash
omarchy theme install https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme
~/.config/omarchy/themes/obsidian-veil/scripts/enable-extras.sh --all
```

Perintah pertama memasang tampilan inti dan langsung menerapkannya. Perintah kedua dijalankan sekali saja dan memasang yang tidak bisa dibawa `omarchy theme install`:

| Opsi | Isi |
| --- | --- |
| `--hook` | Hook `theme-set` resmi Omarchy: border 1 px, sudut 5 px, animasi 120–180 ms, terminal & Nautilus solid, font menu IBM Plex Sans, ikon folder graphite |
| `--wallpapers` | Mengunduh Pilulae, Discus, Cubus (Resend) ke `~/.config/omarchy/backgrounds/obsidian-veil/` |
| `--typography` | Font VS Code & foot (lihat bawah), dengan backup |
| `--all` | Semuanya (default) |

Kenapa perlu langkah kedua? Demi keamanan, Omarchy membuang semua `*.lua` dari tema hasil clone git. Karena itu dekorasi Hyprland disimpan di `extras/hyprland-extras.lua`. Hook yang dipasang `enable-extras.sh` menambahkannya ke `hyprland.lua` tema aktif setiap kali Obsidian Veil diterapkan. Saat pindah ke tema lain, file itu dibuat ulang sehingga dekorasi ikut hilang. Catatan: `omarchy theme update` bisa membawa perubahan isi `extras/hyprland-extras.lua` dari repo ini.

### Cara 2 — satu perintah, dengan backup dan rollback otomatis

```bash
git clone https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme.git ~/obsidian-veil
~/obsidian-veil/scripts/install.sh            # tambahkan --dry-run untuk melihat rencana
```

`install.sh` melakukan langkah berikut:
1. Mencatat tema, wallpaper, dan pengaturan VS Code yang aktif ke `~/.local/state/obsidian-veil/`.
2. Memasang hook.
3. Menjalankan `omarchy theme install`.
4. Menjalankan `enable-extras.sh --wallpapers --typography`.
5. Memasang Black Ribbons sebagai wallpaper awal.
6. Memeriksa `hyprctl configerrors`, dan rollback otomatis bila ada error baru.

Opsi: `--local` (clone dari working copy ini), `--url <git-url>`, `--no-extras`.

Repo private: di mesin lain, login GitHub dulu (`gh auth login`) atau jadikan repo public.

## Struktur

```text
colors.toml              palet kanonik Omarchy (+ warna border Hyprland)
shell.*.toml             override section bar/popup/notifikasi/tooltip/launcher/menu
vscode-theme.json        tema VS Code (dirender build.sh dari template Omarchy)
backgrounds/             Black Ribbons (default) & Black Dune — Unsplash License
preview.png              screenshot asli untuk theme switcher (Neovim, btop, terminal, Nautilus)
unlock.png               logo layar unlock Plymouth (LUKS/boot)
preview-unlock.png       render nyata `omarchy plymouth preview`
extras/                  hyprland-extras.lua + theme-set-hook.sh (lihat Cara 1)
scripts/                 install, enable-extras, apply, rollback, validate, build, typography, ...
docs/                    device-audit, design, typography, wallpaper-sources, validation
```

Wallpaper asli disimpan di luar repo, di `~/Pictures/obsidian-veil/` (bisa diganti lewat variabel `SB_ORIGINALS_DIR`). Folder itu dan tiga turunan Resend tidak di-commit; lihat `docs/wallpaper-sources.md`.

Menambah wallpaper baru: taruh file asli di `~/Pictures/obsidian-veil/`, tambahkan satu baris di daftar `WALLPAPERS` pada `scripts/build.sh`, lalu jalankan `scripts/build.sh`. Hasilnya masuk ke `backgrounds/`.

## Ikon folder

`icons.theme` berisi `Yaru-sage` sebagai fallback netral, yang selalu ada di Omarchy. `enable-extras.sh --hook` membangun tema ikon lokal **ObsidianVeil-Graphite** di `~/.local/share/icons/` (`scripts/build-icons.sh`). Tema ini dibuat dengan mewarnai ulang 263 ikon aksen Yaru-blue milik sistem (folder, places) ke rentang graphite `#2A3038` → `#C9D0D9`; ikon lain diwarisi dari Yaru. Hook memilih ikon ini hanya selama Obsidian Veil aktif. Saat pindah tema, ikon tema itu yang dipakai. Turunan dari Yaru (CC BY-SA 4.0) dibuat lokal dan tidak di-commit.

## Memakai

- Pilih tema: menu Omarchy → Theme → **Obsidian Veil**, atau `omarchy theme set obsidian-veil`, atau `scripts/apply.sh` (dengan cek error).
- Ganti wallpaper: `omarchy theme bg next` atau `omarchy theme bg-switcher`. Wallpaper tambahan (jpg/png/webp, **bukan** avif) bisa diletakkan di `~/.config/omarchy/backgrounds/obsidian-veil/`.
- Update dari GitHub: `omarchy theme update`.
- Validasi: `scripts/validate.sh --installed`.

### Tipografi

| Area | Font | Ukuran |
| --- | --- | --- |
| VS Code editor | JetBrains Mono (fallback ikon JetBrainsMono Nerd Font) | 14 px / line height 22, weight 400, ligatures off |
| VS Code terminal | JetBrainsMono Nerd Font | 14 px |
| foot (Claude Code, Codex) | JetBrainsMono Nerd Font | 11 pt |
| Launcher/menu | IBM Plex Sans (Medium untuk judul baris) | default shell |
| Bar, jam, notifikasi | tetap alias `monospace` / Liberation Sans (keterbatasan shell) | — |

Paket font: `sudo pacman -S --needed ttf-jetbrains-mono ttf-ibm-plex`. `scripts/typography.sh` menolak berjalan bila font belum terpasang. Detail lengkap ada di `docs/typography.md`.

### Layar unlock (Plymouth)

`unlock.png` berisi wordmark Omarchy (dari tema bawaan matte-black, lisensi MIT) dengan gradasi silver `#EEF1F5` → `#7E8794`, tanpa glow. Latarnya `#101216` dan teks/kotak password `#D7DCE2`, diambil dari `colors.toml`. Layar ini **tidak diterapkan otomatis** karena butuh sudo dan mengubah tampilan boot/dekripsi:

```bash
omarchy plymouth set by theme obsidian-veil   # terapkan (minta password sudo)
omarchy plymouth reset                        # kembali ke default Omarchy
```

Lock screen sesi adalah komponen lain (Omarchy shell). Warnanya sudah mengikuti tema lewat section `[lock]`.

## Ganti tema dan update Omarchy

**Ganti tema.** Dekorasi Obsidian Veil hanya ada selama tema ini aktif:

| Aksi | Hasil (diuji) |
| --- | --- |
| Ganti ke tema lain (menu atau `omarchy theme set`) | Border, sudut, animasi, opacity, bar, dan menu kembali ke milik tema itu; VS Code ikut tema itu |
| Kembali ke Obsidian Veil | Semua fitur muncul lagi otomatis lewat hook; wallpaper terakhir diingat Omarchy |
| Ganti tema beruntun dengan cepat | Aman: hook menunggu lock `omarchy-theme-set` dan hanya bekerja bila Obsidian Veil masih aktif |
| `omarchy theme bg next`, `hyprctl reload`, `omarchy theme refresh` | Fitur tetap aktif, tidak dobel |
| Login ulang / reboot | Fitur tetap aktif (file tema aktif disimpan), font menu terbaca sejak shell mulai |

Yang tetap terbawa ke tema lain: font VS Code/foot (pengaturan aplikasi, bukan tema). Font menu IBM Plex Sans juga bertahan sampai login ulang.

**Update Omarchy.** `omarchy update` dan migrasinya tidak menghapus tema pengguna, hook, maupun wallpaper pengguna. Beberapa migrasi menjalankan `omarchy theme refresh`, yang memicu hook sehingga fitur dipasang lagi. Risikonya ada pada versi Omarchy berikutnya yang mungkin mengubah titik integrasi (format override shell, variabel font menu, template border, mekanisme hook). Untuk memeriksanya:

```bash
~/.config/omarchy/themes/obsidian-veil/scripts/check-compat.sh        # read-only
~/.config/omarchy/themes/obsidian-veil/scripts/enable-extras.sh --update-check   # opsional: jalankan otomatis setelah setiap omarchy update
```

Opsi kedua (sudah dipasang di laptop ini) memasang `check-compat.sh` sebagai hook `post-update`. Hook itu hanya mengirim notifikasi bila ada yang rusak, dan dilepas oleh `rollback.sh`. Bila ada yang GAGAL, tampilan inti biasanya tetap jalan; jalankan `omarchy theme set tokyo-night` bila perlu, lalu perbaiki repo. Bila template VS Code Omarchy berubah, `check-compat.sh` memberi tahu: jalankan `scripts/build.sh`, commit, push, lalu `omarchy theme update`.

## Apakah folder clone (`~/obsidian-veil`) boleh dihapus?

Boleh. Setelah tema terpasang, hook, ikon, wallpaper, dan backup tidak bergantung pada folder clone ini. Semua skrip juga ada di `~/.config/omarchy/themes/obsidian-veil/scripts/`, termasuk `rollback.sh`, yang menghapus folder tema paling akhir sehingga aman dijalankan dari sana. Sebelum menghapus, pastikan dua hal:
- tidak ada perubahan yang belum di-push (`git status`);
- file asli wallpaper sudah berada di `~/Pictures/obsidian-veil/`, di luar repo, jadi tidak ikut terhapus.

## Rollback

```bash
~/.config/omarchy/themes/obsidian-veil/scripts/rollback.sh --dry-run
~/.config/omarchy/themes/obsidian-veil/scripts/rollback.sh                 # atau: --to tokyo-night bila tidak ada backup
```

Rollback melakukan langkah berikut:
1. Kembali ke tema dan wallpaper sebelumnya lewat `omarchy theme set`, yang juga mengembalikan VS Code, terminal, GTK, dan Brave.
2. Menghapus hook, wallpaper Resend yang dibuat, dan clone tema. Masing-masing hanya dihapus bila masih persis seperti saat dipasang; bila sudah berubah, isinya dipindah ke folder backup.
3. Mengembalikan baris font VS Code dan foot.

`settings.json` VS Code tidak pernah ditimpa. Backup tidak pernah dihapus. Rollback bisa dijalankan dari TTY (`Ctrl+Alt+F3`). Font menu Plex Sans masih bertahan di lingkungan Hyprland sampai login ulang.

Rollback darurat manual: `omarchy theme set tokyo-night`.

## File yang disentuh

| Oleh | Path |
| --- | --- |
| `omarchy theme install` | `~/.config/omarchy/themes/obsidian-veil/` (clone git) |
| `enable-extras.sh` | `~/.local/share/icons/ObsidianVeil-Graphite/`, `~/.config/omarchy/hooks/theme-set.d/50-obsidian-veil-extras`, `~/.config/omarchy/backgrounds/obsidian-veil/`, `~/.cache/obsidian-veil/wallpapers/` |
| `typography.sh` | 7 key font di `~/.config/Code/User/settings.json`, baris `font=` di `~/.config/foot/foot.ini` |
| skrip proyek | `~/.local/state/obsidian-veil/` (backup mode 700, manifest) |
| `omarchy theme set` (resmi) | `~/.local/state/omarchy/current/*`, `colorTheme` VS Code + `~/.vscode/extensions/omarchy-theme/`, `~/.claude/themes/omarchy.json`, gsettings, kebijakan warna Brave, tema Obsidian/fcitx5 |

Tidak disentuh: `~/.config/hypr/*`, `~/.config/omarchy/shell.json`, alias `monospace` fontconfig, keybinding, monitor, input, idle/lock.

## Opsional

- **Claude Code**: palet "Omarchy" sudah tersedia. Untuk memakainya, pilih `custom:omarchy` lewat `/theme` atau jalankan `omarchy-theme-set-claude --activate`.
- **Codex** mengikuti warna ANSI terminal.

## Keterbatasan

- Bergantung pada internal Omarchy 4.5: override `shell.<section>.toml`, `OMARCHY_MENU_FONT`, template `hyprland.lua`, dan path state. Jalankan `scripts/validate.sh --installed` setelah upgrade Omarchy.
- ANSI slot 0 = background (aturan Omarchy).
- Black Dune hanya 1400×933, jadi diperbesar saat ditampilkan *cover*.
- `preview.png` adalah screenshot asli 1920×1080 (layar perangkat ini, tanpa upscaling), sementara tema bawaan memakai 2560×1440. Terminal di pratinjau memakai 8 pt agar btop muat di panel seperempat layar; ukuran harian foot tetap 11 pt.
