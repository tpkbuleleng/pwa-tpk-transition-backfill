# Supabase Paket 7-C — Production Base Tables & Controlled Promote

Paket 7-C membuat tabel production base di project `tpk-backfill-staging` dan fungsi controlled promote dari tabel dry-run Paket 7-B.

## Jalankan SQL berurutan

1. `supabase/migrations/20260614_07_backfill_production_base_schema.sql`
2. `supabase/migrations/20260614_08_backfill_controlled_promote_functions.sql`
3. `supabase/migrations/20260614_09_backfill_production_promote_views.sql`

## Alur uji minimal

1. Pastikan batch sasaran sudah ada di `dryrun_sasaran`.
2. Promote sasaran ke production base.
3. Pastikan batch pendampingan sudah ada di `dryrun_pendampingan` dan parent sasaran sudah ada di `sasaran`.
4. Promote pendampingan ke production base.
5. Cek `production_promote_batch`, `production_promote_error`, `sasaran`, dan `pendampingan`.

## Catatan keamanan

RLS diaktifkan tanpa policy publik. Pada Paket 7-C, tabel production base belum dimaksudkan untuk akses frontend `anon` atau `authenticated`.
