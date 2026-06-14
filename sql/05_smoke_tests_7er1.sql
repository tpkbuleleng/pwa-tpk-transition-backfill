-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1 — Smoke Tests
-- ============================================================
-- Jalankan setelah migration 01-04.
-- Semua query bersifat read-only.
-- ============================================================

-- 1) Helper umur bulan
SELECT
  public.tpk_age_months_7er1('2026-01-31'::date, '2024-02-01'::date) AS age_23_should_be_23,
  public.tpk_is_baduta_prioritas_7er1('BALITA', 23) AS balita_23_should_true,
  public.tpk_age_months_7er1('2026-01-31'::date, '2023-12-01'::date) AS age_25_should_be_25,
  public.tpk_is_baduta_prioritas_7er1('BALITA', 25) AS balita_25_should_false,
  public.tpk_is_official_jenis_sasaran_7er1('BADUTA') AS baduta_should_false,
  public.tpk_is_official_jenis_sasaran_7er1('BALITA') AS balita_should_true;

-- 2) Staging validation errors taxonomy, jika staging table sudah ada.
SELECT *
FROM public.validate_backfill_import_batch_taxonomy_7er1(NULL)
ORDER BY source_table, record_key
LIMIT 50;

-- 3) Production read model health 7-E-R1.
SELECT *
FROM public.v_production_read_model_health_7er1;

-- 4) Summary tim 7-E-R1.
SELECT *
FROM public.v_summary_tim_basic_7er1
ORDER BY id_tim;

-- 5) Summary kecamatan 7-E-R1.
SELECT *
FROM public.v_summary_kecamatan_basic_7er1
ORDER BY id_kecamatan;

-- 6) Pendampingan historis: prioritas dihitung dari tanggal_pendampingan.
SELECT
  pendampingan_id,
  sasaran_unique_key,
  nama_sasaran,
  jenis_sasaran,
  tanggal_lahir,
  tanggal_pendampingan,
  usia_bulan_saat_pendampingan,
  is_baduta_prioritas_saat_pendampingan,
  kelompok_umur_saat_pendampingan
FROM public.v_pendampingan_lite_7er1
WHERE jenis_sasaran = 'BALITA'
ORDER BY tanggal_pendampingan NULLS LAST, nama_sasaran
LIMIT 50;
