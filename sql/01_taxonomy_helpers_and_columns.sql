-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1 — Sasaran Taxonomy Realignment
-- Migration 01: Helper functions + derived columns
-- ============================================================
-- Aman dijalankan berulang.
-- Tidak membuka RLS / policy.
-- Semua function diberi SET search_path untuk menghindari Function Search Path Mutable.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.tpk_taxonomy_version_7er1()
RETURNS text
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT 'TPK_TAXONOMY_2026_7E_R1'::text;
$$;

CREATE OR REPLACE FUNCTION public.tpk_norm_text_7er1(p_value text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT btrim(coalesce(p_value, ''));
$$;

CREATE OR REPLACE FUNCTION public.tpk_norm_jenis_sasaran_7er1(p_value text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT upper(public.tpk_norm_text_7er1(p_value));
$$;

CREATE OR REPLACE FUNCTION public.tpk_is_official_jenis_sasaran_7er1(p_value text)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT public.tpk_norm_jenis_sasaran_7er1(p_value) IN ('CATIN', 'BUMIL', 'BUFAS', 'BALITA');
$$;

CREATE OR REPLACE FUNCTION public.tpk_try_date_7er1(p_value text)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_text text;
  v_date date;
BEGIN
  v_text := public.tpk_norm_text_7er1(p_value);

  IF v_text = '' THEN
    RETURN NULL;
  END IF;

  IF v_text !~ '^\d{4}-\d{2}-\d{2}' THEN
    RETURN NULL;
  END IF;

  BEGIN
    v_date := left(v_text, 10)::date;
    RETURN v_date;
  EXCEPTION WHEN others THEN
    RETURN NULL;
  END;
END;
$$;


CREATE OR REPLACE FUNCTION public.tpk_try_int_7er1(p_value text)
RETURNS integer
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_text text;
BEGIN
  v_text := public.tpk_norm_text_7er1(p_value);
  IF v_text = '' THEN
    RETURN NULL;
  END IF;
  IF v_text !~ '^-?\d+$' THEN
    RETURN NULL;
  END IF;
  RETURN v_text::integer;
EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.tpk_first_date_from_json_7er1(
  p_row jsonb,
  p_keys text[],
  p_default date DEFAULT NULL
)
RETURNS date
LANGUAGE plpgsql
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_key text;
  v_date date;
BEGIN
  IF p_row IS NULL THEN
    RETURN p_default;
  END IF;

  FOREACH v_key IN ARRAY p_keys LOOP
    v_date := public.tpk_try_date_7er1(p_row ->> v_key);
    IF v_date IS NOT NULL THEN
      RETURN v_date;
    END IF;
  END LOOP;

  RETURN p_default;
END;
$$;

CREATE OR REPLACE FUNCTION public.tpk_age_months_7er1(
  p_anchor_date date,
  p_birth_date date
)
RETURNS integer
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_months integer;
BEGIN
  IF p_anchor_date IS NULL OR p_birth_date IS NULL THEN
    RETURN NULL;
  END IF;

  IF p_birth_date > p_anchor_date THEN
    RETURN NULL;
  END IF;

  v_months :=
    ((date_part('year', p_anchor_date)::int - date_part('year', p_birth_date)::int) * 12) +
    (date_part('month', p_anchor_date)::int - date_part('month', p_birth_date)::int);

  IF date_part('day', p_anchor_date)::int < date_part('day', p_birth_date)::int THEN
    v_months := v_months - 1;
  END IF;

  IF v_months < 0 THEN
    RETURN NULL;
  END IF;

  RETURN v_months;
END;
$$;

CREATE OR REPLACE FUNCTION public.tpk_kelompok_umur_balita_7er1(
  p_jenis_sasaran text,
  p_usia_bulan integer
)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT CASE
    WHEN public.tpk_norm_jenis_sasaran_7er1(p_jenis_sasaran) <> 'BALITA' THEN NULL
    WHEN p_usia_bulan IS NULL THEN NULL
    WHEN p_usia_bulan < 0 THEN NULL
    WHEN p_usia_bulan <= 23 THEN 'BADUTA_0_23'
    WHEN p_usia_bulan <= 59 THEN 'BALITA_24_59'
    ELSE 'NON_BALITA'
  END;
$$;

CREATE OR REPLACE FUNCTION public.tpk_is_baduta_prioritas_7er1(
  p_jenis_sasaran text,
  p_usia_bulan integer
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT public.tpk_norm_jenis_sasaran_7er1(p_jenis_sasaran) = 'BALITA'
    AND p_usia_bulan BETWEEN 0 AND 23;
$$;

-- ---------------------------
-- Tambah kolom staging
-- ---------------------------
ALTER TABLE IF EXISTS public.staging_sasaran_import
  ADD COLUMN IF NOT EXISTS usia_bulan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_balita text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

ALTER TABLE IF EXISTS public.staging_pendampingan_import
  ADD COLUMN IF NOT EXISTS usia_bulan_saat_pendampingan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas_saat_pendampingan boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_saat_pendampingan text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

-- ---------------------------
-- Tambah kolom dry-run
-- ---------------------------
ALTER TABLE IF EXISTS public.dryrun_sasaran
  ADD COLUMN IF NOT EXISTS usia_bulan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_balita text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

ALTER TABLE IF EXISTS public.dryrun_pendampingan
  ADD COLUMN IF NOT EXISTS usia_bulan_saat_pendampingan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas_saat_pendampingan boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_saat_pendampingan text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

-- ---------------------------
-- Tambah kolom production
-- ---------------------------
ALTER TABLE IF EXISTS public.sasaran
  ADD COLUMN IF NOT EXISTS usia_bulan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_balita text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

ALTER TABLE IF EXISTS public.pendampingan
  ADD COLUMN IF NOT EXISTS usia_bulan_saat_pendampingan integer,
  ADD COLUMN IF NOT EXISTS is_baduta_prioritas_saat_pendampingan boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS kelompok_umur_saat_pendampingan text,
  ADD COLUMN IF NOT EXISTS taxonomy_version text;

COMMIT;
