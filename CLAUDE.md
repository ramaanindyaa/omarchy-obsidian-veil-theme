# Obsidian Veil (palet Stealth Black) — Tema Omarchy Pribadi

## 1. Tujuan dan cara bekerja

Buat dan terapkan tema Omarchy bernama `obsidian-veil` (palet "Stealth Black") pada perangkat pengguna. Hasil akhir harus berupa desktop hitam matte berlapis dengan aksen graphite–silver, konsisten untuk coding menggunakan VS Code, terminal, Claude Code, dan Codex.

Dokumen ini adalah spesifikasi proyek dan panduan implementasi. Semua angka visual merupakan target desain, bukan klaim tentang konfigurasi bawaan. Sesuaikan implementasi dengan versi Omarchy dan aplikasi yang benar-benar terpasang.

- Berkomunikasi dalam Bahasa Indonesia yang jelas.
- Mulai dengan inspeksi lokal, lalu kerjakan implementasi sampai selesai; jangan berhenti hanya pada rencana.
- Pengguna mengizinkan pembuatan proyek, backup, pemasangan tema lokal, perubahan tampilan yang dapat dipulihkan, dan reload komponen tampilan yang aman. Jangan meminta konfirmasi berulang untuk hal tersebut.
- Jangan mengubah fungsi sistem, aplikasi, akun, jaringan, autentikasi, monitor, atau keybinding yang tidak berkaitan dengan tampilan.
- Jangan melakukan upgrade sistem, logout, reboot, restart compositor, memasang paket baru, menghapus konfigurasi pengguna, atau mengubah boot/dekripsi tanpa izin khusus. Tema desktop tidak memerlukan perubahan itu.
- Jangan mengunduh atau menjalankan skrip instalasi pihak ketiga. Wallpaper boleh diunduh sebagai data gambar.
- Jika tidak ada akses ke sesi desktop, lanjutkan pembuatan dan validasi statis. Jelaskan bagian penerapan dan verifikasi visual yang belum dapat dilakukan.
- Jangan menggunakan subagent kecuali pengguna memintanya secara eksplisit.

## 2. Konteks pengguna dan keputusan default

- OS: Omarchy Linux pada perangkat pengguna; jangan menganggap versi tertentu.
- Editor utama: VS Code.
- Kegiatan utama: coding, membaca kode, menjalankan terminal Claude Code/Codex, browser untuk dokumentasi.
- Nama tema (slug): `obsidian-veil`. Slug ini diturunkan `omarchy theme install` dari nama repo `omarchy-obsidian-veil-theme` (keputusan 5 November 2026; sebelumnya `stealth-black`).
- Nama tampilan: `Obsidian Veil` di switcher Omarchy (diturunkan dari slug); nama palet: `Stealth Black — Graphite & Silver`.
- Repo: https://github.com/ramaanindyaa/omarchy-obsidian-veil-theme (private). Isi tema berada di root repo agar bisa dipasang dengan `omarchy theme install`.
- Wallpaper default proyek: Black Ribbons karya Andrew Kliatskyi. Ini keputusan default yang dapat diganti; pengguna belum menetapkan pilihan final.
- Jika pengguna telah menyediakan wallpaper pilihannya dalam proyek, prioritaskan file itu.
- Desktop harus nyaman untuk bekerja, dengan informasi penting yang tetap jelas.

## 3. Prinsip visual

1. Gunakan beberapa tingkat hitam untuk memisahkan wallpaper, jendela, panel, dan seleksi.
2. Terapkan aksen silver hanya pada fokus, seleksi, cursor, dan indikator aktif.
3. Pertahankan warna semantik untuk error, sukses, peringatan, Git diff, dan syntax.
4. Gunakan latar solid atau hampir solid. Wallpaper tidak boleh mengganggu teks kode.
5. Pilih sudut kecil, border tipis, bayangan sangat halus, dan gerakan singkat.
6. Hindari neon, rainbow RGB, glow kuat, blur berat, kaca dominan, logo besar, dock baru, widget dekoratif, dan perubahan layout kerja otomatis.
7. Jangan menurunkan brightness layar atau mengubah profil warna monitor untuk mendapatkan tampilan gelap.
8. Jika antarmuka gelap kehilangan batas antarbagian, perbaiki perbedaan luminansinya sebelum menambah efek.

