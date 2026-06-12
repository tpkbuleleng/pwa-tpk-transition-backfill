# Paket 7-A — Supabase Staging Schema & Import Contract

Paket 7-A adalah tahap awal transisi dari BACKFILL Google Sheet menuju Supabase. Tujuannya bukan membuat PWA production penuh, melainkan menyiapkan tempat aman untuk CSV hasil Paket 6.

## Keputusan arsitektur

1. Data dari Google Sheet tidak langsung masuk production.
2. CSV masuk ke tabel staging Supabase.
3. Validasi SQL dilakukan setelah import.
4. Error dicatat ke `import_error`.
5. Promote ke tabel production ditunda ke Paket 7-B/7-C.

## Tabel staging

- `staging_sasaran_import`: menerima CSV sasaran.
- `staging_pendampingan_import`: menerima CSV pendampingan.
- `import_batch`: registry batch CSV.
- `import_error`: hasil validasi per row/field.

## Kenapa kolom staging memakai text?

CSV backfill bisa mengandung variasi format dari Google Sheet. Jika kolom staging langsung dibuat strict type, import dapat gagal sebelum error bisa direkam. Dengan kolom `text`, data diterima dahulu, kemudian divalidasi secara terkontrol oleh SQL function.

## Validasi awal Paket 7-A

Function `validate_backfill_import_batch(import_batch_id)` memeriksa:

- field wajib kosong;
- NIK sasaran harus 16 digit jika terisi;
- duplikasi `sasaran_unique_key`;
- duplikasi `pendampingan_unique_key`;
- kesesuaian `tanggal_pendampingan` dengan `periode_bulan` dan `tahun_laporan`.

## Batas yang belum dikerjakan

- Belum ada Supabase Auth.
- Belum ada SupabaseProvider aktif di frontend.
- Belum ada RLS operasional berdasarkan role kader/tim.
- Belum ada promote ke tabel production.
- Belum ada read model production.

## Kriteria PASS

Paket 7-A PASS jika:

1. tiga file SQL berhasil dijalankan;
2. empat tabel staging terbentuk;
3. dua view summary terbentuk;
4. function `validate_backfill_import_batch()` terbentuk;
5. CSV sasaran hasil Paket 6 bisa diimport ke `staging_sasaran_import`;
6. CSV pendampingan hasil Paket 6 bisa diimport ke `staging_pendampingan_import`;
7. function validasi menghasilkan summary valid/error;
8. `import_error` mencatat error jika data sengaja dibuat tidak valid.
