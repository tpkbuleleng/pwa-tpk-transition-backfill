# Paket 7-B — Supabase Import Validation & Promote Dry Run

Versi: `tpk-transition-p7b-20260612-r1`

## Tujuan

Paket 7-B menambahkan tahap dry-run promote di Supabase staging. Data valid dari `staging_sasaran_import` dan `staging_pendampingan_import` dipromosikan ke tabel sementara:

- `dryrun_sasaran`
- `dryrun_pendampingan`

Paket ini tidak menyentuh tabel production final.

## File yang ditambahkan/diubah

```txt
index.html
src/main.js
src/config/appConfig.js
src/supabase/promoteDryRunContract.js
supabase/migrations/20260612_04_backfill_promote_dryrun_schema.sql
supabase/migrations/20260612_05_backfill_promote_dryrun_functions.sql
supabase/migrations/20260612_06_backfill_promote_dryrun_views.sql
docs/SUPABASE_IMPORT_VALIDATION_PROMOTE_DRY_RUN.md
tests/PAKET_7B_TEST_NOTES.md
README_PAKET_7B.md
VERSION.txt
```

## Cara pakai

1. Upload isi ZIP ke root repository GitHub.
2. Commit:

```txt
Paket 7-B - Supabase Import Validation and Promote Dry Run
```

3. Di Supabase project `tpk-backfill-staging`, jalankan SQL migration 04, 05, 06 secara berurutan.
4. Pastikan batch sasaran dan pendampingan sudah valid dari Paket 7-A.
5. Jalankan promote dry-run.

## SQL utama

```sql
select public.promote_backfill_batch_dry_run('IMPB_BATCH_SASARAN', 'sasaran', false);
```

```sql
select public.promote_backfill_batch_dry_run('IMPB_BATCH_PENDAMPINGAN', 'pendampingan', false);
```

## Jika perlu purge hasil dry-run

```sql
select public.purge_backfill_promote_dry_run(null, 'IMPB_BATCH_ID');
```

## Status PASS

Paket 7-B PASS jika:

- SQL migration berjalan tanpa error;
- `promote_batch`, `promote_error`, `dryrun_sasaran`, `dryrun_pendampingan` terbentuk;
- batch sasaran berhasil masuk `dryrun_sasaran`;
- batch pendampingan berhasil masuk `dryrun_pendampingan`;
- `promote_error` kosong untuk batch valid;
- Security Advisor tidak menampilkan error/warning kritikal.
