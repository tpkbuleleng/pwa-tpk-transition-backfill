# Paket 7-B — Supabase Import Validation & Promote Dry Run

## Tujuan

Paket 7-B menambahkan tahap **promote dry run** setelah CSV berhasil masuk ke Supabase staging dan `validate_backfill_import_batch()` menghasilkan `error_rows = 0`.

Paket ini **belum** membuat production final sebagai kanal resmi operasional. Data hanya dipromosikan ke tabel dry-run:

- `dryrun_sasaran`
- `dryrun_pendampingan`

Tujuannya adalah memastikan data valid dari staging dapat dipetakan ke struktur production-like tanpa langsung menyentuh tabel production final.

## Alur

```txt
CSV Google Sheet
  ↓
Supabase staging_sasaran_import / staging_pendampingan_import
  ↓
validate_backfill_import_batch(import_batch_id)
  ↓
Jika valid → promote_backfill_batch_dry_run(import_batch_id)
  ↓
dryrun_sasaran / dryrun_pendampingan
  ↓
review relasi, duplikasi, dan readiness production
```

## SQL yang dijalankan

Jalankan berurutan:

```txt
supabase/migrations/20260612_04_backfill_promote_dryrun_schema.sql
supabase/migrations/20260612_05_backfill_promote_dryrun_functions.sql
supabase/migrations/20260612_06_backfill_promote_dryrun_views.sql
```

## Fungsi utama

### Promote sasaran dry run

```sql
select public.promote_backfill_batch_dry_run(
  'IMPB_BATCH_SASARAN',
  'sasaran',
  false
);
```

### Promote pendampingan dry run

```sql
select public.promote_backfill_batch_dry_run(
  'IMPB_BATCH_PENDAMPINGAN',
  'pendampingan',
  false
);
```

### Purge hasil dry run

```sql
select public.purge_backfill_promote_dry_run(
  null,
  'IMPB_BATCH_ID'
);
```

## Validasi yang dilakukan

1. Batch import harus ada.
2. Batch import tidak boleh memiliki `import_error`.
3. Row staging harus berstatus `valid`.
4. `sasaran_unique_key` tidak boleh duplikat dalam batch.
5. `sasaran_unique_key` tidak boleh sudah ada di `dryrun_sasaran` dari batch lain.
6. `pendampingan_unique_key` tidak boleh duplikat dalam batch.
7. `pendampingan_unique_key` tidak boleh sudah ada di `dryrun_pendampingan` dari batch lain.
8. Pendampingan harus memiliki `sasaran_unique_key` yang ditemukan di `dryrun_sasaran` atau `staging_sasaran_import` valid.

## Keputusan keamanan

- Tabel dry-run memakai RLS.
- Tidak ada policy publik untuk `anon` atau `authenticated`.
- Fungsi dry-run tidak diberikan ke `anon` atau `authenticated`.
- Fungsi hanya untuk SQL Editor/admin/service role.

## Batas Paket 7-B

Belum ada:

- production final tables resmi;
- SupabaseProvider frontend aktif;
- Supabase Auth;
- RLS operasional kader/tim;
- submit langsung ke Supabase;
- cut-over dari BACKFILL ke PRODUCTION.
