# Paket 7-B — Test Notes

## Prasyarat

- Paket 7-A dan 7-A-R1 sudah PASS.
- CSV sasaran sudah diimport ke `staging_sasaran_import`.
- CSV pendampingan sudah diimport ke `staging_pendampingan_import`.
- `validate_backfill_import_batch()` untuk masing-masing batch menghasilkan `error_rows = 0`.

## Uji 1 — Contract frontend

Di GitHub Pages klik:

```txt
Cek Supabase Promote Dry Run Contract
```

Harus menampilkan paket, SQL files, dan keputusan dry-run.

## Uji 2 — Jalankan SQL schema

Jalankan berurutan:

```txt
20260612_04_backfill_promote_dryrun_schema.sql
20260612_05_backfill_promote_dryrun_functions.sql
20260612_06_backfill_promote_dryrun_views.sql
```

Pastikan tabel muncul:

```txt
promote_batch
promote_error
dryrun_sasaran
dryrun_pendampingan
```

## Uji 3 — Promote sasaran dry run

```sql
select public.promote_backfill_batch_dry_run('IMPB_BATCH_SASARAN', 'sasaran', false);
```

Ekspektasi:

```json
{"ok":true,"status":"dry_run_valid","sasaran_rows":2,"error_rows":0}
```

## Uji 4 — Promote pendampingan dry run

```sql
select public.promote_backfill_batch_dry_run('IMPB_BATCH_PENDAMPINGAN', 'pendampingan', false);
```

Ekspektasi:

```json
{"ok":true,"status":"dry_run_valid","pendampingan_rows":1,"error_rows":0}
```

Jika gagal dengan `DRYRUN_PARENT_SASARAN_NOT_FOUND`, artinya `sasaran_unique_key` pendampingan belum ada di `dryrun_sasaran` atau `staging_sasaran_import` valid. Perbaiki data sumber atau registrasikan sasaran terkait terlebih dahulu.

## Uji 5 — Cek summary

```sql
select * from public.v_backfill_promote_batch_summary order by created_at desc;
select * from public.v_backfill_dryrun_relation_summary order by dryrun_pendampingan_id desc;
select * from public.promote_error order by created_at desc;
```

## Uji 6 — Security Advisor

Harapan:

```txt
Errors   : 0
Warnings : 0
```

Info `RLS Enabled No Policy` masih dapat diterima untuk tabel staging/dry-run karena memang tertutup dari frontend.
