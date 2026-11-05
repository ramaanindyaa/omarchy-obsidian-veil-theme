# Sumber wallpaper

Semua file asli disediakan pengguna di `Backgrounds/` dan tidak diubah. Turunan untuk tema ada di `theme/backgrounds/` (dibuat oleh `scripts/build.sh`). Repo GitHub (private) hanya memuat turunan Black Ribbons dan Black Dune (Unsplash License). Tiga gambar Resend tidak di-commit (`.gitignore`) karena izin redistribusinya tidak jelas; ambil dengan `scripts/fetch-wallpaper.sh --all`, lalu jalankan `scripts/build.sh`. Folder `Backgrounds/` asli tidak di-commit.

| Tema | Asli (pengguna) | Karya / pembuat | Sumber | Status izin distribusi |
| --- | --- | --- | --- | --- |
| `1-black-ribbons.jpg` (default) | `bg1.avif` 1400×788; versi 3840×2160 diunduh ke `Backgrounds/source/black-ribbons-3840.jpg` | *Curved black ribbons with soft highlights* — Andrew Kliatskyi | https://unsplash.com/photos/curved-black-ribbons-with-highlights-7og8GybWcZw | Unsplash License: boleh dipakai bebas, tetapi tidak boleh dijual tanpa modifikasi atau dihimpun ulang sebagai layanan wallpaper serupa. Penggunaan pribadi aman; bundling publik sebaiknya via downloader. |
| `2-pilulae.jpg` | `bg2.jpg` 7680×4320 | Pilulae — Raphael Fagundes untuk Resend | https://cdn.resend.com/wallpapers/7-a.jpg (koleksi https://resend.com/wallpapers) | Tidak ada lisensi eksplisit yang diperiksa → anggap hanya pemakaian pribadi; jangan redistribusi. |
| `3-discus.jpg` | `bg3.jpg` 7680×4320 | Discus — Raphael Fagundes untuk Resend | https://cdn.resend.com/wallpapers/2-a.jpg | Sama seperti di atas. |
| `4-cubus.jpg` | `bg4.jpg` 7680×4320 | Cubus — Raphael Fagundes untuk Resend | https://cdn.resend.com/wallpapers/6-a.jpg | Sama seperti di atas. |
| `5-black-dune.png` | `bg5.avif` 1400×933 | Black Dune (Unsplash; nama fotografer lihat halaman sumber) | https://unsplash.com/photos/a-black-and-white-photo-of-a-sand-dune-kz63JaDm9V4 | Unsplash License (lihat baris 1). |

Identifikasi file pengguna dilakukan secara visual terhadap daftar kandidat di `CLAUDE.md`. Black Ribbons diverifikasi numerik: versi unduhan vs `bg1.avif` RMSE 0,45% (gambar sama, resolusi lebih tinggi).

## Unduhan

- URL: `https://images.unsplash.com/photo-1678366633407-7f49da199a42?auto=format&fit=max&w=3840&q=90` (header `Accept: image/jpeg`), HTTPS, timeout, `--fail`, file sementara → rename.
- Hasil: `image/jpeg`, 3840×2160, 210 964 byte, SHA256 `1cfcec631bd4b21c2f2b2511a1a2dd208eb640198b2b2d959a55cfc302f81d6f`.
- Ketentuan lisensi tidak dapat dibaca langsung dari halaman (dirender JS); ringkasan di atas berdasarkan Unsplash License yang berlaku umum — periksa ulang halaman sebelum distribusi.

## File asli (SHA256)

| File | MIME | Dimensi | Byte | SHA256 |
| --- | --- | --- | --- | --- |
| bg1.avif | image/avif | 1400×788 | 14 625 | `f30b5a7eba4812361890b8df31c1131943945a04f6febf430538b3a577213b00` |
| bg2.jpg | image/jpeg | 7680×4320 | 8 580 217 | `44dd5c2d0a4d77c530c8c26ac7834aad9e0792e6479e510241885404d51c6d1b` |
| bg3.jpg | image/jpeg | 7680×4320 | 12 862 929 | `0c29756276eda471a42b4f7b8aab59aae5cfd96ef10a76a62ec84a637c22daec` |
| bg4.jpg | image/jpeg | 7680×4320 | 9 795 208 | `67b1963a132e86f5b2fb339fb2d1b1a1bacbc7e379bcbfe807cd7b5654616849` |
| bg5.avif | image/avif | 1400×933 | 156 095 | `117d97e1f1e90e9edfcf3abe55bb6f5d44bc9b2c2850f90106c1d0306519553b` |

## Pengolahan

- 7680×4320 → 3840×2160 (rasio 16:9 sama dengan panel, tanpa crop), JPEG q92, metadata dibuang. Tidak ada perubahan hue/kecerahan, tidak ada logo.
- AVIF dikonversi ke PNG lossless karena Omarchy 4.5 tidak membaca AVIF. Black Dune tetap 1400×933 (rasio 3:2): Omarchy menampilkannya *cover* sehingga di panel 1920×1080 sisi atas/bawah terpotong dan gambar diperbesar ±1,37× — tidak menambah detail. Ganti dengan sumber beresolusi lebih tinggi bila tersedia.