## 4. Palet wajib

| Token desain | Hex | Penggunaan |
| --- | --- | --- |
| wallpaper_base | `#08090B` | Warna acuan wallpaper, bukan perintah untuk mewarnai ulang gambar |
| background | `#101216` | Terminal/editor utama |
| surface | `#191C21` | Sidebar, popup, panel |
| surface_high | `#20242B` | Hover atau lapisan tambahan |
| selection | `#2A3038` | Seleksi teks dan item |
| border | `#30353D` | Garis pemisah dan border tidak aktif |
| accent | `#A9B4C2` | Fokus, border aktif, workspace aktif |
| foreground | `#D7DCE2` | Teks utama |
| muted | `#929AA5` | Teks sekunder, komentar, placeholder |
| bright_foreground | `#EEF1F5` | Cursor dan penekanan terbatas |
| red | `#D08484` | Error, deletion, status mendesak |
| orange | `#C59A7A` | Konstanta atau status tambahan |
| yellow | `#C3AA7A` | Warning |
| green | `#91AD95` | Sukses, addition |
| cyan | `#8FAEB2` | Tipe atau simbol tertentu |
| blue | `#92AAC7` | Keyword, link |
| magenta | `#AE9FBD` | Syntax tambahan |

Token desain tidak otomatis sama dengan key `colors.toml`. Petakan hanya ke key yang didukung versi lokal. Jangan mengasumsikan key arbitrer seperti `surface`, `wallpaper_base`, `border`, atau `cursor` otomatis dibaca Omarchy.

Jika versi lokal mendukung neutral ramp, gunakan kandidat berikut dan sesuaikan dengan semantik template lokal: `darker_background = #08090B`, `dark_background = #0C0E11`, `background = #101216`, `lighter_background = #191C21`, `selection = #2A3038`, `dark_foreground = #929AA5`, `foreground = #D7DCE2`, `light_foreground = #E2E7ED`, `bright_foreground = #EEF1F5`.

Pada beberapa versi cursor diturunkan dari `bright_foreground`, sedangkan versi lain memiliki konfigurasi aplikasi tersendiri. Pastikan dari implementasi lokal; jangan menambahkan key yang tidak digunakan.

### ANSI terminal

Petakan slot semantik berdasarkan implementasi lokal. Jika menggunakan ANSI 0–15:

| Slot | Hex | Slot terang | Hex |
| --- | --- | --- | --- |
| 0 black | `#20242B` | 8 bright black | `#929AA5` |
| 1 red | `#D08484` | 9 bright red | `#DDA0A0` |
| 2 green | `#91AD95` | 10 bright green | `#A8C2AC` |
| 3 yellow | `#C3AA7A` | 11 bright yellow | `#D4BD91` |
| 4 blue | `#92AAC7` | 12 bright blue | `#ACC0D9` |
| 5 magenta | `#AE9FBD` | 13 bright magenta | `#C1B3CE` |
| 6 cyan | `#8FAEB2` | 14 bright cyan | `#A6C4C8` |
| 7 white | `#D7DCE2` | 15 bright white | `#EEF1F5` |

Jika Omarchy menggunakan nama warna kanonik untuk menghasilkan ANSI, ikuti format tersebut. Jangan mengisi dua skema yang saling bertentangan. Verifikasi khusus slot black: teks hitam eksplisit bisa memiliki kontras rendah pada tema gelap; jangan mengandalkannya untuk teks penting.

