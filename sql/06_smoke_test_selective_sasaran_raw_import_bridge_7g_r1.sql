-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G-R1
-- Smoke Test 06: Selective Sasaran Raw Import Bridge
-- ============================================================

-- 1) Health raw bridge.
SELECT public.check_selective_sasaran_raw_bridge_health_7g();

-- 2) Setelah CSV diimpor ke backfill_internal.selective_sasaran_export_raw_7g,
--    cek isi raw table.
SELECT
  COUNT(*) AS raw_rows,
  COUNT(*) FILTER (WHERE upper(coalesce(jenis_sasaran, '')) = 'BADUTA') AS raw_baduta_rows,
  COUNT(*) FILTER (WHERE upper(coalesce(jenis_sasaran, '')) = 'BALITA') AS raw_balita_rows,
  COUNT(*) FILTER (WHERE upper(coalesce(jenis_sasaran, '')) = 'BUMIL') AS raw_bumil_rows,
  COUNT(*) FILTER (WHERE upper(coalesce(jenis_sasaran, '')) = 'BUFAS') AS raw_bufas_rows,
  COUNT(*) FILTER (WHERE upper(coalesce(jenis_sasaran, '')) = 'CATIN') AS raw_catin_rows
FROM backfill_internal.selective_sasaran_export_raw_7g;

-- 3) Preflight untuk batch contoh. Akan mengembalikan ok=false bila CSV masih memuat BADUTA.
--    Itu benar sesuai 7-E-R1.
SELECT public.load_selective_sasaran_raw_to_staging_7g(
  'EXP7G_TJK_SASARAN_20260615_094204',
  'IMP7G_TJK_SASARAN_20260615_094204',
  true,
  false
) AS load_result;
