-- Paket 7-A — Supabase Import Readiness Views
-- Version: supabase-staging-p7a-20260612-r1

create or replace view public.v_backfill_import_batch_summary as
select
  b.import_batch_id,
  b.source_mode,
  b.kode_kecamatan,
  b.nama_kecamatan,
  b.record_type,
  b.periode_bulan,
  b.tahun_laporan,
  b.file_name,
  b.csv_header_version,
  b.status as batch_status,
  coalesce(s.sasaran_rows, 0) as sasaran_rows,
  coalesce(p.pendampingan_rows, 0) as pendampingan_rows,
  coalesce(e.error_rows, 0) as error_rows,
  coalesce(s.valid_sasaran_rows, 0) as valid_sasaran_rows,
  coalesce(p.valid_pendampingan_rows, 0) as valid_pendampingan_rows,
  b.imported_at,
  b.notes
from public.import_batch b
left join (
  select
    import_batch_id,
    count(*) as sasaran_rows,
    count(*) filter (where validation_status = 'valid') as valid_sasaran_rows
  from public.staging_sasaran_import
  group by import_batch_id
) s on s.import_batch_id = b.import_batch_id
left join (
  select
    import_batch_id,
    count(*) as pendampingan_rows,
    count(*) filter (where validation_status = 'valid') as valid_pendampingan_rows
  from public.staging_pendampingan_import
  group by import_batch_id
) p on p.import_batch_id = b.import_batch_id
left join (
  select import_batch_id, count(*) as error_rows
  from public.import_error
  group by import_batch_id
) e on e.import_batch_id = b.import_batch_id;

create or replace view public.v_backfill_import_error_summary as
select
  import_batch_id,
  record_type,
  error_level,
  error_code,
  field_name,
  count(*) as total_errors
from public.import_error
group by import_batch_id, record_type, error_level, error_code, field_name;

comment on view public.v_backfill_import_batch_summary is 'Paket 7-A: summary of imported BACKFILL staging batches before production promote.';
comment on view public.v_backfill_import_error_summary is 'Paket 7-A: error summary for imported BACKFILL staging batches.';
