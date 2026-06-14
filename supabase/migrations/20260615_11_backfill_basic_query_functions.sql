-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-D — Production Read Model & Basic Query Layer
-- File 02: Basic query functions
-- Version: p7d-20260615-r1
-- ============================================================

create or replace function public.query_sasaran_lite(
  p_id_kecamatan text default null,
  p_id_tim text default null,
  p_jenis_sasaran text default null,
  p_status_sasaran text default 'AKTIF',
  p_search text default null,
  p_limit integer default 50,
  p_offset integer default 0
)
returns setof public.v_sasaran_lite
language sql
stable
security invoker
set search_path = public
as $$
  select *
  from public.v_sasaran_lite v
  where v.is_deleted = false
    and (p_id_kecamatan is null or p_id_kecamatan = '' or v.id_kecamatan = p_id_kecamatan or v.kode_kecamatan = p_id_kecamatan)
    and (p_id_tim is null or p_id_tim = '' or v.id_tim = p_id_tim)
    and (p_jenis_sasaran is null or p_jenis_sasaran = '' or v.jenis_sasaran = upper(p_jenis_sasaran))
    and (p_status_sasaran is null or p_status_sasaran = '' or v.status_sasaran = upper(p_status_sasaran))
    and (
      p_search is null or p_search = ''
      or lower(v.nama_sasaran) like '%' || lower(p_search) || '%'
      or v.nik like '%' || p_search || '%'
      or lower(v.sasaran_unique_key) like '%' || lower(p_search) || '%'
    )
  order by v.created_at desc, v.nama_sasaran asc
  limit least(greatest(coalesce(p_limit, 50), 1), 200)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

create or replace function public.query_pendampingan_lite(
  p_id_kecamatan text default null,
  p_id_tim text default null,
  p_tahun_laporan integer default null,
  p_periode_bulan integer default null,
  p_search text default null,
  p_limit integer default 50,
  p_offset integer default 0
)
returns setof public.v_pendampingan_lite
language sql
stable
security invoker
set search_path = public
as $$
  select *
  from public.v_pendampingan_lite v
  where v.is_deleted = false
    and (p_id_kecamatan is null or p_id_kecamatan = '' or v.id_kecamatan = p_id_kecamatan or v.kode_kecamatan = p_id_kecamatan)
    and (p_id_tim is null or p_id_tim = '' or v.id_tim = p_id_tim)
    and (p_tahun_laporan is null or v.tahun_laporan = p_tahun_laporan)
    and (p_periode_bulan is null or v.periode_bulan = p_periode_bulan)
    and (
      p_search is null or p_search = ''
      or lower(v.nama_sasaran) like '%' || lower(p_search) || '%'
      or lower(v.parent_nama_sasaran) like '%' || lower(p_search) || '%'
      or v.nik like '%' || p_search || '%'
      or lower(v.pendampingan_unique_key) like '%' || lower(p_search) || '%'
      or lower(v.sasaran_unique_key) like '%' || lower(p_search) || '%'
    )
  order by v.tanggal_pendampingan desc nulls last, v.created_at desc
  limit least(greatest(coalesce(p_limit, 50), 1), 200)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

create or replace function public.get_production_basic_summary(
  p_id_kecamatan text default null,
  p_id_tim text default null
)
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_sasaran_total bigint;
  v_pendampingan_total bigint;
  v_needs_review_total bigint;
  v_summary_tim jsonb;
  v_summary_kecamatan jsonb;
begin
  select count(*) into v_sasaran_total
  from public.sasaran s
  where s.is_deleted = false
    and (p_id_kecamatan is null or p_id_kecamatan = '' or s.id_kecamatan = p_id_kecamatan or s.kode_kecamatan = p_id_kecamatan)
    and (p_id_tim is null or p_id_tim = '' or s.id_tim = p_id_tim);

  select count(*) into v_pendampingan_total
  from public.pendampingan p
  where p.is_deleted = false
    and (p_id_kecamatan is null or p_id_kecamatan = '' or p.id_kecamatan = p_id_kecamatan or p.kode_kecamatan = p_id_kecamatan)
    and (p_id_tim is null or p_id_tim = '' or p.id_tim = p_id_tim);

  select count(*) into v_needs_review_total
  from public.sasaran s
  where s.is_deleted = false
    and s.needs_review = true
    and (p_id_kecamatan is null or p_id_kecamatan = '' or s.id_kecamatan = p_id_kecamatan or s.kode_kecamatan = p_id_kecamatan)
    and (p_id_tim is null or p_id_tim = '' or s.id_tim = p_id_tim);

  select coalesce(jsonb_agg(to_jsonb(t) order by t.id_tim), '[]'::jsonb)
  into v_summary_tim
  from (
    select *
    from public.v_summary_tim_basic v
    where (p_id_kecamatan is null or p_id_kecamatan = '' or v.id_kecamatan = p_id_kecamatan or v.kode_kecamatan = p_id_kecamatan)
      and (p_id_tim is null or p_id_tim = '' or v.id_tim = p_id_tim)
  ) t;

  select coalesce(jsonb_agg(to_jsonb(k) order by k.id_kecamatan), '[]'::jsonb)
  into v_summary_kecamatan
  from (
    select *
    from public.v_summary_kecamatan_basic v
    where (p_id_kecamatan is null or p_id_kecamatan = '' or v.id_kecamatan = p_id_kecamatan or v.kode_kecamatan = p_id_kecamatan)
  ) k;

  return jsonb_build_object(
    'ok', true,
    'status', 'success',
    'package', 'Paket 7-D — Production Read Model & Basic Query Layer',
    'scope', jsonb_build_object(
      'id_kecamatan', p_id_kecamatan,
      'id_tim', p_id_tim
    ),
    'totals', jsonb_build_object(
      'sasaran_total', coalesce(v_sasaran_total, 0),
      'pendampingan_total', coalesce(v_pendampingan_total, 0),
      'needs_review_total', coalesce(v_needs_review_total, 0)
    ),
    'summary_tim', v_summary_tim,
    'summary_kecamatan', v_summary_kecamatan
  );
end;
$$;

create or replace function public.check_production_read_model_health()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_sasaran_count bigint;
  v_pendampingan_count bigint;
  v_sasaran_lite_count bigint;
  v_pendampingan_lite_count bigint;
begin
  select count(*) into v_sasaran_count from public.sasaran where is_deleted = false;
  select count(*) into v_pendampingan_count from public.pendampingan where is_deleted = false;
  select count(*) into v_sasaran_lite_count from public.v_sasaran_lite where is_deleted = false;
  select count(*) into v_pendampingan_lite_count from public.v_pendampingan_lite where is_deleted = false;

  return jsonb_build_object(
    'ok', true,
    'status', 'healthy',
    'package', 'Paket 7-D — Production Read Model & Basic Query Layer',
    'base_tables', jsonb_build_object(
      'sasaran', v_sasaran_count,
      'pendampingan', v_pendampingan_count
    ),
    'read_models', jsonb_build_object(
      'v_sasaran_lite', v_sasaran_lite_count,
      'v_pendampingan_lite', v_pendampingan_lite_count
    ),
    'checked_at', now()
  );
end;
$$;
