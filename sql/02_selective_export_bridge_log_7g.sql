-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G
-- Migration 02: Selective Export Bridge Log
-- ============================================================
-- Tujuan:
-- 1. Menyediakan log internal untuk manifest selective export dari Apps Script.
-- 2. Menghubungkan export_batch_id BACKFILL dengan import_batch_id Supabase.
-- 3. Menggunakan schema backfill_internal agar tidak membuka table baru ke frontend/public REST.
-- 4. Tidak mengubah RLS/policy pada public schema.
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS backfill_internal;

CREATE TABLE IF NOT EXISTS backfill_internal.selective_export_bridge_log (
  export_bridge_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  export_batch_id text NOT NULL UNIQUE,
  import_batch_id text,
  kode_kecamatan text,
  source_workbook text,
  source_sheet text,
  source_table text,
  export_scope text,
  selected_row_count integer NOT NULL DEFAULT 0,
  selected_record_keys jsonb NOT NULL DEFAULT '[]'::jsonb,
  manifest jsonb NOT NULL DEFAULT '{}'::jsonb,
  checksum_sha256 text,
  contract_version text NOT NULL DEFAULT public.tpk_import_bridge_version_7g(),
  query_contract_version text NOT NULL DEFAULT public.tpk_query_contract_version_7f(),
  taxonomy_version text NOT NULL DEFAULT public.tpk_taxonomy_version_7er1(),
  status text NOT NULL DEFAULT 'REGISTERED',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  finalized_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_selective_export_bridge_log_import_batch_id
  ON backfill_internal.selective_export_bridge_log(import_batch_id);

CREATE INDEX IF NOT EXISTS idx_selective_export_bridge_log_kode_kecamatan
  ON backfill_internal.selective_export_bridge_log(kode_kecamatan);

CREATE OR REPLACE FUNCTION public.register_selective_export_bridge_7g(p_payload jsonb)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SET search_path = public, backfill_internal, pg_temp
AS $$
DECLARE
  v_payload jsonb := COALESCE(p_payload, '{}'::jsonb);
  v_export_batch_id text := NULLIF(BTRIM(COALESCE(v_payload ->> 'export_batch_id', '')), '');
  v_import_batch_id text := NULLIF(BTRIM(COALESCE(v_payload ->> 'import_batch_id', '')), '');
  v_row_count integer := COALESCE(NULLIF(v_payload ->> 'selected_row_count', '')::integer, 0);
  v_manifest jsonb := COALESCE(v_payload -> 'manifest', v_payload, '{}'::jsonb);
  v_keys jsonb := COALESCE(v_payload -> 'selected_record_keys', '[]'::jsonb);
BEGIN
  IF v_export_batch_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'errors', jsonb_build_array(jsonb_build_object(
        'field', 'export_batch_id',
        'code', 'EXPORT_BATCH_ID_REQUIRED',
        'message', 'export_batch_id wajib diisi untuk bridge selective export.'
      ))
    );
  END IF;

  INSERT INTO backfill_internal.selective_export_bridge_log (
    export_batch_id,
    import_batch_id,
    kode_kecamatan,
    source_workbook,
    source_sheet,
    source_table,
    export_scope,
    selected_row_count,
    selected_record_keys,
    manifest,
    checksum_sha256,
    status,
    updated_at
  ) VALUES (
    v_export_batch_id,
    v_import_batch_id,
    NULLIF(BTRIM(COALESCE(v_payload ->> 'kode_kecamatan', '')), ''),
    NULLIF(BTRIM(COALESCE(v_payload ->> 'source_workbook', '')), ''),
    NULLIF(BTRIM(COALESCE(v_payload ->> 'source_sheet', '')), ''),
    NULLIF(BTRIM(COALESCE(v_payload ->> 'source_table', '')), ''),
    NULLIF(BTRIM(COALESCE(v_payload ->> 'export_scope', '')), ''),
    GREATEST(v_row_count, 0),
    v_keys,
    v_manifest,
    NULLIF(BTRIM(COALESCE(v_payload ->> 'checksum_sha256', '')), ''),
    COALESCE(NULLIF(BTRIM(v_payload ->> 'status'), ''), 'REGISTERED'),
    now()
  )
  ON CONFLICT (export_batch_id) DO UPDATE SET
    import_batch_id = COALESCE(EXCLUDED.import_batch_id, backfill_internal.selective_export_bridge_log.import_batch_id),
    kode_kecamatan = COALESCE(EXCLUDED.kode_kecamatan, backfill_internal.selective_export_bridge_log.kode_kecamatan),
    source_workbook = COALESCE(EXCLUDED.source_workbook, backfill_internal.selective_export_bridge_log.source_workbook),
    source_sheet = COALESCE(EXCLUDED.source_sheet, backfill_internal.selective_export_bridge_log.source_sheet),
    source_table = COALESCE(EXCLUDED.source_table, backfill_internal.selective_export_bridge_log.source_table),
    export_scope = COALESCE(EXCLUDED.export_scope, backfill_internal.selective_export_bridge_log.export_scope),
    selected_row_count = EXCLUDED.selected_row_count,
    selected_record_keys = EXCLUDED.selected_record_keys,
    manifest = EXCLUDED.manifest,
    checksum_sha256 = COALESCE(EXCLUDED.checksum_sha256, backfill_internal.selective_export_bridge_log.checksum_sha256),
    status = EXCLUDED.status,
    updated_at = now();

  RETURN jsonb_build_object(
    'ok', true,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'query_contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'export_batch_id', v_export_batch_id,
    'import_batch_id', v_import_batch_id,
    'status', COALESCE(NULLIF(BTRIM(v_payload ->> 'status'), ''), 'REGISTERED')
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_selective_export_bridge_log_7g(p_export_batch_id text DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, backfill_internal, pg_temp
AS $$
DECLARE
  v_export_batch_id text := NULLIF(BTRIM(COALESCE(p_export_batch_id, '')), '');
BEGIN
  RETURN (
    WITH src AS (
      SELECT to_jsonb(l) AS j
      FROM backfill_internal.selective_export_bridge_log l
      WHERE v_export_batch_id IS NULL OR l.export_batch_id = v_export_batch_id
      ORDER BY l.created_at DESC
      LIMIT 50
    )
    SELECT jsonb_build_object(
      'ok', true,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'data', COALESCE(jsonb_agg(j), '[]'::jsonb)
    )
    FROM src
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.check_selective_export_bridge_health_7g()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, backfill_internal, pg_temp
AS $$
DECLARE
  v_log_rows integer := 0;
BEGIN
  SELECT COUNT(*)::integer INTO v_log_rows
  FROM backfill_internal.selective_export_bridge_log;

  RETURN jsonb_build_object(
    'ok', true,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'query_contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'checks', jsonb_build_object(
      'internal_schema_exists', to_regnamespace('backfill_internal') IS NOT NULL,
      'bridge_log_table_exists', to_regclass('backfill_internal.selective_export_bridge_log') IS NOT NULL,
      'bridge_log_rows', v_log_rows
    )
  );
END;
$$;

COMMIT;