## 5. Pemeriksaan perangkat sebelum menulis konfigurasi

Inspeksi hanya informasi yang dibutuhkan. Jangan mencetak seluruh environment atau file yang mungkin berisi token.

1. Tentukan direktori proyek, pengguna aktif, XDG config/data/state roots, dan apakah sesi Wayland aktif. Gunakan variabel khusus proyek; jangan menimpa `HOME` atau `XDG_CONFIG_HOME`.
2. Temukan executable Omarchy dan perintah versi/help yang tersedia. Periksa versi paket atau metadata lokal bila CLI versi tidak tersedia.
3. Temukan tema bawaan, tema pengguna, template, skrip theme-set, dan target aktif menggunakan konfigurasi/symlink yang benar-benar ada.
4. Cari dengan `rg`/`rg --files` pada lokasi relevan, bukan seluruh home tanpa batas.
5. Periksa contoh `colors.toml` dari Matte Black dan Vantablack jika tersedia. Catat perbedaan format versi lokal.
6. Baca konfigurasi utama Hyprland dan rantai include/source. Tentukan apakah menggunakan `.conf`, Lua, atau format lain; jangan mencampurkan sintaks.
7. Deteksi bar/shell aktif. Bisa berupa Waybar atau shell Omarchy versi lain. Jangan menginstal Waybar atau Walker jika sistem memakai komponen lain.
8. Deteksi terminal yang digunakan dan aplikasi yang terpasang; jangan membuat konfigurasi untuk aplikasi yang tidak ada.
9. Deteksi mekanisme tema VS Code: ekstensi, settings, generated theme, atau template. Hormati profil pengguna, VSCodium, maupun varian lain yang ditemukan.
10. Catat theme ID aktif, background aktif, target symlink, font, dan baseline error compositor/shell sebelum perubahan.
11. Baca `AGENTS.md`/`CLAUDE.md` yang relevan pada proyek dan instruksi lokal yang berlaku.

Gunakan dokumentasi versi lokal sebagai sumber utama. Dokumentasi online terbaru dapat berbeda dari perangkat. Jangan menyalin path `/usr/share/omarchy`, `~/.local/share/omarchy`, atau path state/current secara membabi buta: identifikasi mana yang benar-benar digunakan.

Simpan temuan ringkas dalam `docs/device-audit.md`, tanpa rahasia atau dump konfigurasi pribadi penuh.

## 6. Wallpaper

### Prioritas

1. File pilihan pengguna jika sudah diberikan.
2. Black Ribbons sebagai default proyek.
3. Jika unduhan gagal, gunakan wallpaper lokal paling sesuai tanpa mengganti pilihan secara diam-diam; catat fallback dan alasannya.

### Sumber default

- Karya: Curved black ribbons with soft highlights against a dark background.
- Pembuat: Andrew Kliatskyi.
- Halaman sumber: https://unsplash.com/photos/curved-black-ribbons-with-highlights-7og8GybWcZw
- Endpoint gambar yang sudah diketahui: https://images.unsplash.com/photo-1678366633407-7f49da199a42?auto=format&fit=max&w=3840&q=90
- Lisensi: periksa halaman sumber dan ketentuan Unsplash saat mengunduh; simpan attribution. Jangan menganggap semua gambar internet bebas didistribusikan ulang.

### Alternatif yang telah dipilih sebagai kandidat

| Nama | Sumber |
| --- | --- |
| Cubus | https://cdn.resend.com/wallpapers/6-a.jpg |
| Pilulae | https://cdn.resend.com/wallpapers/7-a.jpg |
| Discus | https://cdn.resend.com/wallpapers/2-a.jpg |
| Scalae | https://cdn.resend.com/wallpapers/8-a.jpg |
| Black Dune | https://unsplash.com/photos/a-black-and-white-photo-of-a-sand-dune-kz63JaDm9V4 |
| Layers Deep | https://raw.githubusercontent.com/basecamp/omarchy/v4.0.2/themes/vantablack/backgrounds/2-layers-deep.jpg |

