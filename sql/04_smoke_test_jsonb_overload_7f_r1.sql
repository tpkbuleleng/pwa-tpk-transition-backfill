-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-F-R1
-- Smoke Test 04: JSONB Filter Overload
-- ============================================================
-- Jalankan setelah sql/03_query_contract_jsonb_overload_7f_r1.sql
-- Semua query read-only.
-- ============================================================

-- 1) Query sasaran lite normal via JSONB filters object.
SELECT public.query_sasaran_lite_7f('{}'::jsonb) AS sasaran_lite_jsonb_all;

-- 2) Query pendampingan lite normal via JSONB filters object.
SELECT public.query_pendampingan_lite_7f('{}'::jsonb) AS pendampingan_lite_jsonb_all;

-- 3) BADUTA sebagai filter jenis_sasaran harus ditolak.
SELECT public.query_sasaran_lite_7f('{"jenis_sasaran":"BADUTA"}'::jsonb) AS baduta_query_should_be_rejected;

-- 4) BALITA harus diterima sebagai jenis_sasaran resmi.
SELECT public.query_sasaran_lite_7f('{"jenis_sasaran":"BALITA"}'::jsonb) AS balita_query_should_be_accepted;

-- 5) Filter Baduta Prioritas untuk sasaran.
SELECT public.query_sasaran_lite_7f(
  '{"jenis_sasaran":"BALITA","is_baduta_prioritas":true,"limit":10,"offset":0}'::jsonb
) AS balita_baduta_prioritas_filter;

-- 6) Filter Baduta Prioritas saat pendampingan historis.
SELECT public.query_pendampingan_lite_7f(
  '{"jenis_sasaran":"BALITA","is_baduta_prioritas_saat_pendampingan":true,"limit":10,"offset":0}'::jsonb
) AS pendampingan_baduta_prioritas_filter;

-- 7) Summary production basic tetap normal.
SELECT public.get_production_basic_summary_7f() AS production_basic_summary_7f;

-- 8) Health check contract tetap normal.
SELECT public.check_production_query_contract_health_7f() AS production_query_contract_health_7f;

-- 9) Ringkasan PASS cepat.
SELECT jsonb_build_object(
  'ok', true,
  'contract_version', public.tpk_query_contract_version_7f(),
  'taxonomy_version', public.tpk_taxonomy_version_7er1(),
  'sasaran_jsonb_ok', public.query_sasaran_lite_7f('{}'::jsonb) ->> 'ok',
  'pendampingan_jsonb_ok', public.query_pendampingan_lite_7f('{}'::jsonb) ->> 'ok',
  'baduta_rejected_ok_false', public.query_sasaran_lite_7f('{"jenis_sasaran":"BADUTA"}'::jsonb) ->> 'ok',
  'baduta_rejected_code', public.query_sasaran_lite_7f('{"jenis_sasaran":"BADUTA"}'::jsonb) #>> '{errors,0,code}',
  'health_ok', public.check_production_query_contract_health_7f() ->> 'ok'
) AS jsonb_overload_smoke_summary_7f_r1;
