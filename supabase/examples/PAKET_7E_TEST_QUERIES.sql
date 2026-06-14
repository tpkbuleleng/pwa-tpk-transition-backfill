-- ============================================================
-- Paket 7-E — Production Master Reference & Scope Foundation
-- Test queries
-- ============================================================

-- 1. Refresh master references from current production base rows.
select public.refresh_master_reference_from_production('manual_test_p7e');

-- 2. Check master/scope health.
select public.check_master_reference_health();
select * from public.v_master_reference_health;

-- 3. Inspect master references.
select * from public.master_kecamatan order by kode_kecamatan;
select * from public.master_tim order by id_kecamatan, id_tim;
select * from public.master_kader order by id_kecamatan, id_tim, id_kader;
select * from public.master_wilayah order by id_kecamatan, desa_kelurahan, dusun_rw;
select * from public.v_scope_profile_lite order by role_akses, id_kecamatan, id_tim, id_kader;

-- 4. Check scope foundation summary.
select public.get_scope_foundation_summary('TJK', 'TIM_TJK_001');

-- 5. Check read model enrichment.
select
  sasaran_id,
  id_kecamatan,
  kode_kecamatan,
  nama_kecamatan,
  id_tim,
  nomor_tim,
  nama_tim,
  id_kader,
  nama_kader,
  id_wilayah,
  desa_kelurahan,
  dusun_rw,
  nama_sasaran,
  jenis_sasaran,
  total_pendampingan
from public.query_sasaran_lite('TJK', 'TIM_TJK_001', null, 'AKTIF', null, 50, 0);

select
  pendampingan_id,
  id_kecamatan,
  kode_kecamatan,
  nama_kecamatan,
  id_tim,
  nomor_tim,
  nama_tim,
  id_kader,
  nama_kader,
  id_wilayah,
  desa_kelurahan,
  dusun_rw,
  nama_sasaran,
  parent_nama_sasaran,
  periode_bulan,
  tahun_laporan
from public.query_pendampingan_lite('TJK', 'TIM_TJK_001', 2026, 1, null, 50, 0);

-- 6. Existing production summary should still work after enrichment.
select public.get_production_basic_summary('TJK', 'TIM_TJK_001');
