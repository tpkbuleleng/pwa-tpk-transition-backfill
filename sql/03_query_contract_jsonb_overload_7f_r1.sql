-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-F-R1
-- Patch 03: JSONB Filter Overload for Production Query Contract
-- ============================================================
-- Tujuan:
-- 1. Menambahkan overload RPC query_sasaran_lite_7f(jsonb).
-- 2. Menambahkan overload RPC query_pendampingan_lite_7f(jsonb).
-- 3. Memudahkan SQL smoke test dan kontrak frontend berbasis filters object.
-- 4. Tidak mengubah table, view, RLS, policy, atau data.
-- 5. Function diberi SET search_path untuk menghindari Function Search Path Mutable.
-- ============================================================
-- Catatan:
-- - Overload JSONB sengaja TIDAK diberi DEFAULT '{}'::jsonb agar tidak ambigu
--   dengan function positional 7-F yang semua argumennya memiliki default.
-- - SupabaseProvider placeholder tetap boleh memakai named positional args.
-- - SQL smoke test boleh memakai '{}'::jsonb.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.query_sasaran_lite_7f(p_filters jsonb)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_filters jsonb := COALESCE(p_filters, '{}'::jsonb);
  v_id_kecamatan text := NULLIF(BTRIM(COALESCE(v_filters ->> 'id_kecamatan', '')), '');
  v_id_tim text := NULLIF(BTRIM(COALESCE(v_filters ->> 'id_tim', '')), '');
  v_jenis_sasaran text := NULLIF(BTRIM(COALESCE(v_filters ->> 'jenis_sasaran', '')), '');
  v_is_baduta_prioritas boolean := NULL;
  v_search text := NULLIF(BTRIM(COALESCE(v_filters ->> 'search', '')), '');
  v_limit integer := NULL;
  v_offset integer := NULL;
BEGIN
  IF v_filters ? 'is_baduta_prioritas'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'is_baduta_prioritas', '')), '') IS NOT NULL THEN
    v_is_baduta_prioritas := (v_filters ->> 'is_baduta_prioritas')::boolean;
  END IF;

  IF v_filters ? 'limit'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'limit', '')), '') IS NOT NULL THEN
    v_limit := (v_filters ->> 'limit')::integer;
  END IF;

  IF v_filters ? 'offset'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'offset', '')), '') IS NOT NULL THEN
    v_offset := (v_filters ->> 'offset')::integer;
  END IF;

  RETURN public.query_sasaran_lite_7f(
    v_id_kecamatan,
    v_id_tim,
    v_jenis_sasaran,
    v_is_baduta_prioritas,
    v_search,
    v_limit,
    v_offset
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.query_pendampingan_lite_7f(p_filters jsonb)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_filters jsonb := COALESCE(p_filters, '{}'::jsonb);
  v_id_kecamatan text := NULLIF(BTRIM(COALESCE(v_filters ->> 'id_kecamatan', '')), '');
  v_id_tim text := NULLIF(BTRIM(COALESCE(v_filters ->> 'id_tim', '')), '');
  v_periode_bulan text := NULLIF(BTRIM(COALESCE(v_filters ->> 'periode_bulan', '')), '');
  v_tahun_laporan integer := NULL;
  v_jenis_sasaran text := NULLIF(BTRIM(COALESCE(v_filters ->> 'jenis_sasaran', '')), '');
  v_is_baduta_prioritas_saat_pendampingan boolean := NULL;
  v_search text := NULLIF(BTRIM(COALESCE(v_filters ->> 'search', '')), '');
  v_limit integer := NULL;
  v_offset integer := NULL;
BEGIN
  IF v_filters ? 'tahun_laporan'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'tahun_laporan', '')), '') IS NOT NULL THEN
    v_tahun_laporan := (v_filters ->> 'tahun_laporan')::integer;
  END IF;

  IF v_filters ? 'is_baduta_prioritas_saat_pendampingan'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'is_baduta_prioritas_saat_pendampingan', '')), '') IS NOT NULL THEN
    v_is_baduta_prioritas_saat_pendampingan :=
      (v_filters ->> 'is_baduta_prioritas_saat_pendampingan')::boolean;
  END IF;

  IF v_filters ? 'limit'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'limit', '')), '') IS NOT NULL THEN
    v_limit := (v_filters ->> 'limit')::integer;
  END IF;

  IF v_filters ? 'offset'
     AND NULLIF(BTRIM(COALESCE(v_filters ->> 'offset', '')), '') IS NOT NULL THEN
    v_offset := (v_filters ->> 'offset')::integer;
  END IF;

  RETURN public.query_pendampingan_lite_7f(
    v_id_kecamatan,
    v_id_tim,
    v_periode_bulan,
    v_tahun_laporan,
    v_jenis_sasaran,
    v_is_baduta_prioritas_saat_pendampingan,
    v_search,
    v_limit,
    v_offset
  );
END;
$$;

COMMIT;
