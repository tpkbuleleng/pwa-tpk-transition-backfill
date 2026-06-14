-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E — Production Master Reference & Scope Foundation
-- File 03: Scope-enriched read models and health functions
-- Version: p7e-20260615-r1
-- ============================================================

-- ============================================================
-- Master reference lite views
-- ============================================================
create or replace view public.v_master_reference_health
with (security_invoker = true)
as
select
  now() as checked_at,
  (select count(*) from public.master_kecamatan where is_active = true) as master_kecamatan_rows,
  (select count(*) from public.master_tim where is_active = true) as master_tim_rows,
  (select count(*) from public.master_kader where is_active = true) as master_kader_rows,
  (select count(*) from public.master_wilayah where is_active = true) as master_wilayah_rows,
  (select count(*) from public.scope_profile where is_active = true) as scope_profile_rows,
  (
    select count(*)
    from public.sasaran s
    left join public.master_tim mt on mt.id_tim = s.id_tim and mt.is_active = true
    where s.is_deleted = false and nullif(s.id_tim, '') is not null and mt.id_tim is null
  ) as unresolved_sasaran_tim_rows,
  (
    select count(*)
    from public.sasaran s
    left join public.master_kader mk on mk.id_kader = s.id_kader and mk.is_active = true
    where s.is_deleted = false and nullif(s.id_kader, '') is not null and mk.id_kader is null
  ) as unresolved_sasaran_kader_rows,
  (
    select count(*)
    from public.sasaran s
    left join public.master_wilayah mw on mw.id_wilayah = s.id_wilayah and mw.is_active = true
    where s.is_deleted = false and nullif(s.id_wilayah, '') is not null and mw.id_wilayah is null
  ) as unresolved_sasaran_wilayah_rows;

create or replace view public.v_scope_profile_lite
with (security_invoker = true)
as
select
  sp.scope_profile_id,
  sp.auth_user_id,
  sp.id_user,
  sp.username,
  sp.display_name,
  sp.role_akses,
  sp.scope_level,
  sp.scope_code,
  sp.id_kecamatan,
  mkec.kode_kecamatan,
  mkec.nama_kecamatan,
  sp.id_tim,
  mt.nomor_tim,
  mt.nama_tim,
  sp.id_kader,
  mkad.nama_kader,
  sp.is_active,
  sp.created_at,
  sp.updated_at
from public.scope_profile sp
left join public.master_kecamatan mkec on mkec.id_kecamatan = sp.id_kecamatan
left join public.master_tim mt on mt.id_tim = sp.id_tim
left join public.master_kader mkad on mkad.id_kader = sp.id_kader;

-- ============================================================
-- Scope-enriched Read model: Sasaran Lite
-- Keeps the same columns as Paket 7-D, but resolves reference labels from master tables.
-- ============================================================
create or replace view public.v_sasaran_lite
with (security_invoker = true)
as
select
  s.sasaran_id,
  s.created_at,
  s.updated_at,
  s.source_mode,
  s.source_import_batch_id,
  s.source_promote_batch_id,
  s.client_mutation_id,
  s.id_kecamatan,
  coalesce(mkec.kode_kecamatan, s.kode_kecamatan) as kode_kecamatan,
  coalesce(mkec.nama_kecamatan, s.nama_kecamatan) as nama_kecamatan,
  s.id_tim,
  coalesce(mt.nomor_tim, s.nomor_tim) as nomor_tim,
  coalesce(mt.nama_tim, s.nama_tim) as nama_tim,
  s.id_kader,
  coalesce(mkad.nama_kader, s.nama_kader) as nama_kader,
  s.id_wilayah,
  coalesce(mw.desa_kelurahan, s.desa_kelurahan) as desa_kelurahan,
  coalesce(mw.dusun_rw, s.dusun_rw) as dusun_rw,
  s.jenis_sasaran,
  s.nik,
  s.no_kk,
  s.nama_sasaran,
  s.jenis_kelamin,
  s.tanggal_lahir,
  s.usia_bulan,
  s.alamat_lengkap,
  s.nama_ibu_kandung,
  s.sasaran_unique_key,
  s.unique_key_strategy,
  s.needs_review,
  s.review_reason,
  s.status_sasaran,
  s.is_deleted,
  coalesce(pstats.total_pendampingan, 0)::integer as total_pendampingan,
  coalesce(pstats.total_pendampingan_2026, 0)::integer as total_pendampingan_2026,
  coalesce(pstats.pendampingan_jan, 0)::integer as pendampingan_jan,
  coalesce(pstats.pendampingan_feb, 0)::integer as pendampingan_feb,
  coalesce(pstats.pendampingan_mar, 0)::integer as pendampingan_mar,
  coalesce(pstats.pendampingan_apr, 0)::integer as pendampingan_apr,
  coalesce(pstats.pendampingan_mei, 0)::integer as pendampingan_mei,
  coalesce(pstats.pendampingan_jun, 0)::integer as pendampingan_jun,
  pstats.last_tanggal_pendampingan,
  pstats.last_periode_yyyymm,
  pstats.last_status_pendampingan,
  case when coalesce(pstats.total_pendampingan, 0) > 0 then true else false end as sudah_pernah_didampingi
