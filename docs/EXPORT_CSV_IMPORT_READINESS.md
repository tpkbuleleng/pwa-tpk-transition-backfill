# Export CSV & Import Readiness

Paket 6 membuat jalur export dari Google Sheet staging ke CSV yang siap dimuat ke Supabase staging.

## Alur

PWA GitHub Pages → GASProvider → TPK Backfill Router → BACKFILL_TPK_* → CSV → Supabase staging.

## Action backend

### getExportReadiness

Memeriksa:

- route workbook kecamatan;
- keberadaan sheet target;
- kesesuaian header dengan kontrak Paket 2;
- jumlah data row;
- jumlah baris kosong yang diabaikan;
- target tabel Supabase staging.

### exportCsv

Melakukan:

- membaca sheet target;
- validasi header;
- membuat `export_batch_id`;
- membuat `import_batch_id`;
- mengisi `import_batch_id` pada CSV export;
- mengabaikan baris kosong;
- membuat checksum SHA-256;
- membuat file CSV di Google Drive jika diminta;
- mencatat hasil ke `export_log`.

## Target export

- `sasaran` → `staging_sasaran` → `staging_sasaran_import`
- `pendampingan` Januari → `staging_pendampingan_jan` → `staging_pendampingan_import`
- `pendampingan` Februari → `staging_pendampingan_feb` → `staging_pendampingan_import`
- `pendampingan` Maret → `staging_pendampingan_mar` → `staging_pendampingan_import`
- `pendampingan` April → `staging_pendampingan_apr` → `staging_pendampingan_import`
- `pendampingan` Mei → `staging_pendampingan_mei` → `staging_pendampingan_import`
- `pendampingan` Juni → `staging_pendampingan_jun` → `staging_pendampingan_import`

## Batasan Paket 6

Paket 6 belum melakukan upload ke Supabase. Paket ini hanya menyiapkan CSV dan metadata import.