Resend collection: https://resend.com/wallpapers — karya Raphael Fagundes, dipesan oleh Resend. URL Omarchy yang dipin ke v4.0.2 di atas hanya sumber gambar yang diketahui, bukan instruksi untuk menurunkan versi OS.

### Aturan pengolahan

- Unduh hanya wallpaper default, kecuali pengguna meminta paket alternatif.
- Gunakan HTTPS, timeout, pengecekan HTTP failure, file sementara, lalu rename setelah valid.
- Pastikan file adalah gambar yang bisa didekode, bukan HTML; catat MIME, dimensi, ukuran, dan SHA256.
- Sesuaikan ukuran dengan monitor dan scaling; jangan menganggap 4K atau rasio 16:9.
- Gunakan fill/cover jika sesuai. Jangan meregangkan gambar atau mengklaim upscaling menambah detail asli.
- Simpan sumber asli. Jika perlu crop/resize, buat turunan terpisah; jangan mengubah hue, menambah logo, atau menggelapkan berlebihan tanpa kebutuhan nyata.
- Jangan membuat gambar default dengan AI sebagai pengganti unduhan tanpa menjelaskan dan mendapat arahan pengguna.
- Pertahankan wallpaper tiap monitor jika pengguna memiliki pilihan berbeda; jangan menyamaratakannya tanpa kebutuhan.

Simpan attribution dan status izin distribusi dalam `docs/wallpaper-sources.md`. Untuk repo publik, jika izin bundling tidak jelas, sediakan downloader/link dan jangan commit bitmap pihak ketiga.

## 7. Spesifikasi komponen

### Hyprland / dekorasi

- Border: 1–2 logical px; mulai dari 1 jika terlihat jelas pada scaling aktual.
- Border aktif: accent; tidak aktif: border. Tidak ada gradient rainbow.
- Jarak terlihat antarkontainer: target 8–12 logical px. Terjemahkan ke semantik `gaps_in`/`gaps_out` versi lokal; jangan mengasumsikan nilainya identik dengan jarak hasil akhir.
- Sudut: 4–6 logical px jika didukung.
- Jendela aktif dan tidak aktif tetap legible; jangan meredupkan jendela tidak aktif secara agresif.
- Latar aplikasi solid; hindari opacity global yang ikut memudarkan teks.
- Shadow sangat lembut atau nonaktif jika tidak memberi pemisahan visual yang berguna.
- Blur minimal; nonaktifkan jika tidak diperlukan.
- Animasi pendek, sasaran sekitar 120–180 ms hanya bila format lokal mendukung durasi tersebut. Jika menggunakan parameter speed/bezier, jangan memasukkan milidetik sebagai nilai speed.
- Jangan mengganti layout tiling, binding, gesture, fokus, rule aplikasi, resolusi, scale, atau refresh rate.
- Perubahan geometry bersifat override pengguna terpisah jika tidak bisa dikemas sebagai tema warna. Dokumentasikan cakupannya dan pulihkan secara terpisah.

### Bar dan shell

- Pertahankan komponen dan susunan yang ada; terapkan palet dahulu.
- Tinggi bar sasaran 28–32 logical px jika dapat disesuaikan tanpa merusak layout.
- Workspace aktif dibedakan melalui latar/penanda dan warna; urgent memakai red.
- Pertahankan jam, network, audio, battery dan indikator sistem yang sudah ada.
- Jangan menambah grafik CPU/RAM atau widget baru secara otomatis.
- Terapkan warna ke launcher, notification, OSD, dan lock screen melalui mekanisme lokal yang didukung.
- Jangan mengubah backend lock screen, timeout idle, suspend, atau alur autentikasi.

### Terminal

