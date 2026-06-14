-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-F
-- Migration 01: Production Query Contract RPC
-- ============================================================
-- Tujuan:
-- 1. Mengunci kontrak query production untuk frontend readiness.
-- 2. Membaca read model taxonomy 7-E-R1.
-- 3. Menolak BADUTA sebagai filter jenis_sasaran resmi.
-- 4. Menyediakan envelope JSON stabil untuk frontend.
-- 5. Tidak mengubah RLS/policy/table/data.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.tpk_query_contract_version_7f()
RETURNS text
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT 'TPK_QUERY_CONTRACT_2026_7F'::text;
$$;

CREATE OR REPLACE FUNCTION public.tpk_7f_error(
  p_code text,
  p_message text,
  p_field text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT jsonb_build_object(
    'ok', false,
    'contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'errors', jsonb_build_array(
      jsonb_strip_nulls(
        jsonb_build_object(
          'field', p_field,
          'code', p_code,
          'message', p_message
        )
      )
    ),
    'data', '[]'::jsonb,
    'meta', jsonb_build_object(
      'total_count', 0,
      'limit', 0,
      'offset', 0
    )
  );
$$;

CREATE OR REPLACE FUNCTION public.query_sasaran_lite_7f(
  p_id_kecamatan text DEFAULT NULL,
  p_id_tim text DEFAULT NULL,
  p_jenis_sasaran text DEFAULT NULL,
  p_is_baduta_prioritas boolean DEFAULT NULL,
  p_search text DEFAULT NULL,
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_jenis text := NULL;
  v_limit integer := GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
  v_offset integer := GREATEST(COALESCE(p_offset, 0), 0);
  v_search text := NULLIF(LOWER(BTRIM(COALESCE(p_search, ''))), '');
  v_id_kecamatan text := NULLIF(BTRIM(COALESCE(p_id_kecamatan, '')), '');
  v_id_tim text := NULLIF(BTRIM(COALESCE(p_id_tim, '')), '');
BEGIN
  IF NULLIF(BTRIM(COALESCE(p_jenis_sasaran, '')), '') IS NOT NULL THEN
    v_jenis := public.tpk_norm_jenis_sasaran_7er1(p_jenis_sasaran);

    IF v_jenis = 'BADUTA' THEN
      RETURN public.tpk_7f_error(
        'BADUTA_LEGACY_NOT_ALLOWED',
        'BADUTA tidak lagi dipakai sebagai jenis_sasaran. Gunakan BALITA dan filter is_baduta_prioritas=true.',
        'jenis_sasaran'
      );
    END IF;

    IF NOT public.tpk_is_official_jenis_sasaran_7er1(v_jenis) THEN
      RETURN public.tpk_7f_error(
        'INVALID_JENIS_SASARAN',
        'jenis_sasaran resmi hanya CATIN, BUMIL, BUFAS, BALITA.',
        'jenis_sasaran'
      );
    END IF;
  END IF;

  RETURN (
    WITH src AS (
      SELECT to_jsonb(v) AS j
      FROM public.v_sasaran_lite_7er1 v
    ),
    filtered AS (
      SELECT j
      FROM src
      WHERE
        (v_id_kecamatan IS NULL OR j ->> 'id_kecamatan' = v_id_kecamatan)
        AND (v_id_tim IS NULL OR j ->> 'id_tim' = v_id_tim)
        AND (v_jenis IS NULL OR j ->> 'jenis_sasaran' = v_jenis)
        AND (
          p_is_baduta_prioritas IS NULL
          OR COALESCE((j ->> 'is_baduta_prioritas')::boolean, false) = p_is_baduta_prioritas
        )
        AND (
          v_search IS NULL
          OR LOWER(CONCAT_WS(
            ' ',
            j ->> 'nama_sasaran',
            j ->> 'nik',
            j ->> 'sasaran_unique_key',
            j ->> 'id_tim',
            j ->> 'id_kecamatan',
            j ->> 'jenis_sasaran'
          )) LIKE '%' || v_search || '%'
        )
    ),
    counted AS (
      SELECT COUNT(*)::integer AS total_count
      FROM filtered
    ),
    paged AS (
      SELECT j
      FROM filtered
      ORDER BY
        COALESCE(j ->> 'nama_sasaran', ''),
        COALESCE(j ->> 'sasaran_unique_key', '')
      LIMIT v_limit
      OFFSET v_offset
    )
    SELECT jsonb_build_object(
      'ok', true,
      'contract_version', public.tpk_query_contract_version_7f(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'data', COALESCE((SELECT jsonb_agg(j) FROM paged), '[]'::jsonb),
      'meta', jsonb_build_object(
        'total_count', (SELECT total_count FROM counted),
        'limit', v_limit,
        'offset', v_offset,
        'filters', jsonb_strip_nulls(jsonb_build_object(
          'id_kecamatan', v_id_kecamatan,
          'id_tim', v_id_tim,
          'jenis_sasaran', v_jenis,
          'is_baduta_prioritas', p_is_baduta_prioritas,
          'search', v_search
        ))
      )
    )
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.query_pendampingan_lite_7f(
  p_id_kecamatan text DEFAULT NULL,
  p_id_tim text DEFAULT NULL,
  p_periode_bulan text DEFAULT NULL,
  p_tahun_laporan integer DEFAULT NULL,
  p_jenis_sasaran text DEFAULT NULL,
  p_is_baduta_prioritas_saat_pendampingan boolean DEFAULT NULL,
  p_search text DEFAULT NULL,
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_jenis text := NULL;
  v_limit integer := GREATEST(1, LEAST(COALESCE(p_limit, 50), 200));
  v_offset integer := GREATEST(COALESCE(p_offset, 0), 0);
  v_search text := NULLIF(LOWER(BTRIM(COALESCE(p_search, ''))), '');
  v_id_kecamatan text := NULLIF(BTRIM(COALESCE(p_id_kecamatan, '')), '');
  v_id_tim text := NULLIF(BTRIM(COALESCE(p_id_tim, '')), '');
  v_periode_bulan text := NULLIF(LOWER(BTRIM(COALESCE(p_periode_bulan, ''))), '');
BEGIN
  IF NULLIF(BTRIM(COALESCE(p_jenis_sasaran, '')), '') IS NOT NULL THEN
    v_jenis := public.tpk_norm_jenis_sasaran_7er1(p_jenis_sasaran);

    IF v_jenis = 'BADUTA' THEN
      RETURN public.tpk_7f_error(
        'BADUTA_LEGACY_NOT_ALLOWED',
        'BADUTA tidak lagi dipakai sebagai jenis_sasaran. Gunakan BALITA dan filter is_baduta_prioritas_saat_pendampingan=true.',
        'jenis_sasaran'
      );
    END IF;

    IF NOT public.tpk_is_official_jenis_sasaran_7er1(v_jenis) THEN
      RETURN public.tpk_7f_error(
        'INVALID_JENIS_SASARAN',
        'jenis_sasaran resmi hanya CATIN, BUMIL, BUFAS, BALITA.',
        'jenis_sasaran'
      );
    END IF;
  END IF;

  RETURN (
    WITH src AS (
      SELECT to_jsonb(v) AS j
      FROM public.v_pendampingan_lite_7er1 v
    ),
    filtered AS (
      SELECT j
      FROM src
      WHERE
        (v_id_kecamatan IS NULL OR j ->> 'id_kecamatan' = v_id_kecamatan)
        AND (v_id_tim IS NULL OR j ->> 'id_tim' = v_id_tim)
        AND (
          v_periode_bulan IS NULL
          OR LOWER(COALESCE(j ->> 'periode_bulan', '')) = v_periode_bulan
          OR LOWER(COALESCE(j ->> 'bulan_laporan', '')) = v_periode_bulan
        )
        AND (
          p_tahun_laporan IS NULL
          OR COALESCE(j ->> 'tahun_laporan', j ->> 'tahun') = p_tahun_laporan::text
        )
        AND (v_jenis IS NULL OR j ->> 'jenis_sasaran' = v_jenis)
        AND (
          p_is_baduta_prioritas_saat_pendampingan IS NULL
          OR COALESCE((j ->> 'is_baduta_prioritas_saat_pendampingan')::boolean, false)
             = p_is_baduta_prioritas_saat_pendampingan
        )
        AND (
          v_search IS NULL
          OR LOWER(CONCAT_WS(
            ' ',
            j ->> 'nama_sasaran',
            j ->> 'nik',
            j ->> 'sasaran_unique_key',
            j ->> 'pendampingan_unique_key',
            j ->> 'id_tim',
            j ->> 'id_kecamatan',
            j ->> 'jenis_sasaran'
          )) LIKE '%' || v_search || '%'
        )
    ),
    counted AS (
      SELECT COUNT(*)::integer AS total_count
      FROM filtered
    ),
    paged AS (
      SELECT j
      FROM filtered
      ORDER BY
        COALESCE(j ->> 'tanggal_pendampingan', ''),
        COALESCE(j ->> 'nama_sasaran', ''),
        COALESCE(j ->> 'pendampingan_unique_key', '')
      LIMIT v_limit
      OFFSET v_offset
    )
    SELECT jsonb_build_object(
      'ok', true,
      'contract_version', public.tpk_query_contract_version_7f(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'data', COALESCE((SELECT jsonb_agg(j) FROM paged), '[]'::jsonb),
      'meta', jsonb_build_object(
        'total_count', (SELECT total_count FROM counted),
        'limit', v_limit,
        'offset', v_offset,
        'filters', jsonb_strip_nulls(jsonb_build_object(
          'id_kecamatan', v_id_kecamatan,
          'id_tim', v_id_tim,
          'periode_bulan', v_periode_bulan,
          'tahun_laporan', p_tahun_laporan,
          'jenis_sasaran', v_jenis,
          'is_baduta_prioritas_saat_pendampingan', p_is_baduta_prioritas_saat_pendampingan,
          'search', v_search
        ))
      )
    )
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_production_basic_summary_7f()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_summary_tim jsonb := '[]'::jsonb;
  v_summary_kecamatan jsonb := '[]'::jsonb;
  v_summary_pendampingan_tim jsonb := '[]'::jsonb;
  v_summary_pendampingan_kecamatan jsonb := '[]'::jsonb;
BEGIN
  SELECT COALESCE(jsonb_agg(to_jsonb(v) ORDER BY to_jsonb(v) ->> 'id_tim'), '[]'::jsonb)
  INTO v_summary_tim
  FROM public.v_summary_tim_basic_7er1 v;

  SELECT COALESCE(jsonb_agg(to_jsonb(v) ORDER BY to_jsonb(v) ->> 'id_kecamatan'), '[]'::jsonb)
  INTO v_summary_kecamatan
  FROM public.v_summary_kecamatan_basic_7er1 v;

  SELECT COALESCE(jsonb_agg(to_jsonb(v) ORDER BY to_jsonb(v) ->> 'id_tim'), '[]'::jsonb)
  INTO v_summary_pendampingan_tim
  FROM public.v_summary_pendampingan_tim_basic_7er1 v;

  SELECT COALESCE(jsonb_agg(to_jsonb(v) ORDER BY to_jsonb(v) ->> 'id_kecamatan'), '[]'::jsonb)
  INTO v_summary_pendampingan_kecamatan
  FROM public.v_summary_pendampingan_kecamatan_basic_7er1 v;

  RETURN jsonb_build_object(
    'ok', true,
    'contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'data', jsonb_build_object(
      'summary_tim', v_summary_tim,
      'summary_kecamatan', v_summary_kecamatan,
      'summary_pendampingan_tim', v_summary_pendampingan_tim,
      'summary_pendampingan_kecamatan', v_summary_pendampingan_kecamatan
    ),
    'summary_tim', v_summary_tim,
    'summary_kecamatan', v_summary_kecamatan,
    'summary_pendampingan_tim', v_summary_pendampingan_tim,
    'summary_pendampingan_kecamatan', v_summary_pendampingan_kecamatan
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.check_production_query_contract_health_7f()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_public_views_without_security_invoker integer := 0;
  v_legacy_baduta integer := 0;
  v_sasaran_rows integer := 0;
  v_pendampingan_rows integer := 0;
  v_summary_tim_rows integer := 0;
  v_summary_kecamatan_rows integer := 0;
  v_has_total_baduta_columns integer := 0;
BEGIN
  SELECT COUNT(*)::integer
  INTO v_public_views_without_security_invoker
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'v'
    AND NOT (COALESCE(c.reloptions, ARRAY[]::text[]) @> ARRAY['security_invoker=true']);

  SELECT COUNT(*)::integer
  INTO v_legacy_baduta
  FROM public.v_sasaran_lite_7er1 v
  WHERE to_jsonb(v) ->> 'jenis_sasaran' = 'BADUTA';

  SELECT COUNT(*)::integer INTO v_sasaran_rows FROM public.v_sasaran_lite_7er1;
  SELECT COUNT(*)::integer INTO v_pendampingan_rows FROM public.v_pendampingan_lite_7er1;
  SELECT COUNT(*)::integer INTO v_summary_tim_rows FROM public.v_summary_tim_basic_7er1;
  SELECT COUNT(*)::integer INTO v_summary_kecamatan_rows FROM public.v_summary_kecamatan_basic_7er1;

  SELECT COUNT(*)::integer
  INTO v_has_total_baduta_columns
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('v_summary_tim_basic_7er1', 'v_summary_kecamatan_basic_7er1')
    AND column_name = 'total_baduta';

  RETURN jsonb_build_object(
    'ok',
      (
        v_public_views_without_security_invoker = 0
        AND v_legacy_baduta = 0
        AND v_has_total_baduta_columns = 0
      ),
    'contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'checks', jsonb_build_object(
      'public_views_without_security_invoker', v_public_views_without_security_invoker,
      'legacy_baduta_rows', v_legacy_baduta,
      'summary_total_baduta_columns', v_has_total_baduta_columns,
      'sasaran_lite_rows', v_sasaran_rows,
      'pendampingan_lite_rows', v_pendampingan_rows,
      'summary_tim_rows', v_summary_tim_rows,
      'summary_kecamatan_rows', v_summary_kecamatan_rows
    )
  );
END;
$$;

COMMIT;
