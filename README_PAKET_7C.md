# Paket 7-C — Production Base Tables & Controlled Promote

Status: update package.

## Tujuan

Paket ini membuat tabel production base awal dan fungsi controlled promote dari hasil dry-run Paket 7-B.

## File utama

```txt
index.html
src/main.js
src/config/appConfig.js
src/supabase/productionPromoteContract.js
supabase/migrations/20260614_07_backfill_production_base_schema.sql
supabase/migrations/20260614_08_backfill_controlled_promote_functions.sql
supabase/migrations/20260614_09_backfill_production_promote_views.sql
supabase/examples/PAKET_7C_TEST_QUERIES.sql
docs/SUPABASE_PRODUCTION_BASE_TABLES_CONTROLLED_PROMOTE.md
tests/PAKET_7C_TEST_NOTES.md
```

## Cara uji

1. Upload isi ZIP ke GitHub.
2. Jalankan SQL migration 07–09 di Supabase `tpk-backfill-staging`.
3. Klik tombol frontend `Cek Supabase Production Promote Contract`.
4. Jalankan query promote sasaran.
5. Jalankan query promote pendampingan.
6. Cek tabel `sasaran`, `pendampingan`, `production_promote_batch`, dan `production_promote_error`.

## Batasan

Paket ini belum mengaktifkan SupabaseProvider frontend dan belum membuat RLS operasional untuk user/kader.