- Terapkan palette ANSI dan foreground/background.
- Latar solid, cursor terbaca, seleksi jelas, URL dan pencarian terlihat.
- Font dan ukuran mengikuti bagian **Tipografi** di bawah. Jangan mengunduh font di luar keluarga yang ditetapkan di sana.
- Jangan mengubah shell startup command, SSH, prompt framework, executable Claude/Codex, atau meng-hardcode kredensial.
- Warna Git: addition green, deletion red, warning yellow; diff tetap dapat dibedakan.

### VS Code

- Editor background: background; sidebar/popup: surface; teks utama: foreground.
- Active line tipis dan tenang; selection menggunakan selection; focus border accent.
- Status bar gelap tanpa blok biru/ungu terang, sambil tetap membedakan mode penting seperti debugging.
- Pertahankan syntax highlighting semantik; jangan memaksa seluruh kode menjadi grayscale.
- Comments menggunakan muted; jangan menjadikannya hampir hitam.
- Error squiggle, warning, Git gutter, search match, bracket match, selected text, dan terminal terintegrasi harus jelas.
- Gunakan mekanisme integrasi Omarchy lokal jika tersedia. Jika tidak, buat tema lokal minimal atau override warna yang terarah; jelaskan tradeoff dan hindari instalasi Marketplace otomatis.
- Preserve JSONC, komentar, settings, profile, keybindings, extension list, dan konfigurasi workspace pengguna. Jangan memproses JSONC dengan parser JSON biasa.
- Jangan mengganti settings global dengan file baru seluruhnya. Gunakan patch minimal dan backup.

### Tipografi

Keputusan pengguna (5 November 2026). Target: modern, tenang, tegas; keterbacaan coding diutamakan; tidak memakai Thin/ExtraLight untuk teks utama. Tipografi tidak mengubah warna, wallpaper, keybinding, atau layout.

| Area | Font (family fontconfig) | Ukuran awal | Mekanisme Omarchy 4.5 |
| --- | --- | --- | --- |
| VS Code editor | `JetBrains Mono` Regular (fallback ikon `JetBrainsMono Nerd Font`, lalu `monospace`) | 14 px, line height 22 px, weight 400, ligatures **off** | `~/.config/Code/User/settings.json` (patch key minimal) |
| VS Code terminal terintegrasi | `JetBrainsMono Nerd Font` | 14 px | idem |
| Terminal eksternal (foot: Claude Code, Codex) | `JetBrainsMono Nerd Font` Regular | 11 pt (foot menskalakan pt × scale 1.25 ≈ 18 px fisik) | baris `font=` di `~/.config/foot/foot.ini` |
| Launcher/menu, clipboard, emoji, polkit, reminder | `IBM Plex Sans` Regular; Medium untuk judul baris (bawaan menu) | base-size 12 logical px (tidak diubah) | `hl.env("OMARCHY_MENU_FONT", "IBM Plex Sans")` di `extras/hyprland-extras.lua` (dimuat oleh hook theme-set), berlaku setelah shell di-restart oleh hook |
| Bar, jam, judul notifikasi | tetap alias `monospace` = `JetBrainsMono Nerd Font` | base-size 12 | Lihat batasan |
| Isi notifikasi | `Liberation Sans` (di-hardcode shell Omarchy) | — | Lihat batasan |

Catatan dan batasan:

