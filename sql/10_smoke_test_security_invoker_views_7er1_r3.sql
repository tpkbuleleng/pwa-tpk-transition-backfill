-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1-R3
-- Smoke Test 10: Security Invoker Public Views
-- ============================================================
-- Harapan:
-- 1. public_views_without_security_invoker = 0
-- 2. Semua public views memiliki reloption security_invoker=true
-- 3. Read model 7-E-R1 tetap bisa dibaca oleh role SQL Editor/postgres
-- ============================================================

-- 1) Ringkasan status semua view public.
WITH public_views AS (
  SELECT
    n.nspname AS schema_name,
    c.relname AS view_name,
    COALESCE(c.reloptions, ARRAY[]::text[]) AS reloptions
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'v'
)
SELECT
  COUNT(*) AS public_views_total,
  COUNT(*) FILTER (
    WHERE reloptions @> ARRAY['security_invoker=true']::text[]
  ) AS public_views_with_security_invoker,
  COUNT(*) FILTER (
    WHERE NOT (reloptions @> ARRAY['security_invoker=true']::text[])
  ) AS public_views_without_security_invoker
FROM public_views;

-- 2) Detail view yang masih belum security_invoker.
-- Hasil ideal: 0 row.
WITH public_views AS (
  SELECT
    n.nspname AS schema_name,
    c.relname AS view_name,
    COALESCE(c.reloptions, ARRAY[]::text[]) AS reloptions
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'v'
)
SELECT
  schema_name,
  view_name,
  reloptions
FROM public_views
WHERE NOT (reloptions @> ARRAY['security_invoker=true']::text[])
ORDER BY view_name;

-- 3) Smoke test read model 7-E-R1 yang terlihat pada Advisor.
SELECT COUNT(*) AS v_sasaran_lite_7er1_rows
FROM public.v_sasaran_lite_7er1;

SELECT COUNT(*) AS v_pendampingan_lite_7er1_rows
FROM public.v_pendampingan_lite_7er1;

SELECT COUNT(*) AS v_summary_tim_basic_7er1_rows
FROM public.v_summary_tim_basic_7er1;

SELECT COUNT(*) AS v_summary_kecamatan_basic_7er1_rows
FROM public.v_summary_kecamatan_basic_7er1;

SELECT COUNT(*) AS v_summary_pendampingan_tim_basic_7er1_rows
FROM public.v_summary_pendampingan_tim_basic_7er1;

SELECT COUNT(*) AS v_summary_pendampingan_kecamatan_basic_7er1_rows
FROM public.v_summary_pendampingan_kecamatan_basic_7er1;

SELECT *
FROM public.v_production_read_model_health_7er1;
