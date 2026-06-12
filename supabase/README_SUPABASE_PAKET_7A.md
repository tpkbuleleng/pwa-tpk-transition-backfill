# Paket 7-A — Supabase Staging Schema & Import Contract

Paket ini menyiapkan sisi Supabase staging untuk menerima CSV hasil Paket 6.

## Urutan eksekusi SQL

Jalankan file SQL berikut di Supabase SQL Editor secara berurutan:

1. `supabase/migrations/20260612_01_backfill_staging_schema.sql`
2. `supabase/migrations/20260612_02_backfill_validation_functions.sql`
3. `supabase/migrations/20260612_03_backfill_import_readiness_views.sql`

## Tabel yang dibuat

- `public.staging_sasaran_import`
- `public.staging_pendampingan_import`
- `public.import_batch`
- `public.import_error`

## Prinsip Paket 7-A

- CSV masuk ke staging dahulu.
- Tabel production belum disentuh.
- Kolom CSV dibuat `text` agar import tidak gagal prematur.
- Validasi dilakukan setelah CSV masuk dengan `validate_backfill_import_batch(import_batch_id)`.
- RLS diaktifkan dan tidak ada policy publik untuk menjaga staging tidak terbuka dari frontend.

## Setelah CSV diimport

Jalankan:

```sql
select public.validate_backfill_import_batch('IMPB_...');
```

Lalu cek:

```sql
select * from public.v_backfill_import_batch_summary order by imported_at desc nulls last;
select * from public.v_backfill_import_error_summary;
select * from public.import_error where import_batch_id = 'IMPB_...';
```