- **Nerd Font Mono tidak dipakai.** Pengguna awalnya memilih `JetBrainsMono Nerd Font Mono`, tetapi Omarchy hanya memasang `ttf-jetbrains-mono-nerd-basic` (tanpa varian Mono). Paket resmi lengkap `ttf-jetbrains-mono-nerd` bentrok dengan paket dasar Omarchy itu dan akan menghapusnya, jadi pengguna memilih varian yang sudah terpasang. Glyph-nya sama dan kolom terminal tetap sejajar karena foot memakai sel tetap; ikon hanya tidak diperkecil ke satu sel.
- Omarchy shell 4.5 tidak punya pengaturan font per komponen untuk bar dan notifikasi. Keduanya mengikuti alias `monospace` sistem; isi notifikasi di-hardcode `Liberation Sans`. Mengubah alias `monospace` menjadi font sans akan merusak terminal dan ikon, sedangkan meng-clone plugin bar/notifikasi termasuk perubahan besar. Karena itu bar dan notifikasi tidak diubah, begitu juga jam: JetBrains Mono Medium tidak dipakai karena plugin jam tidak punya opsi font, dan varian NF-basic tidak punya Medium.
- Jangan menjalankan `omarchy font set` tanpa sadar: perintah itu menulis ulang baris `font=` foot (ukurannya dipertahankan) dan alias `monospace`.
- Paket terpasang: `ttf-jetbrains-mono` 2.304-2 dan `ttf-ibm-plex` 6.4.0-2 (repo `extra`). Alias `monospace` tetap mengarah ke JetBrainsMono Nerd Font.
- Implementasi: `scripts/typography.sh` (dengan `--dry-run` dan `--rollback`). Detail dan hasil pemeriksaan ada di `docs/typography.md`.

### Aplikasi lainnya

Gunakan template Omarchy untuk aplikasi yang benar-benar didukung. Periksa terminal, file manager, browser chrome, btop, Neovim/Helix, notification, launcher, OSD, dan lock screen yang ditemukan. Jangan menjanjikan tema situs web/browser content mengikuti desktop. Jangan menambahkan ekstensi dark-mode browser otomatis.

## 8. Struktur hasil proyek

Gunakan struktur berikut sebagai panduan; kurangi file yang tidak diperlukan dan sesuaikan nama konfigurasi dengan versi lokal:

```text
omarchy-obsidian-veil-theme/      # root repo = direktori tema Omarchy
  CLAUDE.md
  README.md
  colors.toml
  shell.*.toml
  vscode-theme.json
  backgrounds/                    # hanya aset yang layak dibundel (Unsplash)
  unlock.png                      # logo Plymouth
  preview-unlock.png              # render nyata omarchy plymouth preview
  extras/
    hyprland-extras.lua           # dekorasi Lua (Omarchy membuang *.lua dari tema git)
    theme-set-hook.sh             # hook resmi yang memuat extras saat tema diterapkan
  scripts/
    install.sh  enable-extras.sh  apply.sh  rollback.sh  validate.sh
    build.sh  build_unlock.sh  fetch-wallpaper.sh  typography.sh
  docs/
    device-audit.md  design.md  typography.md  wallpaper-sources.md  validation.md
```

Jangan menaruh `*.lua`, `alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`, atau `vscode.json` di root repo, karena Omarchy membuangnya dari tema yang dipasang lewat git. Taruh logika seperti itu di `extras/` dan aktifkan lewat hook.

Jangan membuat preview palsu lalu menyebutnya screenshot hasil implementasi. Jika belum ada akses screenshot, biarkan preview belum tersedia.

## 9. Backup, instalasi, dan rollback

### Sebelum perubahan pertama

- Buat backup dengan timestamp dan izin privat di lokasi state pengguna yang sesuai, di luar repo publik.
- Backup hanya file yang akan diubah beserta metadata/symlinknya; jangan menyalin seluruh home.
- Rekam path asli, tipe file, target symlink, hash, file yang sebelumnya tidak ada, dan tema/background aktif.
- Jika ada symlink menuju dotfiles repo, identifikasi pemiliknya dan hindari menulis menembus symlink tanpa memahami akibatnya.
- Simpan rollback yang bisa dijalankan melalui terminal/TTY sebelum menerapkan tema.

### Instalasi

