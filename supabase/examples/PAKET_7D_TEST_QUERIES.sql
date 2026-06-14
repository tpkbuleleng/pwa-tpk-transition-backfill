-- ============================================================
-- Paket 7-D — Test Queries
-- Production Read Model & Basic Query Layer
-- ============================================================

-- 1. Health check read model
select public.check_production_read_model_health();

-- 2. Cek rows read model
select * from public.v_production_read_model_health;

-- 3. Query sasaran lite untuk TJK/TIM_TJK_001
select
  sasaran_id,
  sasaran_unique_key,
  nama_sasaran,
  nik,
  jenis_sasaran,
  total_pendampingan,
  pendampingan_jan,
  sudah_pernah_didampingi
from public.query_sasaran_lite(
  'TJK',
  'TIM_TJK_001',
  null,
  'AKTIF',
  null,
  50,
  0
);

-- 4. Query pendampingan lite Januari 2026
select
  pendampingan_id,
  pendampingan_unique_key,
  sasaran_unique_key,
  parent_nama_sasaran,
  periode_bulan,
  tahun_laporan,
  tanggal_pendampingan
from public.query_pendampingan_lite(
  'TJK',
  'TIM_TJK_001',
  2026,
  1,
  null,
  50,
  0
);

-- 5. Summary basic JSON
select public.get_production_basic_summary('TJK', 'TIM_TJK_001');

-- 6. Summary tim dan kecamatan
select * from public.v_summary_tim_basic order by id_kecamatan, id_tim;
select * from public.v_summary_kecamatan_basic order by id_kecamatan;
