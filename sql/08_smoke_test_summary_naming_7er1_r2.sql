-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1-R2
-- Smoke Test: Summary Naming Alignment Repair
-- ============================================================
-- Harapan:
-- 1. Summary memakai kolom total_baduta_prioritas.
-- 2. Summary tidak memiliki kolom total_baduta.
-- 3. Helper taxonomy resmi tetap menerima BALITA dan menolak BADUTA.
-- 4. Pendampingan historis tetap memakai field *_saat_pendampingan.
-- ============================================================

-- 1) Cek nama kolom summary.
SELECT
  table_name,
  column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('v_summary_kecamatan_basic_7er1', 'v_summary_tim_basic_7er1')
  AND column_name IN ('total_balita', 'total_baduta', 'total_baduta_prioritas')
ORDER BY table_name, ordinal_position;

-- 2) PASS jika legacy_total_baduta_columns = 0.
SELECT
  COUNT(*)::integer AS legacy_total_baduta_columns_should_be_0
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('v_summary_kecamatan_basic_7er1', 'v_summary_tim_basic_7er1')
  AND column_name = 'total_baduta';

-- 3) Cek helper taxonomy inti.
SELECT
  public.tpk_taxonomy_version_7er1() AS taxonomy_version,
  public.tpk_is_official_jenis_sasaran_7er1('BALITA') AS balita_should_true,
  public.tpk_is_official_jenis_sasaran_7er1('BADUTA') AS baduta_should_false,
  public.tpk_age_months_7er1('2026-01-31'::date, '2024-02-01'::date) AS age_23_should_be_23,
  public.tpk_is_baduta_prioritas_7er1('BALITA', 23) AS balita_23_should_true,
  public.tpk_is_baduta_prioritas_7er1('BALITA', 25) AS balita_25_should_false;

-- 4) Cek output summary sasaran.
SELECT * FROM public.v_summary_kecamatan_basic_7er1 ORDER BY id_kecamatan;
SELECT * FROM public.v_summary_tim_basic_7er1 ORDER BY id_tim;

-- 5) Cek output summary pendampingan tetap tersedia.
SELECT * FROM public.v_summary_pendampingan_kecamatan_basic_7er1 ORDER BY id_kecamatan;
SELECT * FROM public.v_summary_pendampingan_tim_basic_7er1 ORDER BY id_tim;

-- 6) Cek health read model.
SELECT * FROM public.v_production_read_model_health_7er1;
