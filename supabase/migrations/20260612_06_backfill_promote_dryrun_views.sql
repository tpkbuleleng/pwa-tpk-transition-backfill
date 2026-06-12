-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-B — Supabase Import Validation & Promote Dry Run
-- File 03: Dry-run promote summary views and security hardening
-- Version: p7b-20260612-r1
-- ============================================================

create or replace view public.v_backfill_promote_batch_summary
with (security_invoker = true)
as
select
  pb.promote_batch_id,
  pb.created_at,
  pb.import_batch_id,
  pb.record_type,
  pb.dry_run,
  pb.status,
  pb.sasaran_rows,
  pb.pendampingan_rows,
  pb.error_rows,
  pb.promoted_at,
  pb.notes,
  ib.source_mode,
  ib.kode_kecamatan,
  ib.nama_kecamatan,
  ib.file_name,
  ib.csv_header_version,
  ib.total_rows as import_total_rows,
  ib.valid_rows as import_valid_rows,
  ib.error_rows as import_error_rows
from public.promote_batch pb
left join public.import_batch ib
  on ib.import_batch_id = pb.import_batch_id;

create or replace view public.v_backfill_promote_error_summary
with (security_invoker = true)
as
select
  promote_error_id,
  created_at,
  promote_batch_id,
  import_batch_id,
  record_type,
  staging_row_id,
  client_mutation_id,
  unique_key,
  error_level,
  error_code,
  error_message,
  field_name,
  field_value,
  resolved_at,
  resolved_by,
  resolution_note
from public.promote_error;

create or replace view public.v_backfill_dryrun_relation_summary
with (security_invoker = true)
as
select
  dp.dryrun_pendampingan_id,
  dp.promote_batch_id,
  dp.import_batch_id,
  dp.client_mutation_id,
  dp.pendampingan_unique_key,
  dp.sasaran_unique_key,
  dp.nama_sasaran,
  dp.jenis_sasaran,
  dp.periode_bulan,
  dp.tahun_laporan,
  dp.parent_sasaran_dryrun_id,
  dp.parent_resolution_status,
  ds.nama_sasaran as parent_nama_sasaran,
  ds.jenis_sasaran as parent_jenis_sasaran
from public.dryrun_pendampingan dp
left join public.dryrun_sasaran ds
  on ds.dryrun_sasaran_id = dp.parent_sasaran_dryrun_id;

revoke all on table public.v_backfill_promote_batch_summary from anon, authenticated;
revoke all on table public.v_backfill_promote_error_summary from anon, authenticated;
revoke all on table public.v_backfill_dryrun_relation_summary from anon, authenticated;

-- Keep staging/dry-run objects closed to browser clients.
revoke all on table public.promote_batch from anon, authenticated;
revoke all on table public.promote_error from anon, authenticated;
revoke all on table public.dryrun_sasaran from anon, authenticated;
revoke all on table public.dryrun_pendampingan from anon, authenticated;
