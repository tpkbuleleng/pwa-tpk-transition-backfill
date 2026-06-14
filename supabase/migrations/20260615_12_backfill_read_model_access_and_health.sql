-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-D — Production Read Model & Basic Query Layer
-- File 03: Read model access lock and health view
-- Version: p7d-20260615-r1
-- ============================================================

create or replace view public.v_production_read_model_health
with (security_invoker = true)
as
select
  now() as checked_at,
  (select count(*) from public.sasaran where is_deleted = false) as sasaran_rows,
  (select count(*) from public.pendampingan where is_deleted = false) as pendampingan_rows,
  (select count(*) from public.v_sasaran_lite where is_deleted = false) as sasaran_lite_rows,
  (select count(*) from public.v_pendampingan_lite where is_deleted = false) as pendampingan_lite_rows,
  (select count(*) from public.v_summary_tim_basic) as summary_tim_rows,
  (select count(*) from public.v_summary_kecamatan_basic) as summary_kecamatan_rows;

-- Keep read models closed to anon/authenticated until Paket Auth/RLS role model.
revoke all on table public.v_sasaran_lite from anon, authenticated;
revoke all on table public.v_pendampingan_lite from anon, authenticated;
revoke all on table public.v_summary_tim_basic from anon, authenticated;
revoke all on table public.v_summary_kecamatan_basic from anon, authenticated;
revoke all on table public.v_production_read_model_health from anon, authenticated;

revoke execute on function public.query_sasaran_lite(text, text, text, text, text, integer, integer) from public;
revoke execute on function public.query_sasaran_lite(text, text, text, text, text, integer, integer) from anon;
revoke execute on function public.query_sasaran_lite(text, text, text, text, text, integer, integer) from authenticated;

revoke execute on function public.query_pendampingan_lite(text, text, integer, integer, text, integer, integer) from public;
revoke execute on function public.query_pendampingan_lite(text, text, integer, integer, text, integer, integer) from anon;
revoke execute on function public.query_pendampingan_lite(text, text, integer, integer, text, integer, integer) from authenticated;

revoke execute on function public.get_production_basic_summary(text, text) from public;
revoke execute on function public.get_production_basic_summary(text, text) from anon;
revoke execute on function public.get_production_basic_summary(text, text) from authenticated;

revoke execute on function public.check_production_read_model_health() from public;
revoke execute on function public.check_production_read_model_health() from anon;
revoke execute on function public.check_production_read_model_health() from authenticated;

-- Allow database owner / service role for admin-side SQL and future secure RPC gateway.
grant select on table public.v_sasaran_lite to postgres, service_role;
grant select on table public.v_pendampingan_lite to postgres, service_role;
grant select on table public.v_summary_tim_basic to postgres, service_role;
grant select on table public.v_summary_kecamatan_basic to postgres, service_role;
grant select on table public.v_production_read_model_health to postgres, service_role;

grant execute on function public.query_sasaran_lite(text, text, text, text, text, integer, integer) to postgres, service_role;
grant execute on function public.query_pendampingan_lite(text, text, integer, integer, text, integer, integer) to postgres, service_role;
grant execute on function public.get_production_basic_summary(text, text) to postgres, service_role;
grant execute on function public.check_production_read_model_health() to postgres, service_role;