1. Bangun file tema di proyek, bukan langsung di target aktif.
2. Validasi TOML, format aplikasi, serta warna yang dihasilkan.
3. Pasang ke direktori tema pengguna yang ditemukan. Jangan mengedit tema bawaan atau file milik paket.
4. Jika target `obsidian-veil` sudah ada, bandingkan terlebih dahulu dan backup; jangan timpa tema pengguna lain secara diam-diam.
5. Unduh dan pasang wallpaper pada lokasi yang dipakai versi lokal.
6. Gunakan CLI theme-set resmi yang tersedia di mesin; periksa help/implementasinya sebelum dipanggil. Jangan hardcode satu bentuk command untuk semua versi.
7. Reload hanya komponen yang perlu dan hanya melalui cara yang didukung. Jangan `killall` secara luas.
8. Jika konfigurasi baru menghasilkan error atau UI tidak dapat dipakai, rollback segera.

### Persyaratan skrip

- Gunakan Bash yang jelas, quote path, tangani error, dan keluar nonzero pada kegagalan.
- Mendukung path dengan spasi, symlink, file yang belum ada, dan instalasi berulang.
- Install ulang tanpa perubahan tidak membuat backup tak terbatas atau menggandakan include.
- Sediakan `--dry-run` untuk menunjukkan rencana perubahan tanpa menulis config, mendownload, atau reload.
- Jangan menggunakan `sudo` sebagai default, mengubah permission secara luas, atau menjalankan `curl | bash`.
- Gunakan temporary file + rename untuk perubahan atomik pada filesystem yang sama.
- Rekam file mana yang dimiliki proyek. Uninstall tidak boleh menghapus file pengguna yang tidak dikenal.

### Rollback

- Pulihkan tema/background awal melalui mekanisme lokal yang sesuai.
- Pulihkan override pengguna beserta symlink yang sebelumnya ada.
- Hapus hanya file buatan proyek yang sebelumnya tidak ada, setelah memastikan file belum diubah pengguna.
- Bandingkan hash sebelum memulihkan: jika pengguna mengedit setelah instalasi, simpan perubahan tersebut dan jangan menimpanya diam-diam.
- Pulihkan hanya bagian yang relevan; jangan menyalin ulang settings lama secara penuh jika ada perubahan pengguna sesudah instalasi.
- Reload komponen yang diperlukan dan laporkan hasilnya. Jangan menghapus backup otomatis.

## 10. Validasi yang wajib dilakukan

### Statis

- Parse `colors.toml` menggunakan parser TOML yang tersedia, misalnya Python `tomllib` jika versi Python mendukung.
- Pastikan semua hex valid dan tidak ada placeholder template belum tersubstitusi.
- Periksa bahwa key palet benar-benar dibaca implementasi lokal dan fallback warna sesuai.
- Validasi sintaks shell menggunakan `bash -n`; gunakan ShellCheck jika sudah terpasang, tanpa memasang paket hanya untuk pemeriksaan ini.
- Validasi format override sesuai parser aplikasi; jangan menyebut hasil validasi parsial sebagai validasi penuh.
- Periksa diff agar tidak ada setting fungsional atau file di luar lingkup yang berubah.
- Hitung kontras dengan rumus WCAG relative luminance sRGB untuk pasangan teks utama/sekunder terhadap background terkait. Sasaran teks biasa setidaknya 4.5:1. Token utama terhadap background diperkirakan 13.6:1 dan muted 6.6:1; hitung ulang, jangan hanya menyalin angka.
- Periksa teks yang dipilih, hover, placeholder, status, dan warna foreground-background ANSI yang lazim; jangan mengklaim seluruh kombinasi ANSI memenuhi kontras.

### Pada sesi desktop