from public.sasaran s
left join public.master_kecamatan mkec on mkec.id_kecamatan = s.id_kecamatan and mkec.is_active = true
left join public.master_tim mt on mt.id_tim = s.id_tim and mt.is_active = true
left join public.master_kader mkad on mkad.id_kader = s.id_kader and mkad.is_active = true
left join public.master_wilayah mw on mw.id_wilayah = s.id_wilayah and mw.is_active = true
left join lateral (
  select
    count(*) filter (where p.is_deleted = false) as total_pendampingan,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026) as total_pendampingan_2026,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 1) as pendampingan_jan,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 2) as pendampingan_feb,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 3) as pendampingan_mar,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 4) as pendampingan_apr,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 5) as pendampingan_mei,
    count(*) filter (where p.is_deleted = false and p.tahun_laporan = 2026 and p.periode_bulan = 6) as pendampingan_jun,
    max(p.tanggal_pendampingan) filter (where p.is_deleted = false) as last_tanggal_pendampingan,
    (
      select p2.periode_yyyymm
      from public.pendampingan p2
      where p2.sasaran_id = s.sasaran_id and p2.is_deleted = false
      order by p2.tanggal_pendampingan desc nulls last, p2.created_at desc
      limit 1
    ) as last_periode_yyyymm,
    (
      select p2.status_pendampingan
      from public.pendampingan p2
      where p2.sasaran_id = s.sasaran_id and p2.is_deleted = false
      order by p2.tanggal_pendampingan desc nulls last, p2.created_at desc
      limit 1
    ) as last_status_pendampingan
  from public.pendampingan p
  where p.sasaran_id = s.sasaran_id
) pstats on true;

-- ============================================================
-- Scope-enriched Read model: Pendampingan Lite
-- ============================================================
create or replace view public.v_pendampingan_lite
with (security_invoker = true)
as
select
  p.pendampingan_id,
  p.created_at,
  p.updated_at,
  p.source_mode,
  p.source_import_batch_id,
  p.source_promote_batch_id,
  p.client_mutation_id,
  p.sasaran_id,
  p.sasaran_unique_key,
  p.pendampingan_unique_key,
  p.id_kecamatan,
  coalesce(mkec.kode_kecamatan, p.kode_kecamatan) as kode_kecamatan,
  coalesce(mkec.nama_kecamatan, p.nama_kecamatan) as nama_kecamatan,
  p.id_tim,
  coalesce(mt.nomor_tim, p.nomor_tim) as nomor_tim,
  coalesce(mt.nama_tim, p.nama_tim) as nama_tim,
  p.id_kader,
  coalesce(mkad.nama_kader, p.nama_kader) as nama_kader,
  p.id_wilayah,
  coalesce(mw.desa_kelurahan, p.desa_kelurahan) as desa_kelurahan,
  coalesce(mw.dusun_rw, p.dusun_rw) as dusun_rw,
  p.id_sasaran_temp,
  p.jenis_sasaran,
  p.nik,
  p.nama_sasaran,
  p.periode_bulan,
  p.tahun_laporan,
  p.periode_yyyymm,
  p.tanggal_pendampingan,
  p.status_pendampingan,
  p.metode_pendampingan,
  p.hasil_pendampingan,
  p.catatan_pendampingan,
  p.needs_review,
  p.review_reason,
  p.is_deleted,
  s.nama_sasaran as parent_nama_sasaran,
  s.jenis_sasaran as parent_jenis_sasaran,
  s.nik as parent_nik,
  s.status_sasaran as parent_status_sasaran
