-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-D — Production Read Model & Basic Query Layer
-- File 01: Production read models
-- Version: p7d-20260615-r1
-- ============================================================

-- ============================================================
-- Read model: Sasaran Lite
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
  s.kode_kecamatan,
  s.nama_kecamatan,
  s.id_tim,
  s.nomor_tim,
  s.nama_tim,
  s.id_kader,
  s.nama_kader,
  s.id_wilayah,
  s.desa_kelurahan,
  s.dusun_rw,
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
-- Read model: Pendampingan Lite
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
  p.kode_kecamatan,
  p.nama_kecamatan,
  p.id_tim,
  p.nomor_tim,
  p.nama_tim,
  p.id_kader,
  p.nama_kader,
  p.id_wilayah,
  p.desa_kelurahan,
  p.dusun_rw,
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
join public.sasaran s on s.sasaran_id = p.sasaran_id;

-- ============================================================
-- Basic summary per Tim
-- ============================================================
create or replace view public.v_summary_tim_basic
with (security_invoker = true)
as
select
  s.id_kecamatan,
  s.kode_kecamatan,
  s.nama_kecamatan,
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
from public.sasaran s
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
  from public.pendampingan
  group by id_kecamatan, id_tim
) p on p.id_kecamatan = s.id_kecamatan and p.id_tim = s.id_tim
group by
  s.id_kecamatan,
  s.kode_kecamatan,
  s.nama_kecamatan,
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
-- Basic summary per Kecamatan
-- ============================================================
create or replace view public.v_summary_kecamatan_basic
with (security_invoker = true)
as
select
  id_kecamatan,
  kode_kecamatan,
  nama_kecamatan,
  count(distinct id_tim) filter (where is_deleted = false) as total_tim,
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

-- Basic supporting indexes for read model filters.
create index if not exists idx_sasaran_read_scope
  on public.sasaran(id_kecamatan, id_tim, jenis_sasaran, status_sasaran)
  where is_deleted = false;

create index if not exists idx_pendampingan_read_scope
  on public.pendampingan(id_kecamatan, id_tim, tahun_laporan, periode_bulan)
  where is_deleted = false;
