# Paket 5 — Apps Script Provider & Sheet Staging

Paket 5 mengaktifkan jalur BACKFILL dari frontend GitHub Pages menuju Apps Script dan Google Sheet staging.

## Action backend yang aktif

- `healthCheck`
- `setupStagingSheets`
- `submitRegistrasi`
- `submitPendampingan`
- `getSubmitStatus`

## Sheet yang dibuat

- `staging_sasaran`
- `staging_pendampingan_jan`
- `staging_pendampingan_feb`
- `staging_pendampingan_mar`
- `staging_pendampingan_apr`
- `staging_pendampingan_mei`
- `staging_pendampingan_jun`
- `import_error`
- `export_log`

## Aturan submit sasaran

Data dikirim ke `staging_sasaran` jika:

- `client_mutation_id` valid dengan prefix `reg_`
- field wajib dasar lengkap
- NIK kosong atau valid 16 digit
- No. KK kosong atau valid 16 digit
- `tanggal_lahir` format `YYYY-MM-DD`
- `sasaran_unique_key` belum pernah ada di `staging_sasaran`
- `client_mutation_id` belum pernah diproses

## Aturan submit pendampingan

Data dikirim ke sheet bulan sesuai `periode_bulan`:

- 1 -> `staging_pendampingan_jan`
- 2 -> `staging_pendampingan_feb`
- 3 -> `staging_pendampingan_mar`
- 4 -> `staging_pendampingan_apr`
- 5 -> `staging_pendampingan_mei`
- 6 -> `staging_pendampingan_jun`

Data diterima jika:

- `client_mutation_id` valid dengan prefix `pdg_`
- `periode_bulan` hanya 1 sampai 6
- `tahun_laporan` = 2026
- `tanggal_pendampingan` sesuai bulan dan tahun laporan
- `id_sasaran` atau `id_sasaran_temp` tersedia
- `pendampingan_unique_key` belum pernah ada di sheet bulan terkait
- `client_mutation_id` belum pernah diproses
- jumlah laporan kader pada bulan tersebut belum mencapai 10 baris

## Idempotency

Backend menolak duplikasi berdasarkan:

- `client_mutation_id`
- `sasaran_unique_key` untuk sasaran
- `pendampingan_unique_key` untuk pendampingan

## Catatan

Paket 5 belum melakukan export CSV, belum import ke Supabase staging, dan belum mengaktifkan service worker.
