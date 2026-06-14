-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-F
-- Smoke Test 02: Production Query Contract
-- ============================================================
-- Jalankan setelah sql/01_query_contract_rpc_7f.sql
-- Semua query read-only.
-- ============================================================

-- 1) Versi kontrak.
SELECT
  public.tpk_query_contract_version_7f() AS query_contract_version,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version;

-- 2) Query sasaran lite umum.
SELECT public.query_sasaran_lite_7f(
  NULL,  -- p_id_kecamatan
  NULL,  -- p_id_tim
  NULL,  -- p_jenis_sasaran
  NULL,  -- p_is_baduta_prioritas
  NULL,  -- p_search
  10,    -- p_limit
  0      -- p_offset
) AS sasaran_lite_all;

-- 3) Query pendampingan lite umum.
SELECT public.query_pendampingan_lite_7f(
  NULL,  -- p_id_kecamatan
  NULL,  -- p_id_tim
  NULL,  -- p_periode_bulan
  NULL,  -- p_tahun_laporan
  NULL,  -- p_jenis_sasaran
  NULL,  -- p_is_baduta_prioritas_saat_pendampingan
  NULL,  -- p_search
  10,    -- p_limit
  0      -- p_offset
) AS pendampingan_lite_all;

-- 4) BADUTA harus ditolak sebagai jenis_sasaran query.
SELECT public.query_sasaran_lite_7f(
  NULL,
  NULL,
  'BADUTA',
  NULL,
  NULL,
  10,
  0
) AS baduta_query_should_be_rejected;

-- 5) BALITA harus diterima sebagai jenis_sasaran resmi.
SELECT public.query_sasaran_lite_7f(
  NULL,
  NULL,
  'BALITA',
  NULL,
  NULL,
  10,
  0
) AS balita_query_should_be_accepted;

-- 6) Filter Baduta Prioritas untuk sasaran.
SELECT public.query_sasaran_lite_7f(
  NULL,
  NULL,
  'BALITA',
  true,
  NULL,
  10,
  0
) AS balita_baduta_prioritas_filter;

-- 7) Filter Baduta Prioritas saat pendampingan historis.
SELECT public.query_pendampingan_lite_7f(
  NULL,
  NULL,
  NULL,
  NULL,
  'BALITA',
  true,
  NULL,
  10,
  0
) AS pendampingan_baduta_prioritas_filter;

-- 8) Summary production basic.
SELECT public.get_production_basic_summary_7f() AS production_basic_summary_7f;

-- 9) Health check contract.
SELECT public.check_production_query_contract_health_7f() AS production_query_contract_health_7f;
