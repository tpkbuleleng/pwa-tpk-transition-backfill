# Paket 7-A — Supabase Staging Schema & Import Contract

Paket ini menyiapkan Supabase staging untuk menerima CSV dari Paket 6.

## Cara pakai

1. Upload isi ZIP ke root repository GitHub.
2. Commit dengan pesan: `Paket 7-A - Supabase Staging Schema and Import Contract`.
3. Buka Supabase project staging.
4. Jalankan SQL berikut di SQL Editor secara berurutan:
   - `supabase/migrations/20260612_01_backfill_staging_schema.sql`
   - `supabase/migrations/20260612_02_backfill_validation_functions.sql`
   - `supabase/migrations/20260612_03_backfill_import_readiness_views.sql`
5. Import CSV hasil Paket 6 ke tabel staging.
6. Jalankan `select public.validate_backfill_import_batch('IMPB_...');`.

## File penting

- `supabase/migrations/` — SQL schema dan function.
- `supabase/README_SUPABASE_PAKET_7A.md` — petunjuk eksekusi SQL.
- `docs/SUPABASE_STAGING_SCHEMA_IMPORT_CONTRACT.md` — dokumen kontrak.
- `tests/PAKET_7A_TEST_NOTES.md` — checklist uji.

## Catatan

Paket ini belum mengaktifkan SupabaseProvider frontend dan belum menyentuh tabel production.