from public.pendampingan p
join public.sasaran s on s.sasaran_id = p.sasaran_id
left join public.master_kecamatan mkec on mkec.id_kecamatan = p.id_kecamatan and mkec.is_active = true
left join public.master_tim mt on mt.id_tim = p.id_tim and mt.is_active = true
left join public.master_kader mkad on mkad.id_kader = p.id_kader and mkad.is_active = true
left join public.master_wilayah mw on mw.id_wilayah = p.id_wilayah and mw.is_active = true;

-- ============================================================
-- Enriched basic summary per Tim
-- ============================================================
create or replace view public.v_summary_tim_basic
with (security_invoker = true)
as
select
  s.id_kecamatan,
  max(s.kode_kecamatan) as kode_kecamatan,
  max(s.nama_kecamatan) as nama_kecamatan,
  s.id_tim,
  max(s.nomor_tim) as nomor_tim,
  max(s.nama_tim) as nama_tim,
  count(*) filter (where s.is_deleted = false) as total_sasaran,
  count(*) filter (where s.is_deleted = false and s.jenis_sasaran = 'CATIN') as total_catin,
  count(*) filter (where s.is_deleted = false and s.jenis_sasaran = 'BUMIL') as total_bumil,
  count(*) filter (where s.is_deleted = false and s.jenis_sasaran = 'BUFAS') as total_bufas,
  count(*) filter (where s.is_deleted = false and s.jenis_sasaran = 'BADUTA') as total_baduta,
  coalesce(p.total_pendampingan, 0)::bigint as total_pendampingan,
  coalesce(p.pendampingan_jan, 0)::bigint as pendampingan_jan,
  coalesce(p.pendampingan_feb, 0)::bigint as pendampingan_feb,
  coalesce(p.pendampingan_mar, 0)::bigint as pendampingan_mar,
  coalesce(p.pendampingan_apr, 0)::bigint as pendampingan_apr,
  coalesce(p.pendampingan_mei, 0)::bigint as pendampingan_mei,
  coalesce(p.pendampingan_jun, 0)::bigint as pendampingan_jun,
  max(s.updated_at) as last_sasaran_updated_at,
  p.last_pendampingan_at
from public.v_sasaran_lite s
left join (
  select
    id_kecamatan,
    id_tim,
    count(*) filter (where is_deleted = false) as total_pendampingan,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 1) as pendampingan_jan,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 2) as pendampingan_feb,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 3) as pendampingan_mar,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 4) as pendampingan_apr,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 5) as pendampingan_mei,
    count(*) filter (where is_deleted = false and tahun_laporan = 2026 and periode_bulan = 6) as pendampingan_jun,
    max(created_at) as last_pendampingan_at
  from public.v_pendampingan_lite
  group by id_kecamatan, id_tim
) p on p.id_kecamatan = s.id_kecamatan and p.id_tim = s.id_tim
group by
  s.id_kecamatan,
  s.id_tim,
  p.total_pendampingan,
  p.pendampingan_jan,
  p.pendampingan_feb,
  p.pendampingan_mar,
  p.pendampingan_apr,
  p.pendampingan_mei,
  p.pendampingan_jun,
  p.last_pendampingan_at;

-- ============================================================
-- Enriched basic summary per Kecamatan
-- ============================================================
create or replace view public.v_summary_kecamatan_basic
with (security_invoker = true)
as
select
  id_kecamatan,
  kode_kecamatan,
  nama_kecamatan,
  count(distinct id_tim) filter (where coalesce(total_sasaran, 0) > 0) as total_tim,
  sum(total_sasaran)::bigint as total_sasaran,
  sum(total_catin)::bigint as total_catin,
  sum(total_bumil)::bigint as total_bumil,
  sum(total_bufas)::bigint as total_bufas,
  sum(total_baduta)::bigint as total_baduta,
  sum(total_pendampingan)::bigint as total_pendampingan,
  sum(pendampingan_jan)::bigint as pendampingan_jan,
  sum(pendampingan_feb)::bigint as pendampingan_feb,
  sum(pendampingan_mar)::bigint as pendampingan_mar,
  sum(pendampingan_apr)::bigint as pendampingan_apr,
  sum(pendampingan_mei)::bigint as pendampingan_mei,
  sum(pendampingan_jun)::bigint as pendampingan_jun,
  max(last_sasaran_updated_at) as last_sasaran_updated_at,
  max(last_pendampingan_at) as last_pendampingan_at
from public.v_summary_tim_basic
group by id_kecamatan, kode_kecamatan, nama_kecamatan;