- Terapkan tema dan periksa error baru dibanding baseline compositor/shell.
- Periksa VS Code, terminal aktif, terminal terintegrasi, launcher/menu, notification, file manager, dan bar yang tersedia.
- Periksa fokus aktif/tidak aktif, seleksi, pencarian, komentar, Git diff, warning, error, link, dan cursor.
- Periksa wallpaper pada resolusi/scale aktual dan setiap monitor; pastikan tidak stretched.
- Periksa tidak ada bar/widget yang terpotong dan teks tidak bertabrakan pada scaling aktual.
- Periksa warna lock screen melalui metode preview bila tersedia. Jangan mengunci sesi atau melakukan suspend otomatis saat pengguna sedang bekerja; catat pemeriksaan manual jika diperlukan.
- Jika tersedia akses screenshot, simpan screenshot yang tidak menampilkan token atau data pribadi, dan inspeksi hasilnya. Jangan menutup pekerjaan pengguna untuk menyiapkan screenshot.
- Verifikasi rollback secara non-destruktif/dry-run. Jangan mengklaim rollback end-to-end lulus bila belum benar-benar diuji; dokumentasikan level pengujiannya.
- Verifikasi tema lain tetap bisa dipilih, dan jelaskan override geometry yang bersifat global bila ada.

Catat hasil nyata dalam `docs/validation.md` dengan status lulus/gagal/belum diuji dan alasan. Jangan membuat benchmark performa atau klaim penghematan baterai tanpa pengukuran.

## 11. Definition of done

Pekerjaan selesai jika:

- Tema `obsidian-veil` tersedia lewat mekanisme tema lokal (`omarchy theme install`) dan bisa diterapkan.
- Tampilan memenuhi palet, hierarki lapisan, border, dan keterbacaan di atas.
- Wallpaper default atau pilihan pengguna terpasang dengan attribution yang jelas.
- VS Code dan terminal konsisten tanpa kehilangan warna semantik.
- Tidak ada error konfigurasi baru yang belum diselesaikan.
- Tidak ada perubahan fungsional di luar lingkup.
- Backup serta rollback tersedia sebelum aktivasi dan sudah diverifikasi sesuai kemampuan akses.
- README memuat cara install, apply, mengganti wallpaper, rollback, keterbatasan versi, serta daftar file yang disentuh.
- Hasil pengujian nyata dan bagian yang belum diuji dijelaskan secara jujur.

Jika akses/perangkat membatasi aktivasi, berikan hasil yang siap dipasang dan perintah tepat untuk versi yang ditemukan; nyatakan tahap yang belum selesai tanpa mengklaim tema sudah aktif.

## 12. Urutan pelaksanaan dan laporan akhir

Kerjakan: audit lokal → backup dan rollback → tema warna → wallpaper → integrasi aplikasi → dekorasi minimal → validasi → aktivasi → inspeksi hasil → dokumentasi akhir.

Laporan akhir singkat harus menyebut:

1. Versi Omarchy/komponen yang ditemukan.
2. Lokasi proyek, tema terpasang, backup, dan rollback.
3. Wallpaper yang benar-benar dipakai.
4. Perubahan visual utama dan cakupan override global.
5. Pemeriksaan yang lulus, masalah yang tersisa, dan bagian yang belum diuji.
6. Perintah apply/rollback yang sudah disesuaikan dengan mesin tersebut.

Jangan berhenti setelah audit jika implementasi berikutnya dapat dilanjutkan dengan aman dalam lingkup ini.

## 13. Referensi

Gunakan dokumentasi lokal terlebih dahulu, lalu referensi resmi berikut untuk klarifikasi. Halaman online dapat berubah dan tidak selalu cocok dengan versi mesin.

- https://omarchy.org/manual/making-your-own-theme/
- https://omarchy.org/manual/backgrounds/
- https://omarchy.org/manual/dotfiles/
- https://github.com/omacom/omarchy/blob/quattro/docs/theming.md
- https://resend.com/wallpapers
- https://unsplash.com/photos/curved-black-ribbons-with-highlights-7og8GybWcZw

Dokumen disusun pada 5 November 2026. Jangan menganggap tanggal ini sebagai bukti versi Omarchy yang sedang terpasang.
