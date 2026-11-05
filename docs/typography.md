# Tipografi — implementasi dan validasi (5 November 2026)

Spesifikasi: bagian **Tipografi** di `CLAUDE.md`.

## Lingkungan

Omarchy 4.5.0-2 · Hyprland (Lua) · Omarchy shell (Quickshell) · foot 1.28.0 · VS Code (profil default; `profiles/` kosong; tidak ada override font di `.vscode/settings.json` workspace hingga kedalaman 4 di home) · monitor eDP-1 1920×1080 scale 1.25.

## Font terpasang

| Paket | Versi | Sumber | Family yang terdaftar |
| --- | --- | --- | --- |
| `ttf-jetbrains-mono` | 2.304-2 | extra (baru dipasang, `pkexec pacman -S --needed`, tanpa `-y`) | `JetBrains Mono`: Regular, Italic, Medium, Bold, + varian lain |
| `ttf-ibm-plex` | 6.4.0-2 | extra (baru dipasang) | `IBM Plex Sans`: Regular, Medium, Bold, Italic, … (paket memuat seluruh keluarga Plex, ±99 MB, karena tidak ada paket Plex Sans saja) |
| `ttf-jetbrains-mono-nerd-basic` | 3.5.1-2 | omarchy (sudah ada) | `JetBrainsMono Nerd Font`: Regular, Bold, Italic, Bold Italic |

`fc-match` setelah pemasangan:

| Pola | Hasil |
| --- | --- |
| `JetBrains Mono:style=Regular/Medium/Italic/Bold` | `JetBrainsMono-Regular/Medium/Italic/Bold.ttf` |
| `IBM Plex Sans:style=Regular/Medium` | `IBMPlexSans-Regular/Medium.ttf` |
| `JetBrainsMono Nerd Font:style=Regular` | `JetBrainsMonoNerdFont-Regular.ttf` |
| `monospace` | `JetBrainsMono Nerd Font` (tidak berubah) |

## File yang diubah

| File | Perubahan | Backup |
| --- | --- | --- |
| `~/.config/Code/User/settings.json` | Menyisipkan 7 key setelah `{`: `editor.fontFamily` `'JetBrains Mono', 'JetBrainsMono Nerd Font', monospace`, `editor.fontSize` 14, `editor.lineHeight` 22, `editor.fontWeight` "400", `editor.fontLigatures` false, `terminal.integrated.fontFamily` `'JetBrainsMono Nerd Font'`, `terminal.integrated.fontSize` 14. Key lain, urutan, dan byte akhir file tetap utuh (tanpa round-trip parser JSON) | `~/.local/state/stealth-black/typography/pre-typography/` |
| `~/.config/foot/foot.ini` | Hanya `font=JetBrainsMono Nerd Font:size=9` → `size=11` | idem |
| `extras/hyprland-extras.lua` (dimuat hook theme-set) | `hl.env("OMARCHY_MENU_FONT", "IBM Plex Sans")` | dikelola `enable-extras.sh` / `rollback.sh` |

Komponen yang di-reload: `omarchy theme refresh` (tanpa mengganti wallpaper) dan `omarchy restart shell`. VS Code membaca `settings.json` secara langsung. Jendela foot yang sedang berjalan, termasuk sesi Claude Code ini, tetap memakai ukuran lama sampai jendelanya dibuka ulang. Tidak ada editor atau terminal yang ditutup.

## Hasil pemeriksaan

| Pemeriksaan | Status | Bukti |
| --- | --- | --- |
| Family benar-benar terdaftar | LULUS | `fc-list` / `fc-match` di atas |
| Font yang dipakai shell (bukan sekadar config) | LULUS | Proses `quickshell` baru memiliki `OMARCHY_MENU_FONT=IBM Plex Sans` dan memetakan `IBMPlexSans-Regular.ttf` + `IBMPlexSans-Medium.ttf`; screenshot menu memperlihatkan Plex Sans dan ikon tetap tampil lewat fallback |
| Bar dan jam | LULUS (tidak berubah) | Tetap `JetBrainsMonoNerdFont-Regular` di proses shell; screenshot bar tidak terpotong |
| Glyph ikon | LULUS | JetBrainsMono Nerd Font memuat U+E0B0/E0B6 (Powerline), U+E0A0/E725 (Git), U+F07B (folder), U+F00C/F071, U+F0214, box drawing U+2500–2588. JetBrains Mono biasa tidak punya ikon NF, jadi VS Code mengambilnya dari family kedua |
| 0/O, 1/l/I, tanda baca | LULUS (render offline) | Render pada ukuran fisik nyata (foot ≈18 px, VS Code 17,5 px): zero bertitik, `l` berekor, `I` berserif |
| Regular/Medium/Bold/Italic | LULUS | Setiap style di-resolve ke file varian yang sesuai; tidak ada sintesis Thin/ExtraLight |
| Kolom terminal sejajar | LULUS (sebagian) | Semua family mono memakai advance tetap; foot menggambar box drawing secara native. Visual foot baru BELUM DIUJI |
| `foot --check-config` | LULUS | — |
| `settings.json` valid | LULUS | Diparse sebagai JSON (file ini tidak berisi komentar); diff hanya 7 baris sisipan |
| Rollback tipografi | LULUS end-to-end | `typography.sh --rollback` mengembalikan `settings.json` dan `foot.ini` identik byte-per-byte (`cmp`), lalu diterapkan ulang |
| Idempotensi | LULUS | Run kedua tidak mengubah apa pun dan tidak membuat backup baru |
| Error Hyprland | LULUS | `hyprctl configerrors` kosong |
| Visual VS Code (editor, terminal terintegrasi, ligatures off) | BELUM DIUJI | VS Code tidak terbuka; tidak dibuka agar tidak mengganggu |
| Visual foot 11 pt, Claude Code/Codex | BELUM DIUJI | Perlu jendela foot baru; tidak dibuka agar tidak mencuri fokus |
| Notifikasi dan launcher penuh | Sebagian | Menu root sudah dicek; notifikasi tidak berubah |

Catatan: render offline dibuat dengan ImageMagick, yang tetap menampilkan ligature. Di VS Code ligature dimatikan oleh `editor.fontLigatures: false`.

## Rollback

```bash
cd ~/obsidian-veil
scripts/typography.sh --rollback --dry-run
scripts/typography.sh --rollback        # VS Code + foot; hanya key/baris yang masih persis milik skrip
# Font menu ikut hook tema; rollback.sh menghapus hook. Untuk melepasnya saja:
#   hapus baris hl.env di extras/hyprland-extras.lua, lalu omarchy theme refresh
# Paket font (opsional, tidak otomatis):
#   sudo pacman -R ttf-jetbrains-mono ttf-ibm-plex
```

Catatan: `hl.env` tidak menghapus variabel dari lingkungan Hyprland yang sedang berjalan. Setelah baris itu dihapus, menu baru benar-benar kembali ke `monospace` setelah sesi berikutnya, atau dengan `hl.env("OMARCHY_MENU_FONT", "")` lalu `omarchy restart shell`. Hal yang sama berlaku bila beralih ke tema lain: font menu Plex Sans masih bertahan sampai login ulang atau restart sesi.