-- ============================================================
-- Master/scope health and summary functions
-- ============================================================
create or replace function public.check_master_reference_health()
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object(
    'ok', true,
    'package', 'Paket 7-E — Production Master Reference & Scope Foundation',
    'status', case
      when master_kecamatan_rows > 0
       and master_tim_rows > 0
       and master_kader_rows > 0
       and master_wilayah_rows > 0
       and scope_profile_rows > 0
       and unresolved_sasaran_tim_rows = 0
       and unresolved_sasaran_kader_rows = 0
       and unresolved_sasaran_wilayah_rows = 0
      then 'healthy'
      else 'needs_review'
    end,
    'health', to_jsonb(h)
  )
  from public.v_master_reference_health h;
$$;

create or replace function public.get_scope_foundation_summary(
  p_id_kecamatan text default null,
  p_id_tim text default null
)
returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  select jsonb_build_object(
    'ok', true,
    'package', 'Paket 7-E — Production Master Reference & Scope Foundation',
    'scope', jsonb_build_object('id_kecamatan', p_id_kecamatan, 'id_tim', p_id_tim),
    'totals', jsonb_build_object(
      'kecamatan', (select count(*) from public.master_kecamatan where is_active = true and (p_id_kecamatan is null or id_kecamatan = p_id_kecamatan)),
      'tim', (select count(*) from public.master_tim where is_active = true and (p_id_kecamatan is null or id_kecamatan = p_id_kecamatan) and (p_id_tim is null or id_tim = p_id_tim)),
      'kader', (select count(*) from public.master_kader where is_active = true and (p_id_kecamatan is null or id_kecamatan = p_id_kecamatan) and (p_id_tim is null or id_tim = p_id_tim)),
      'wilayah', (select count(*) from public.master_wilayah where is_active = true and (p_id_kecamatan is null or id_kecamatan = p_id_kecamatan)),
      'scope_profile', (select count(*) from public.scope_profile where is_active = true and (p_id_kecamatan is null or id_kecamatan = p_id_kecamatan) and (p_id_tim is null or id_tim = p_id_tim))
    ),
    'kecamatan', coalesce((
      select jsonb_agg(to_jsonb(k) order by k.kode_kecamatan)
      from public.master_kecamatan k
      where k.is_active = true and (p_id_kecamatan is null or k.id_kecamatan = p_id_kecamatan)
    ), '[]'::jsonb),
    'tim', coalesce((
      select jsonb_agg(to_jsonb(t) order by t.id_tim)
      from public.master_tim t
      where t.is_active = true and (p_id_kecamatan is null or t.id_kecamatan = p_id_kecamatan) and (p_id_tim is null or t.id_tim = p_id_tim)
    ), '[]'::jsonb),
    'kader', coalesce((
      select jsonb_agg(to_jsonb(kd) order by kd.id_kader)
      from public.master_kader kd
      where kd.is_active = true and (p_id_kecamatan is null or kd.id_kecamatan = p_id_kecamatan) and (p_id_tim is null or kd.id_tim = p_id_tim)
    ), '[]'::jsonb),
    'scope_profiles', coalesce((
      select jsonb_agg(to_jsonb(sp) order by sp.username)
      from public.v_scope_profile_lite sp
      where sp.is_active = true and (p_id_kecamatan is null or sp.id_kecamatan = p_id_kecamatan) and (p_id_tim is null or sp.id_tim = p_id_tim)
    ), '[]'::jsonb)
  );
$$;

-- Access lock: master/scope views and functions are not opened to anon/authenticated yet.
revoke all on table public.v_master_reference_health from anon, authenticated;
revoke all on table public.v_scope_profile_lite from anon, authenticated;
revoke all on table public.v_sasaran_lite from anon, authenticated;
revoke all on table public.v_pendampingan_lite from anon, authenticated;
revoke all on table public.v_summary_tim_basic from anon, authenticated;
revoke all on table public.v_summary_kecamatan_basic from anon, authenticated;

revoke execute on function public.check_master_reference_health() from public;
revoke execute on function public.check_master_reference_health() from anon;
revoke execute on function public.check_master_reference_health() from authenticated;
grant execute on function public.check_master_reference_health() to postgres;
grant execute on function public.check_master_reference_health() to service_role;

revoke execute on function public.get_scope_foundation_summary(text, text) from public;
revoke execute on function public.get_scope_foundation_summary(text, text) from anon;
revoke execute on function public.get_scope_foundation_summary(text, text) from authenticated;
grant execute on function public.get_scope_foundation_summary(text, text) to postgres;
grant execute on function public.get_scope_foundation_summary(text, text) to service_role;
