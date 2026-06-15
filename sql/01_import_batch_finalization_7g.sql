-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G
-- Migration 01: Production Import Batch Finalization
-- ============================================================
-- Tujuan:
-- 1. Mengunci helper finalisasi batch import/promote production.
-- 2. Membaca state staging, dry-run, production, dan error log secara aman.
-- 3. Menyediakan envelope JSON stabil untuk pengecekan finalisasi batch.
-- 4. Tidak mengubah RLS/policy dan tidak membuka akses frontend.
-- 5. Semua function diberi SET search_path untuk menghindari Function Search Path Mutable.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.tpk_import_bridge_version_7g()
RETURNS text
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT 'TPK_IMPORT_BRIDGE_2026_7G'::text;
$$;

CREATE OR REPLACE FUNCTION public.tpk_table_exists_7g(p_table_name text)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT to_regclass(p_table_name) IS NOT NULL;
$$;

CREATE OR REPLACE FUNCTION public.tpk_column_exists_7g(
  p_schema_name text,
  p_table_name text,
  p_column_name text
)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns c
    WHERE c.table_schema = p_schema_name
      AND c.table_name = p_table_name
      AND c.column_name = p_column_name
  );
$$;

CREATE OR REPLACE FUNCTION public.tpk_count_rows_by_any_json_key_7g(
  p_table_name text,
  p_keys text[],
  p_value text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_table regclass;
  v_condition text;
  v_count integer := 0;
BEGIN
  IF NULLIF(BTRIM(COALESCE(p_table_name, '')), '') IS NULL
     OR p_keys IS NULL
     OR array_length(p_keys, 1) IS NULL
     OR NULLIF(BTRIM(COALESCE(p_value, '')), '') IS NULL THEN
    RETURN 0;
  END IF;

  v_table := to_regclass(p_table_name);
  IF v_table IS NULL THEN
    RETURN 0;
  END IF;

  SELECT string_agg(format('to_jsonb(t)->>%L = $1', k), ' OR ')
  INTO v_condition
  FROM unnest(p_keys) AS k;

  IF NULLIF(v_condition, '') IS NULL THEN
    RETURN 0;
  END IF;

  EXECUTE format('SELECT COUNT(*)::integer FROM %s t WHERE %s', v_table, v_condition)
  INTO v_count
  USING p_value;

  RETURN COALESCE(v_count, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.tpk_import_batch_key_column_7g(p_table_name text DEFAULT 'public.import_batch')
RETURNS text
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_schema text;
  v_table text;
BEGIN
  IF to_regclass(p_table_name) IS NULL THEN
    RETURN NULL;
  END IF;

  v_schema := split_part(p_table_name, '.', 1);
  v_table := split_part(p_table_name, '.', 2);

  IF v_schema = '' OR v_table = '' THEN
    RETURN NULL;
  END IF;

  IF public.tpk_column_exists_7g(v_schema, v_table, 'import_batch_id') THEN
    RETURN 'import_batch_id';
  END IF;
  IF public.tpk_column_exists_7g(v_schema, v_table, 'batch_id') THEN
    RETURN 'batch_id';
  END IF;
  IF public.tpk_column_exists_7g(v_schema, v_table, 'id') THEN
    RETURN 'id';
  END IF;

  RETURN NULL;
END;
$$;

ALTER TABLE IF EXISTS public.import_batch
  ADD COLUMN IF NOT EXISTS finalization_status text,
  ADD COLUMN IF NOT EXISTS finalization_checked_at timestamptz,
  ADD COLUMN IF NOT EXISTS finalization_metadata jsonb,
  ADD COLUMN IF NOT EXISTS finalized_at timestamptz,
  ADD COLUMN IF NOT EXISTS finalized_by text,
  ADD COLUMN IF NOT EXISTS selective_export_batch_id text,
  ADD COLUMN IF NOT EXISTS query_contract_version text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

CREATE OR REPLACE FUNCTION public.check_import_batch_finalization_7g(p_import_batch_id text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_batch_id text := NULLIF(BTRIM(COALESCE(p_import_batch_id, '')), '');
  v_staging_sasaran integer := 0;
  v_staging_pendampingan integer := 0;
  v_dryrun_sasaran integer := 0;
  v_dryrun_pendampingan integer := 0;
  v_production_sasaran integer := 0;
  v_production_pendampingan integer := 0;
  v_import_errors integer := 0;
  v_promote_errors integer := 0;
  v_production_promote_errors integer := 0;
  v_status text;
  v_has_errors boolean;
  v_has_rows boolean;
BEGIN
  IF v_batch_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'errors', jsonb_build_array(jsonb_build_object(
        'field', 'import_batch_id',
        'code', 'IMPORT_BATCH_ID_REQUIRED',
        'message', 'import_batch_id wajib diisi untuk finalisasi batch.'
      ))
    );
  END IF;

  v_staging_sasaran := public.tpk_count_rows_by_any_json_key_7g(
    'public.staging_sasaran_import', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_staging_pendampingan := public.tpk_count_rows_by_any_json_key_7g(
    'public.staging_pendampingan_import', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_dryrun_sasaran := public.tpk_count_rows_by_any_json_key_7g(
    'public.dryrun_sasaran', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_dryrun_pendampingan := public.tpk_count_rows_by_any_json_key_7g(
    'public.dryrun_pendampingan', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_production_sasaran := public.tpk_count_rows_by_any_json_key_7g(
    'public.sasaran', ARRAY['import_batch_id', 'batch_id', 'source_import_batch_id', 'backfill_import_batch_id'], v_batch_id
  );
  v_production_pendampingan := public.tpk_count_rows_by_any_json_key_7g(
    'public.pendampingan', ARRAY['import_batch_id', 'batch_id', 'source_import_batch_id', 'backfill_import_batch_id'], v_batch_id
  );
  v_import_errors := public.tpk_count_rows_by_any_json_key_7g(
    'public.import_error', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_promote_errors := public.tpk_count_rows_by_any_json_key_7g(
    'public.promote_error', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );
  v_production_promote_errors := public.tpk_count_rows_by_any_json_key_7g(
    'public.production_promote_error', ARRAY['import_batch_id', 'batch_id'], v_batch_id
  );

  v_has_errors := (v_import_errors + v_promote_errors + v_production_promote_errors) > 0;
  v_has_rows := (v_staging_sasaran + v_staging_pendampingan + v_dryrun_sasaran + v_dryrun_pendampingan + v_production_sasaran + v_production_pendampingan) > 0;

  v_status := CASE
    WHEN v_has_errors THEN 'BLOCKED_BY_ERRORS'
    WHEN (v_production_sasaran + v_production_pendampingan) > 0 THEN 'PRODUCTION_PROMOTED'
    WHEN (v_dryrun_sasaran + v_dryrun_pendampingan) > 0 THEN 'DRYRUN_READY'
    WHEN (v_staging_sasaran + v_staging_pendampingan) > 0 THEN 'STAGING_IMPORTED'
    ELSE 'NO_BATCH_ROWS_FOUND'
  END;

  RETURN jsonb_build_object(
    'ok', NOT v_has_errors AND v_has_rows,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'import_batch_id', v_batch_id,
    'finalization_status', v_status,
    'checks', jsonb_build_object(
      'staging_sasaran_rows', v_staging_sasaran,
      'staging_pendampingan_rows', v_staging_pendampingan,
      'dryrun_sasaran_rows', v_dryrun_sasaran,
      'dryrun_pendampingan_rows', v_dryrun_pendampingan,
      'production_sasaran_rows', v_production_sasaran,
      'production_pendampingan_rows', v_production_pendampingan,
      'import_error_rows', v_import_errors,
      'promote_error_rows', v_promote_errors,
      'production_promote_error_rows', v_production_promote_errors,
      'has_rows', v_has_rows,
      'has_errors', v_has_errors
    )
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.finalize_backfill_import_batch_7g(p_payload jsonb)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_payload jsonb := COALESCE(p_payload, '{}'::jsonb);
  v_batch_id text := NULLIF(BTRIM(COALESCE(v_payload ->> 'import_batch_id', '')), '');
  v_export_batch_id text := NULLIF(BTRIM(COALESCE(v_payload ->> 'export_batch_id', v_payload ->> 'selective_export_batch_id', '')), '');
  v_actor text := NULLIF(BTRIM(COALESCE(v_payload ->> 'finalized_by', v_payload ->> 'actor', 'postgres')), '');
  v_force boolean := COALESCE(NULLIF(v_payload ->> 'force', '')::boolean, false);
  v_check jsonb;
  v_has_errors boolean;
  v_has_rows boolean;
  v_status text;
  v_key_col text;
  v_rows_updated integer := 0;
BEGIN
  IF v_batch_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'errors', jsonb_build_array(jsonb_build_object(
        'field', 'import_batch_id',
        'code', 'IMPORT_BATCH_ID_REQUIRED',
        'message', 'import_batch_id wajib diisi untuk finalisasi batch.'
      ))
    );
  END IF;

  v_check := public.check_import_batch_finalization_7g(v_batch_id);
  v_has_errors := COALESCE((v_check #>> '{checks,has_errors}')::boolean, false);
  v_has_rows := COALESCE((v_check #>> '{checks,has_rows}')::boolean, false);
  v_status := COALESCE(v_check ->> 'finalization_status', 'UNKNOWN');

  IF v_has_errors AND NOT v_force THEN
    RETURN jsonb_build_object(
      'ok', false,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'import_batch_id', v_batch_id,
      'finalization_status', v_status,
      'errors', jsonb_build_array(jsonb_build_object(
        'field', 'import_batch_id',
        'code', 'FINALIZATION_BLOCKED_ERRORS_EXIST',
        'message', 'Batch masih memiliki error import/promote. Perbaiki atau jalankan dengan force=true hanya untuk kebutuhan administratif.'
      )),
      'check', v_check
    );
  END IF;

  IF NOT v_has_rows AND NOT v_force THEN
    RETURN jsonb_build_object(
      'ok', false,
      'contract_version', public.tpk_import_bridge_version_7g(),
      'taxonomy_version', public.tpk_taxonomy_version_7er1(),
      'import_batch_id', v_batch_id,
      'finalization_status', v_status,
      'errors', jsonb_build_array(jsonb_build_object(
        'field', 'import_batch_id',
        'code', 'FINALIZATION_BLOCKED_NO_ROWS',
        'message', 'Tidak ditemukan row staging/dry-run/production untuk import_batch_id ini.'
      )),
      'check', v_check
    );
  END IF;

  v_key_col := public.tpk_import_batch_key_column_7g('public.import_batch');

  IF v_key_col IS NOT NULL THEN
    EXECUTE format(
      'UPDATE public.import_batch
       SET finalization_status = $2,
           finalization_checked_at = now(),
           finalization_metadata = $3,
           finalized_at = now(),
           finalized_by = $4,
           selective_export_batch_id = COALESCE($5, selective_export_batch_id),
           query_contract_version = public.tpk_query_contract_version_7f(),
           taxonomy_version = public.tpk_taxonomy_version_7er1()
       WHERE %I = $1',
      v_key_col
    )
    USING v_batch_id, v_status, v_check, COALESCE(v_actor, 'postgres'), v_export_batch_id;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'query_contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'import_batch_id', v_batch_id,
    'export_batch_id', v_export_batch_id,
    'finalization_status', v_status,
    'import_batch_rows_updated', v_rows_updated,
    'import_batch_key_column', v_key_col,
    'check', v_check
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.check_import_finalization_health_7g()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_public_views_without_security_invoker integer := 0;
BEGIN
  SELECT COUNT(*)::integer
  INTO v_public_views_without_security_invoker
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'v'
    AND NOT (COALESCE(c.reloptions, ARRAY[]::text[]) @> ARRAY['security_invoker=true']::text[]);

  RETURN jsonb_build_object(
    'ok', true,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'query_contract_version', public.tpk_query_contract_version_7f(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'checks', jsonb_build_object(
      'import_batch_table_exists', public.tpk_table_exists_7g('public.import_batch'),
      'staging_sasaran_import_table_exists', public.tpk_table_exists_7g('public.staging_sasaran_import'),
      'staging_pendampingan_import_table_exists', public.tpk_table_exists_7g('public.staging_pendampingan_import'),
      'dryrun_sasaran_table_exists', public.tpk_table_exists_7g('public.dryrun_sasaran'),
      'dryrun_pendampingan_table_exists', public.tpk_table_exists_7g('public.dryrun_pendampingan'),
      'production_sasaran_table_exists', public.tpk_table_exists_7g('public.sasaran'),
      'production_pendampingan_table_exists', public.tpk_table_exists_7g('public.pendampingan'),
      'import_batch_key_column', public.tpk_import_batch_key_column_7g('public.import_batch'),
      'public_views_without_security_invoker', v_public_views_without_security_invoker
    )
  );
END;
$$;

COMMIT;
