-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E — Production Master Reference & Scope Foundation
-- File 02: Master reference seed and refresh functions
-- Version: p7e-20260615-r1
-- ============================================================

create or replace function public.refresh_master_reference_from_production(
  p_requested_by text default 'manual_sql'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_kecamatan_count integer := 0;
  v_tim_count integer := 0;
  v_kader_count integer := 0;
  v_wilayah_count integer := 0;
  v_scope_count integer := 0;
begin
  -- Kecamatan from sasaran and pendampingan production base.
  insert into public.master_kecamatan(
    id_kecamatan, kode_kecamatan, nama_kecamatan, source_mode, updated_at, catatan
  )
  select distinct
    src.id_kecamatan,
    coalesce(nullif(src.kode_kecamatan, ''), src.id_kecamatan) as kode_kecamatan,
    coalesce(nullif(src.nama_kecamatan, ''), src.id_kecamatan) as nama_kecamatan,
    'BACKFILL',
    now(),
    'Seeded from production base by ' || coalesce(p_requested_by, 'manual_sql')
  from (
    select id_kecamatan, kode_kecamatan, nama_kecamatan from public.sasaran where nullif(id_kecamatan, '') is not null
    union
    select id_kecamatan, kode_kecamatan, nama_kecamatan from public.pendampingan where nullif(id_kecamatan, '') is not null
  ) src
  on conflict (id_kecamatan) do update set
    kode_kecamatan = excluded.kode_kecamatan,
    nama_kecamatan = excluded.nama_kecamatan,
    updated_at = now();

  get diagnostics v_kecamatan_count = row_count;

  -- Tim from production base.
  insert into public.master_tim(
    id_tim, id_kecamatan, kode_kecamatan, nomor_tim, nama_tim, source_mode, updated_at, catatan
  )
  select
    src.id_tim,
    src.id_kecamatan,
    max(src.kode_kecamatan) as kode_kecamatan,
    coalesce(max(nullif(src.nomor_tim, '')), src.id_tim) as nomor_tim,
    coalesce(max(nullif(src.nama_tim, '')), src.id_tim) as nama_tim,
    'BACKFILL',
    now(),
    'Seeded from production base by ' || coalesce(p_requested_by, 'manual_sql')
  from (
    select id_tim, id_kecamatan, kode_kecamatan, nomor_tim, nama_tim from public.sasaran where nullif(id_tim, '') is not null and nullif(id_kecamatan, '') is not null
    union all
    select id_tim, id_kecamatan, kode_kecamatan, nomor_tim, nama_tim from public.pendampingan where nullif(id_tim, '') is not null and nullif(id_kecamatan, '') is not null
  ) src
  group by src.id_tim, src.id_kecamatan
  on conflict (id_tim) do update set
    id_kecamatan = excluded.id_kecamatan,
    kode_kecamatan = excluded.kode_kecamatan,
    nomor_tim = excluded.nomor_tim,
    nama_tim = excluded.nama_tim,
    updated_at = now();

  get diagnostics v_tim_count = row_count;

  -- Kader from production base.
  insert into public.master_kader(
    id_kader, id_tim, id_kecamatan, nama_kader, source_mode, updated_at, catatan
  )
  select
    src.id_kader,
    max(src.id_tim) as id_tim,
    max(src.id_kecamatan) as id_kecamatan,
    coalesce(max(nullif(src.nama_kader, '')), src.id_kader) as nama_kader,
    'BACKFILL',
    now(),
    'Seeded from production base by ' || coalesce(p_requested_by, 'manual_sql')
  from (
    select id_kader, id_tim, id_kecamatan, nama_kader from public.sasaran where nullif(id_kader, '') is not null
    union all
    select id_kader, id_tim, id_kecamatan, nama_kader from public.pendampingan where nullif(id_kader, '') is not null
  ) src
  group by src.id_kader
  on conflict (id_kader) do update set
    id_tim = excluded.id_tim,
    id_kecamatan = excluded.id_kecamatan,
    nama_kader = excluded.nama_kader,
    updated_at = now();

  get diagnostics v_kader_count = row_count;

  -- Wilayah from production base.
  insert into public.master_wilayah(
    id_wilayah, id_kecamatan, kode_kecamatan, nama_kecamatan, desa_kelurahan, dusun_rw,
    nama_wilayah_lengkap, source_mode, updated_at, catatan
  )
  select
    src.id_wilayah,
    max(src.id_kecamatan) as id_kecamatan,
    max(src.kode_kecamatan) as kode_kecamatan,
    max(src.nama_kecamatan) as nama_kecamatan,
    coalesce(max(nullif(src.desa_kelurahan, '')), '-') as desa_kelurahan,
    max(nullif(src.dusun_rw, '')) as dusun_rw,
    trim(concat_ws(' - ', coalesce(max(nullif(src.nama_kecamatan, '')), max(src.id_kecamatan)), coalesce(max(nullif(src.desa_kelurahan, '')), '-'), max(nullif(src.dusun_rw, '')))) as nama_wilayah_lengkap,
    'BACKFILL',
    now(),
    'Seeded from production base by ' || coalesce(p_requested_by, 'manual_sql')
  from (
    select id_wilayah, id_kecamatan, kode_kecamatan, nama_kecamatan, desa_kelurahan, dusun_rw from public.sasaran where nullif(id_wilayah, '') is not null
    union all
    select id_wilayah, id_kecamatan, kode_kecamatan, nama_kecamatan, desa_kelurahan, dusun_rw from public.pendampingan where nullif(id_wilayah, '') is not null
  ) src
  group by src.id_wilayah
  on conflict (id_wilayah) do update set
    id_kecamatan = excluded.id_kecamatan,
    kode_kecamatan = excluded.kode_kecamatan,
    nama_kecamatan = excluded.nama_kecamatan,
    desa_kelurahan = excluded.desa_kelurahan,
    dusun_rw = excluded.dusun_rw,
    nama_wilayah_lengkap = excluded.nama_wilayah_lengkap,
    updated_at = now();

  get diagnostics v_wilayah_count = row_count;

  -- Scope foundation from master_kader. This is not Supabase Auth yet.
  insert into public.scope_profile(
    id_user, username, display_name, role_akses, scope_level, scope_code,
    id_kecamatan, id_tim, id_kader, source_mode, updated_at, catatan
  )
  select
    k.id_kader as id_user,
    k.id_kader as username,
    k.nama_kader as display_name,
    'KADER' as role_akses,
    'TIM' as scope_level,
    k.id_tim as scope_code,
    k.id_kecamatan,
    k.id_tim,
    k.id_kader,
    'BACKFILL',
    now(),
    'Scope seed from master_kader by ' || coalesce(p_requested_by, 'manual_sql')
  from public.master_kader k
  where k.is_active = true
    and nullif(k.id_kader, '') is not null
  on conflict (id_user) do update set
    username = excluded.username,
    display_name = excluded.display_name,
    role_akses = excluded.role_akses,
    scope_level = excluded.scope_level,
    scope_code = excluded.scope_code,
    id_kecamatan = excluded.id_kecamatan,
    id_tim = excluded.id_tim,
    id_kader = excluded.id_kader,
    updated_at = now();

  get diagnostics v_scope_count = row_count;

  return jsonb_build_object(
    'ok', true,
    'status', 'success',
    'package', 'Paket 7-E — Production Master Reference & Scope Foundation',
    'requested_by', p_requested_by,
    'upserted', jsonb_build_object(
      'master_kecamatan', v_kecamatan_count,
      'master_tim', v_tim_count,
      'master_kader', v_kader_count,
      'master_wilayah', v_wilayah_count,
      'scope_profile', v_scope_count
    )
  );
end;
$$;

-- Execute once during migration so current promoted data is immediately enriched.
select public.refresh_master_reference_from_production('migration_p7e_20260615');

revoke execute on function public.refresh_master_reference_from_production(text) from public;
revoke execute on function public.refresh_master_reference_from_production(text) from anon;
revoke execute on function public.refresh_master_reference_from_production(text) from authenticated;
grant execute on function public.refresh_master_reference_from_production(text) to postgres;
grant execute on function public.refresh_master_reference_from_production(text) to service_role;
