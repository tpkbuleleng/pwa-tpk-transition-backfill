-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-C — Production Base Tables & Controlled Promote
-- File 03: Production promote readiness views
-- Version: p7c-20260614-r1
-- ============================================================

create or replace view public.v_production_promote_batch_summary
with (security_invoker = true)
as
select
  b.production_promote_batch_id,
  b.created_at,
  b.import_batch_id,
  b.record_type,
  b.status,
  b.sasaran_rows,
  b.pendampingan_rows,
  b.error_rows,
  b.promoted_at,
  b.promoted_by,
  b.notes
from public.production_promote_batch b;

create or replace view public.v_production_promote_error_summary
with (security_invoker = true)
as
select
  e.production_promote_error_id,
  e.created_at,
  e.production_promote_batch_id,
  e.import_batch_id,
  e.record_type,
  e.dryrun_row_id,
  e.client_mutation_id,
  e.unique_key,
  e.error_code,
  e.error_message,
  e.field_name,
  e.field_value,
  e.resolved_at,
  e.resolved_by,
  e.resolution_note
from public.production_promote_error e;

create or replace view public.v_production_backfill_record_summary
with (security_invoker = true)
as
select
  'sasaran'::text as record_type,
  count(*)::bigint as total_rows,
  count(*) filter (where needs_review is true)::bigint as needs_review_rows,
  count(*) filter (where is_deleted is true)::bigint as deleted_rows,
  min(created_at) as first_created_at,
  max(created_at) as last_created_at
from public.sasaran
union all
select
  'pendampingan'::text as record_type,
  count(*)::bigint as total_rows,
  count(*) filter (where needs_review is true)::bigint as needs_review_rows,
  count(*) filter (where is_deleted is true)::bigint as deleted_rows,
  min(created_at) as first_created_at,
  max(created_at) as last_created_at
from public.pendampingan;

revoke all on table public.v_production_promote_batch_summary from anon, authenticated;
revoke all on table public.v_production_promote_error_summary from anon, authenticated;
revoke all on table public.v_production_backfill_record_summary from anon, authenticated;
