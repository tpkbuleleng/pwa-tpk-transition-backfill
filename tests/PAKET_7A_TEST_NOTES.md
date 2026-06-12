# Paket 7-A — Test Notes

## Uji 1 — SQL schema

Jalankan file 01, 02, 03 di Supabase SQL Editor.

Expected:

- `staging_sasaran_import` ada.
- `staging_pendampingan_import` ada.
- `import_batch` ada.
- `import_error` ada.
- `validate_backfill_import_batch(text)` ada.
- `v_backfill_import_batch_summary` ada.

## Uji 2 — Import CSV sasaran

Import file CSV sasaran hasil Paket 6 ke `staging_sasaran_import`.

Expected:

- jumlah row sama dengan CSV.
- `import_batch_id` terisi dari CSV.

## Uji 3 — Import CSV pendampingan

Import file CSV pendampingan Januari hasil Paket 6 ke `staging_pendampingan_import`.

Expected:

- jumlah row sama dengan CSV.
- `periode_bulan = 1`.
- `tahun_laporan = 2026`.

## Uji 4 — Validasi batch

```sql
select public.validate_backfill_import_batch('IMPB_...');
```

Expected untuk data bersih:

- `ok = true`
- `error_rows = 0`

Expected untuk data sengaja salah:

- `ok = false`
- `import_error` berisi baris error.
