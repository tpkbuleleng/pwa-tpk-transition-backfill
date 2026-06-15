-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G-R1
-- Migration 05: Selective Sasaran CSV Raw Import Bridge
-- ============================================================
-- Tujuan:
-- 1. Menyediakan tabel raw internal dengan header sama persis seperti
--    CSV hasil selective export Apps Script 7-G untuk staging_sasaran.
-- 2. CSV selective export TIDAK diimpor langsung ke public.staging_sasaran_import,
--    karena header table import Supabase memiliki metadata internal berbeda.
-- 3. Raw table ini menjadi jembatan: CSV -> raw internal -> staging_sasaran_import.
-- 4. Aman dijalankan berulang.
-- 5. Tidak mengubah public RLS/policy/frontend.
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS backfill_internal;

CREATE TABLE IF NOT EXISTS backfill_internal.selective_sasaran_export_raw_7g (
  record_id text,
  client_mutation_id text,
  source_mode text,
  app_version text,
  import_batch_id text,
  id_kecamatan text,
  kode_kecamatan text,
  nama_kecamatan text,
  id_tim text,
  nomor_tim text,
  nama_tim text,
  id_kader text,
  nama_kader text,
  id_wilayah text,
  desa_kelurahan text,
  dusun_rw text,
  jenis_sasaran text,
  nik text,
  no_kk text,
  nama_sasaran text,
  jenis_kelamin text,
  tanggal_lahir text,
  usia_bulan text,
  alamat_lengkap text,
  nama_kepala_keluarga text,
  nama_ibu_kandung text,
  status_krs text,
  sumber_air_minum_utama text,
  fasilitas_bab text,
  nik_pasangan text,
  nama_pasangan text,
  kabupaten_pasangan text,
  kecamatan_pasangan text,
  desa_pasangan text,
  dusun_pasangan text,
  domisili_setelah_menikah text,
  usia_kehamilan_minggu text,
  bb_sebelum_hamil_kg text,
  kehamilan_diinginkan text,
  tanggal_melahirkan text,
  jenis_persalinan text,
  bb_lahir_kg text,
  pb_lahir_cm text,
  form_id text,
  form_version text,
  sasaran_unique_key text,
  unique_key_strategy text,
  needs_review text,
  review_reason text,
  form_answers_json text,
  raw_payload_json text,
  created_at_client text,
  submitted_at_server text,
  created_by text,
  updated_at text,
  is_deleted text,
  catatan text
);

ALTER TABLE backfill_internal.selective_sasaran_export_raw_7g ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE backfill_internal.selective_sasaran_export_raw_7g IS
  'Raw internal bridge untuk CSV selective export sasaran 7-G. Header sengaja sama dengan CSV Apps Script, bukan header public.staging_sasaran_import.';

CREATE OR REPLACE FUNCTION public.tpk_7g_jsonb_blank_to_null(p_json jsonb)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    jsonb_object_agg(
      key,
      CASE
        WHEN value = '""'::jsonb THEN 'null'::jsonb
        ELSE value
      END
    ),
    '{}'::jsonb
  )
  FROM jsonb_each(COALESCE(p_json, '{}'::jsonb));
$$;

CREATE OR REPLACE FUNCTION public.check_selective_sasaran_raw_bridge_health_7g()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path = public, backfill_internal, pg_temp
AS $$
DECLARE
  v_raw_exists boolean;
  v_target_exists boolean;
  v_log_exists boolean;
  v_raw_rows integer;
  v_baduta_rows integer;
