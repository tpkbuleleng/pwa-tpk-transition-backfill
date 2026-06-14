-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1-R2
-- Patch 07: Summary Naming Alignment Repair
-- ============================================================
-- Tujuan:
-- 1. Memperbaiki patch 7-E-R1-R1 yang salah memanggil helper:
--      tpk_is_baduta_priority_7er1  -> SALAH / tidak ada
--      tpk_is_baduta_prioritas_7er1 -> BENAR
-- 2. Mengunci nama kolom resmi derived priority:
--      total_baduta_prioritas
-- 3. Tidak membuat kolom total_baduta pada summary.
-- 4. Tidak mengubah RLS/policy.
-- 5. Aman dijalankan berulang setelah migration 01-04 Paket 7-E-R1.
-- ============================================================

BEGIN;

-- Summary sasaran per tim.
-- Menggunakan v_sasaran_lite_7er1 agar parsing tanggal/boolean tetap mengikuti
-- read model 7-E-R1 yang sudah PASS dan tidak perlu cast manual dari jsonb.
CREATE OR REPLACE VIEW public.v_summary_tim_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_sasaran_lite_7er1
)
SELECT
  COALESCE(id_tim, '-') AS id_tim,
  COUNT(*)::integer AS total_sasaran,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'CATIN')::integer AS total_catin,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BUMIL')::integer AS total_bumil,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BUFAS')::integer AS total_bufas,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS total_balita,
  COUNT(*) FILTER (
    WHERE jenis_sasaran = 'BALITA'
      AND is_baduta_prioritas IS TRUE
  )::integer AS total_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY COALESCE(id_tim, '-');

-- Summary sasaran per kecamatan.
CREATE OR REPLACE VIEW public.v_summary_kecamatan_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_sasaran_lite_7er1
)
SELECT
  COALESCE(id_kecamatan, kode_kecamatan, nama_kecamatan, '-') AS id_kecamatan,
  COUNT(*)::integer AS total_sasaran,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'CATIN')::integer AS total_catin,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BUMIL')::integer AS total_bumil,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BUFAS')::integer AS total_bufas,
  COUNT(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS total_balita,
  COUNT(*) FILTER (
    WHERE jenis_sasaran = 'BALITA'
      AND is_baduta_prioritas IS TRUE
  )::integer AS total_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY COALESCE(id_kecamatan, kode_kecamatan, nama_kecamatan, '-');

-- Function summary tetap mempertahankan output pendampingan dari migration 04.
CREATE OR REPLACE FUNCTION public.get_production_basic_summary_7er1()
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT jsonb_build_object(
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'summary_tim', COALESCE((SELECT jsonb_agg(to_jsonb(t) ORDER BY t.id_tim) FROM public.v_summary_tim_basic_7er1 t), '[]'::jsonb),
    'summary_kecamatan', COALESCE((SELECT jsonb_agg(to_jsonb(k) ORDER BY k.id_kecamatan) FROM public.v_summary_kecamatan_basic_7er1 k), '[]'::jsonb),
    'summary_pendampingan_tim', COALESCE((SELECT jsonb_agg(to_jsonb(pt) ORDER BY pt.id_tim) FROM public.v_summary_pendampingan_tim_basic_7er1 pt), '[]'::jsonb),
    'summary_pendampingan_kecamatan', COALESCE((SELECT jsonb_agg(to_jsonb(pk) ORDER BY pk.id_kecamatan) FROM public.v_summary_pendampingan_kecamatan_basic_7er1 pk), '[]'::jsonb)
  );
$$;

COMMIT;

-- Smoke check singkat setelah COMMIT.
SELECT * FROM public.v_summary_kecamatan_basic_7er1 ORDER BY id_kecamatan;
SELECT * FROM public.v_summary_tim_basic_7er1 ORDER BY id_tim;
SELECT public.get_production_basic_summary_7er1() AS production_basic_summary_7er1;
