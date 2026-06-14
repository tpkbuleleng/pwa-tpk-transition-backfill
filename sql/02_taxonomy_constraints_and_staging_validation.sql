-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1 — Sasaran Taxonomy Realignment
-- Migration 02: Constraints + staging validation helper
-- ============================================================
-- BADUTA ditolak sebagai jenis_sasaran input baru.
-- Constraint dibuat NOT VALID agar data lama tidak langsung memblokir migration,
-- tetapi row baru tetap dicek.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_table regclass;
  v_table_name text;
  v_constraint text;
BEGIN
  FOREACH v_table_name IN ARRAY ARRAY[
    'public.staging_sasaran_import',
    'public.staging_pendampingan_import',
    'public.dryrun_sasaran',
    'public.dryrun_pendampingan',
    'public.sasaran',
    'public.pendampingan'
  ] LOOP
    v_table := to_regclass(v_table_name);

    IF v_table IS NOT NULL
       AND EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_schema = split_part(v_table_name, '.', 1)
            AND table_name = split_part(v_table_name, '.', 2)
            AND column_name = 'jenis_sasaran'
       ) THEN
      v_constraint := 'chk_' || replace(split_part(v_table_name, '.', 2), '.', '_') || '_jenis_sasaran_7er1';

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = v_table
          AND conname = v_constraint
      ) THEN
        EXECUTE format(
          'ALTER TABLE %s ADD CONSTRAINT %I CHECK (jenis_sasaran IS NULL OR public.tpk_norm_jenis_sasaran_7er1(jenis_sasaran::text) IN (''CATIN'', ''BUMIL'', ''BUFAS'', ''BALITA'')) NOT VALID',
          v_table_name,
          v_constraint
        );
      END IF;
    END IF;
  END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.validate_backfill_import_batch_taxonomy_7er1(
  p_import_batch_id text DEFAULT NULL
)
RETURNS TABLE (
  source_table text,
  record_type text,
  import_batch_id text,
  record_key text,
  error_code text,
  error_message text,
  derived jsonb
)
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF to_regclass('public.staging_sasaran_import') IS NOT NULL THEN
    RETURN QUERY
    WITH src AS (
      SELECT to_jsonb(s) AS row_data
      FROM public.staging_sasaran_import s
      WHERE p_import_batch_id IS NULL
         OR to_jsonb(s) ->> 'import_batch_id' = p_import_batch_id
    ), derived AS (
      SELECT
        row_data,
        public.tpk_norm_jenis_sasaran_7er1(row_data ->> 'jenis_sasaran') AS jenis,
        public.tpk_first_date_from_json_7er1(row_data, ARRAY['tanggal_lahir'], NULL) AS tanggal_lahir,
        public.tpk_first_date_from_json_7er1(row_data, ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date) AS anchor_date
      FROM src
    ), calc AS (
      SELECT
        row_data,
        jenis,
        tanggal_lahir,
        anchor_date,
        CASE WHEN jenis = 'BALITA'
          THEN public.tpk_age_months_7er1(anchor_date, tanggal_lahir)
          ELSE NULL
        END AS usia_bulan
      FROM derived
    )
    SELECT
      'staging_sasaran_import'::text AS source_table,
      'sasaran'::text AS record_type,
      row_data ->> 'import_batch_id' AS import_batch_id,
      coalesce(row_data ->> 'sasaran_unique_key', row_data ->> 'client_mutation_id', row_data ->> 'nik', '-') AS record_key,
      CASE
        WHEN jenis = '' THEN 'JENIS_SASARAN_REQUIRED'
        WHEN jenis = 'BADUTA' THEN 'BADUTA_LEGACY_NOT_ALLOWED'
        WHEN jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA') THEN 'JENIS_SASARAN_NOT_ALLOWED'
        WHEN jenis = 'BALITA' AND tanggal_lahir IS NULL THEN 'BALITA_TANGGAL_LAHIR_REQUIRED'
        WHEN jenis = 'BALITA' AND usia_bulan IS NULL THEN 'BALITA_AGE_INVALID'
        WHEN jenis = 'BALITA' AND usia_bulan > 59 THEN 'BALITA_MAX_59_MONTHS'
        ELSE NULL
      END AS error_code,
      CASE
        WHEN jenis = '' THEN 'Jenis sasaran wajib diisi.'
        WHEN jenis = 'BADUTA' THEN 'BADUTA tidak lagi dipakai sebagai jenis_sasaran. Gunakan BALITA; Baduta Prioritas dihitung otomatis usia 0-23 bulan.'
        WHEN jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA') THEN 'Jenis sasaran tidak termasuk taxonomy resmi 7-E-R1.'
        WHEN jenis = 'BALITA' AND tanggal_lahir IS NULL THEN 'Tanggal lahir wajib untuk BALITA.'
        WHEN jenis = 'BALITA' AND usia_bulan IS NULL THEN 'Tanggal lahir BALITA tidak valid atau melebihi tanggal acuan.'
        WHEN jenis = 'BALITA' AND usia_bulan > 59 THEN 'BALITA maksimal 59 bulan pada tanggal registrasi/import.'
        ELSE NULL
      END AS error_message,
      jsonb_build_object(
        'taxonomy_version', public.tpk_taxonomy_version_7er1(),
        'jenis_sasaran', jenis,
        'usia_bulan', usia_bulan,
        'is_baduta_prioritas', public.tpk_is_baduta_prioritas_7er1(jenis, usia_bulan),
        'kelompok_umur_balita', public.tpk_kelompok_umur_balita_7er1(jenis, usia_bulan),
        'anchor_date', anchor_date
      ) AS derived
    FROM calc
    WHERE
      jenis = ''
      OR jenis = 'BADUTA'
      OR jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA')
      OR (jenis = 'BALITA' AND (tanggal_lahir IS NULL OR usia_bulan IS NULL OR usia_bulan > 59));
  END IF;

  IF to_regclass('public.staging_pendampingan_import') IS NOT NULL THEN
    RETURN QUERY
    WITH src AS (
      SELECT to_jsonb(p) AS row_data
      FROM public.staging_pendampingan_import p
      WHERE p_import_batch_id IS NULL
         OR to_jsonb(p) ->> 'import_batch_id' = p_import_batch_id
    ), derived AS (
      SELECT
        row_data,
        public.tpk_norm_jenis_sasaran_7er1(row_data ->> 'jenis_sasaran') AS jenis,
        public.tpk_first_date_from_json_7er1(row_data, ARRAY['tanggal_lahir'], NULL) AS tanggal_lahir,
        public.tpk_first_date_from_json_7er1(row_data, ARRAY['tanggal_pendampingan'], NULL) AS tanggal_pendampingan
      FROM src
    ), calc AS (
      SELECT
        row_data,
        jenis,
        tanggal_lahir,
        tanggal_pendampingan,
        CASE WHEN jenis = 'BALITA'
          THEN public.tpk_age_months_7er1(tanggal_pendampingan, tanggal_lahir)
          ELSE NULL
        END AS usia_bulan_saat_pendampingan
      FROM derived
    )
    SELECT
      'staging_pendampingan_import'::text AS source_table,
      'pendampingan'::text AS record_type,
      row_data ->> 'import_batch_id' AS import_batch_id,
      coalesce(row_data ->> 'pendampingan_unique_key', row_data ->> 'sasaran_unique_key', row_data ->> 'client_mutation_id', '-') AS record_key,
      CASE
        WHEN jenis = '' THEN 'JENIS_SASARAN_REQUIRED'
        WHEN jenis = 'BADUTA' THEN 'BADUTA_LEGACY_NOT_ALLOWED'
        WHEN jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA') THEN 'JENIS_SASARAN_NOT_ALLOWED'
        WHEN jenis = 'BALITA' AND tanggal_lahir IS NULL THEN 'BALITA_TANGGAL_LAHIR_REQUIRED_FOR_PENDAMPINGAN'
        WHEN jenis = 'BALITA' AND tanggal_pendampingan IS NULL THEN 'TANGGAL_PENDAMPINGAN_REQUIRED_FOR_BALITA_PRIORITY'
        WHEN jenis = 'BALITA' AND usia_bulan_saat_pendampingan IS NULL THEN 'BALITA_AGE_AT_PENDAMPINGAN_INVALID'
        ELSE NULL
      END AS error_code,
      CASE
        WHEN jenis = '' THEN 'Jenis sasaran wajib diisi pada pendampingan.'
        WHEN jenis = 'BADUTA' THEN 'BADUTA tidak lagi dipakai sebagai jenis_sasaran pendampingan. Gunakan BALITA.'
        WHEN jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA') THEN 'Jenis sasaran pendampingan tidak termasuk taxonomy resmi 7-E-R1.'
        WHEN jenis = 'BALITA' AND tanggal_lahir IS NULL THEN 'Tanggal lahir sasaran BALITA wajib dibawa pada pendampingan.'
        WHEN jenis = 'BALITA' AND tanggal_pendampingan IS NULL THEN 'Tanggal pendampingan wajib untuk menghitung prioritas historis.'
        WHEN jenis = 'BALITA' AND usia_bulan_saat_pendampingan IS NULL THEN 'Umur BALITA saat pendampingan tidak valid.'
        ELSE NULL
      END AS error_message,
      jsonb_build_object(
        'taxonomy_version', public.tpk_taxonomy_version_7er1(),
        'jenis_sasaran', jenis,
        'usia_bulan_saat_pendampingan', usia_bulan_saat_pendampingan,
        'is_baduta_prioritas_saat_pendampingan', public.tpk_is_baduta_prioritas_7er1(jenis, usia_bulan_saat_pendampingan),
        'kelompok_umur_saat_pendampingan', public.tpk_kelompok_umur_balita_7er1(jenis, usia_bulan_saat_pendampingan),
        'tanggal_pendampingan', tanggal_pendampingan
      ) AS derived
    FROM calc
    WHERE
      jenis = ''
      OR jenis = 'BADUTA'
      OR jenis NOT IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA')
      OR (jenis = 'BALITA' AND (tanggal_lahir IS NULL OR tanggal_pendampingan IS NULL OR usia_bulan_saat_pendampingan IS NULL));
  END IF;
END;
$$;

COMMIT;