BEGIN
  SELECT to_regclass('backfill_internal.selective_sasaran_export_raw_7g') IS NOT NULL INTO v_raw_exists;
  SELECT to_regclass('public.staging_sasaran_import') IS NOT NULL INTO v_target_exists;
  SELECT to_regclass('backfill_internal.selective_export_bridge_log') IS NOT NULL INTO v_log_exists;

  IF v_raw_exists THEN
    SELECT COUNT(*)::integer INTO v_raw_rows
    FROM backfill_internal.selective_sasaran_export_raw_7g;

    SELECT COUNT(*)::integer INTO v_baduta_rows
    FROM backfill_internal.selective_sasaran_export_raw_7g
    WHERE upper(coalesce(jenis_sasaran, '')) = 'BADUTA';
  ELSE
    v_raw_rows := NULL;
    v_baduta_rows := NULL;
  END IF;

  RETURN jsonb_build_object(
    'ok', v_raw_exists AND v_target_exists AND v_log_exists,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'checks', jsonb_build_object(
      'raw_table_exists', v_raw_exists,
      'target_staging_sasaran_import_exists', v_target_exists,
      'selective_export_bridge_log_exists', v_log_exists,
      'raw_rows', v_raw_rows,
      'raw_baduta_rows', v_baduta_rows
    )
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.load_selective_sasaran_raw_to_staging_7g(
  p_export_batch_id text,
  p_import_batch_id text DEFAULT NULL,
  p_reject_legacy_baduta boolean DEFAULT true,
  p_clear_raw_after_load boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path = public, backfill_internal, pg_temp
AS $$
DECLARE
  v_manifest jsonb;
  v_record_keys text[];
  v_import_batch_id text;
  v_raw_total integer;
  v_raw_selected integer;
  v_baduta_count integer;
  v_insert_cols text;
  v_select_cols text;
  v_insert_sql text;
  v_loaded_count integer := 0;
BEGIN
  p_export_batch_id := nullif(trim(coalesce(p_export_batch_id, '')), '');
  p_import_batch_id := nullif(trim(coalesce(p_import_batch_id, '')), '');

  IF p_export_batch_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'EXPORT_BATCH_ID_REQUIRED',
      'message', 'p_export_batch_id wajib diisi.'
    );
  END IF;

  SELECT manifest
  INTO v_manifest
  FROM backfill_internal.selective_export_bridge_log
  WHERE export_batch_id = p_export_batch_id;

  IF v_manifest IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'EXPORT_BATCH_NOT_REGISTERED',
      'message', 'export_batch_id belum terdaftar di selective_export_bridge_log.',
      'export_batch_id', p_export_batch_id
    );
  END IF;

  IF coalesce(v_manifest ->> 'source_table', '') <> 'sasaran' THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'SOURCE_TABLE_NOT_SASARAN',
      'message', 'Function ini khusus selective export sasaran.',
      'source_table', v_manifest ->> 'source_table'
    );
  END IF;

  SELECT COALESCE(array_agg(value), ARRAY[]::text[])
  INTO v_record_keys
  FROM jsonb_array_elements_text(coalesce(v_manifest -> 'selected_record_keys', '[]'::jsonb)) AS value;

  IF array_length(v_record_keys, 1) IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'MANIFEST_RECORD_KEYS_EMPTY',
      'message', 'Manifest tidak memiliki selected_record_keys.'
    );
  END IF;

  v_import_batch_id := COALESCE(
    p_import_batch_id,
    'IMP7G_' || regexp_replace(p_export_batch_id, '^EXP7G_', '')
  );

  SELECT COUNT(*)::integer
  INTO v_raw_total
  FROM backfill_internal.selective_sasaran_export_raw_7g;

  SELECT COUNT(*)::integer
  INTO v_raw_selected
  FROM backfill_internal.selective_sasaran_export_raw_7g
  WHERE sasaran_unique_key = ANY(v_record_keys);

  IF v_raw_selected = 0 THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'NO_RAW_ROWS_MATCH_MANIFEST',
      'message', 'Tidak ada row raw yang cocok dengan selected_record_keys manifest. Pastikan CSV sudah diimpor ke backfill_internal.selective_sasaran_export_raw_7g.',
      'export_batch_id', p_export_batch_id,
      'raw_total_rows', v_raw_total,
      'manifest_key_count', array_length(v_record_keys, 1)
    );
  END IF;

  SELECT COUNT(*)::integer
  INTO v_baduta_count
  FROM backfill_internal.selective_sasaran_export_raw_7g
  WHERE sasaran_unique_key = ANY(v_record_keys)
    AND upper(coalesce(jenis_sasaran, '')) = 'BADUTA';

  IF p_reject_legacy_baduta AND v_baduta_count > 0 THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'BADUTA_LEGACY_ROWS_FOUND',
      'message', 'CSV selective export masih memuat jenis_sasaran=BADUTA. Sesuai 7-E-R1, BADUTA tidak boleh diimpor sebagai input baru. Re-export hanya record valid atau jalankan cleanup/migration legacy terlebih dahulu.',
      'export_batch_id', p_export_batch_id,
      'baduta_rows', v_baduta_count,
      'raw_selected_rows', v_raw_selected
    );
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.staging_sasaran_import
    WHERE import_batch_id = v_import_batch_id
  ) THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'IMPORT_BATCH_ALREADY_EXISTS',
      'message', 'import_batch_id sudah ada di staging_sasaran_import. Gunakan import_batch_id baru atau purge batch uji terlebih dahulu.',
      'import_batch_id', v_import_batch_id
    );
  END IF;

  -- Ambil kolom target yang aman diisi: kolom yang ada di target staging dan tersedia
  -- dari JSON raw/metadata. Kolom identity/generated/default seperti staging_row_id
  -- dibiarkan memakai default table.
  WITH target_cols AS (
    SELECT c.column_name, c.ordinal_position
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.table_name = 'staging_sasaran_import'
      AND c.column_name NOT IN ('staging_row_id')
      AND COALESCE(c.is_generated, 'NEVER') = 'NEVER'
      AND COALESCE(c.is_identity, 'NO') = 'NO'
  ), raw_cols AS (
    SELECT c.column_name
    FROM information_schema.columns c
    WHERE c.table_schema = 'backfill_internal'
      AND c.table_name = 'selective_sasaran_export_raw_7g'
  ), allowed_cols AS (
    SELECT t.column_name, t.ordinal_position
    FROM target_cols t
    WHERE t.column_name IN (SELECT column_name FROM raw_cols)
       OR t.column_name IN ('loaded_at', 'validation_status', 'import_batch_id')
  )
  SELECT
    string_agg(format('%I', column_name), ', ' ORDER BY ordinal_position),
    string_agg(format('(rec).%I', column_name), ', ' ORDER BY ordinal_position)
  INTO v_insert_cols, v_select_cols
  FROM allowed_cols;

  IF v_insert_cols IS NULL OR v_select_cols IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'code', 'NO_COMPATIBLE_TARGET_COLUMNS',
      'message', 'Tidak ada kolom kompatibel antara raw table dan staging_sasaran_import.'
    );
  END IF;

  v_insert_sql := format($fmt$
    WITH source_rows AS (
      SELECT public.tpk_7g_jsonb_blank_to_null(
        to_jsonb(r)
        || jsonb_build_object(
          'import_batch_id', %L,
          'loaded_at', now(),
          'validation_status', 'pending'
        )
      ) AS js
      FROM backfill_internal.selective_sasaran_export_raw_7g r
      WHERE r.sasaran_unique_key = ANY($1)
    ), typed_rows AS (
      SELECT jsonb_populate_record(NULL::public.staging_sasaran_import, js) AS rec
      FROM source_rows
    )
    INSERT INTO public.staging_sasaran_import (%s)
    SELECT %s
    FROM typed_rows
  $fmt$, v_import_batch_id, v_insert_cols, v_select_cols);

  EXECUTE v_insert_sql USING v_record_keys;
  GET DIAGNOSTICS v_loaded_count = ROW_COUNT;

  UPDATE backfill_internal.selective_sasaran_export_raw_7g
  SET import_batch_id = v_import_batch_id
  WHERE sasaran_unique_key = ANY(v_record_keys);

  UPDATE backfill_internal.selective_export_bridge_log
  SET import_batch_id = v_import_batch_id
  WHERE export_batch_id = p_export_batch_id;

  IF p_clear_raw_after_load THEN
    DELETE FROM backfill_internal.selective_sasaran_export_raw_7g
    WHERE sasaran_unique_key = ANY(v_record_keys);
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'status', 'LOADED_TO_STAGING',
    'export_batch_id', p_export_batch_id,
    'import_batch_id', v_import_batch_id,
    'raw_selected_rows', v_raw_selected,
    'loaded_rows', v_loaded_count,
    'baduta_rows', v_baduta_count,
    'contract_version', public.tpk_import_bridge_version_7g(),
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'next_step', 'Jalankan validate_backfill_import_batch(import_batch_id) sesuai pipeline 7-A.'
  );
END;
$$;

COMMIT;
