-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1 — Sasaran Taxonomy Realignment
-- Migration 04: Production read models + summary 7-E-R1
-- ============================================================
-- Catatan:
-- - Default aman: membuat view baru dengan suffix _7er1 agar tidak merusak
--   dependensi view/function lama dari Paket 7-D.
-- - Tidak memakai total_baduta sebagai jenis sasaran.
-- - total_baduta_prioritas dihitung dari derived field boolean.
-- ============================================================

BEGIN;

CREATE OR REPLACE VIEW public.v_sasaran_lite_7er1 AS
SELECT
  coalesce(to_jsonb(s) ->> 'sasaran_id', to_jsonb(s) ->> 'id') AS sasaran_id,
  to_jsonb(s) ->> 'sasaran_unique_key' AS sasaran_unique_key,
  to_jsonb(s) ->> 'nik' AS nik,
  to_jsonb(s) ->> 'nama_sasaran' AS nama_sasaran,
  public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') AS jenis_sasaran,
  public.tpk_try_date_7er1(to_jsonb(s) ->> 'tanggal_lahir') AS tanggal_lahir,
  public.tpk_try_int_7er1(to_jsonb(s) ->> 'usia_bulan') AS usia_bulan,
  lower(coalesce(to_jsonb(s) ->> 'is_baduta_prioritas', 'false')) = 'true' AS is_baduta_prioritas,
  to_jsonb(s) ->> 'kelompok_umur_balita' AS kelompok_umur_balita,
  to_jsonb(s) ->> 'id_tim' AS id_tim,
  to_jsonb(s) ->> 'nomor_tim' AS nomor_tim,
  to_jsonb(s) ->> 'nama_tim' AS nama_tim,
  to_jsonb(s) ->> 'id_kader' AS id_kader,
  to_jsonb(s) ->> 'nama_kader' AS nama_kader,
  to_jsonb(s) ->> 'id_kecamatan' AS id_kecamatan,
  to_jsonb(s) ->> 'kode_kecamatan' AS kode_kecamatan,
  to_jsonb(s) ->> 'nama_kecamatan' AS nama_kecamatan,
  to_jsonb(s) ->> 'id_wilayah' AS id_wilayah,
  to_jsonb(s) ->> 'desa_kelurahan' AS desa_kelurahan,
  to_jsonb(s) ->> 'dusun_rw' AS dusun_rw,
  coalesce(to_jsonb(s) ->> 'taxonomy_version', public.tpk_taxonomy_version_7er1()) AS taxonomy_version,
  to_jsonb(s) AS row_data
FROM public.sasaran s;

CREATE OR REPLACE VIEW public.v_pendampingan_lite_7er1 AS
SELECT
  coalesce(to_jsonb(p) ->> 'pendampingan_id', to_jsonb(p) ->> 'id') AS pendampingan_id,
  to_jsonb(p) ->> 'pendampingan_unique_key' AS pendampingan_unique_key,
  coalesce(to_jsonb(p) ->> 'sasaran_id', to_jsonb(s) ->> 'sasaran_id', to_jsonb(s) ->> 'id') AS sasaran_id,
  coalesce(to_jsonb(p) ->> 'sasaran_unique_key', to_jsonb(s) ->> 'sasaran_unique_key') AS sasaran_unique_key,
  coalesce(to_jsonb(p) ->> 'nik', to_jsonb(s) ->> 'nik') AS nik,
  coalesce(to_jsonb(p) ->> 'nama_sasaran', to_jsonb(s) ->> 'nama_sasaran') AS nama_sasaran,
  public.tpk_norm_jenis_sasaran_7er1(coalesce(to_jsonb(p) ->> 'jenis_sasaran', to_jsonb(s) ->> 'jenis_sasaran')) AS jenis_sasaran,
  public.tpk_try_date_7er1(coalesce(to_jsonb(p) ->> 'tanggal_lahir', to_jsonb(s) ->> 'tanggal_lahir')) AS tanggal_lahir,
  public.tpk_try_date_7er1(to_jsonb(p) ->> 'tanggal_pendampingan') AS tanggal_pendampingan,
  to_jsonb(p) ->> 'periode_bulan' AS periode_bulan,
  to_jsonb(p) ->> 'tahun_laporan' AS tahun_laporan,
  to_jsonb(p) ->> 'status_pendampingan' AS status_pendampingan,
  COALESCE(
    public.tpk_try_int_7er1(to_jsonb(p) ->> 'usia_bulan_saat_pendampingan'),
    public.tpk_age_months_7er1(
      public.tpk_try_date_7er1(to_jsonb(p) ->> 'tanggal_pendampingan'),
      public.tpk_try_date_7er1(coalesce(to_jsonb(p) ->> 'tanggal_lahir', to_jsonb(s) ->> 'tanggal_lahir'))
    )
  ) AS usia_bulan_saat_pendampingan,
  COALESCE(
    lower(NULLIF(to_jsonb(p) ->> 'is_baduta_prioritas_saat_pendampingan', '')) = 'true',
    public.tpk_is_baduta_prioritas_7er1(
      public.tpk_norm_jenis_sasaran_7er1(coalesce(to_jsonb(p) ->> 'jenis_sasaran', to_jsonb(s) ->> 'jenis_sasaran')),
      public.tpk_age_months_7er1(
        public.tpk_try_date_7er1(to_jsonb(p) ->> 'tanggal_pendampingan'),
        public.tpk_try_date_7er1(coalesce(to_jsonb(p) ->> 'tanggal_lahir', to_jsonb(s) ->> 'tanggal_lahir'))
      )
    )
  ) AS is_baduta_prioritas_saat_pendampingan,
  COALESCE(
    NULLIF(to_jsonb(p) ->> 'kelompok_umur_saat_pendampingan', ''),
    public.tpk_kelompok_umur_balita_7er1(
      public.tpk_norm_jenis_sasaran_7er1(coalesce(to_jsonb(p) ->> 'jenis_sasaran', to_jsonb(s) ->> 'jenis_sasaran')),
      public.tpk_age_months_7er1(
        public.tpk_try_date_7er1(to_jsonb(p) ->> 'tanggal_pendampingan'),
        public.tpk_try_date_7er1(coalesce(to_jsonb(p) ->> 'tanggal_lahir', to_jsonb(s) ->> 'tanggal_lahir'))
      )
    )
  ) AS kelompok_umur_saat_pendampingan,
  coalesce(to_jsonb(p) ->> 'id_tim', to_jsonb(s) ->> 'id_tim') AS id_tim,
  coalesce(to_jsonb(p) ->> 'id_kader', to_jsonb(s) ->> 'id_kader') AS id_kader,
  coalesce(to_jsonb(p) ->> 'id_kecamatan', to_jsonb(s) ->> 'id_kecamatan') AS id_kecamatan,
  coalesce(to_jsonb(p) ->> 'taxonomy_version', public.tpk_taxonomy_version_7er1()) AS taxonomy_version,
  to_jsonb(p) AS row_data
FROM public.pendampingan p
LEFT JOIN public.sasaran s
  ON (
    coalesce(to_jsonb(p) ->> 'sasaran_id', '') <> ''
    AND coalesce(to_jsonb(p) ->> 'sasaran_id', '') = coalesce(to_jsonb(s) ->> 'sasaran_id', to_jsonb(s) ->> 'id', '')
  )
  OR (
    coalesce(to_jsonb(p) ->> 'sasaran_unique_key', '') <> ''
    AND coalesce(to_jsonb(p) ->> 'sasaran_unique_key', '') = coalesce(to_jsonb(s) ->> 'sasaran_unique_key', '')
  );

CREATE OR REPLACE VIEW public.v_summary_tim_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_sasaran_lite_7er1
)
SELECT
  coalesce(id_tim, '-') AS id_tim,
  count(*)::integer AS total_sasaran,
  count(*) FILTER (WHERE jenis_sasaran = 'CATIN')::integer AS total_catin,
  count(*) FILTER (WHERE jenis_sasaran = 'BUMIL')::integer AS total_bumil,
  count(*) FILTER (WHERE jenis_sasaran = 'BUFAS')::integer AS total_bufas,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS total_balita,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas IS TRUE)::integer AS total_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY coalesce(id_tim, '-');

CREATE OR REPLACE VIEW public.v_summary_kecamatan_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_sasaran_lite_7er1
)
SELECT
  coalesce(id_kecamatan, kode_kecamatan, nama_kecamatan, '-') AS id_kecamatan,
  count(*)::integer AS total_sasaran,
  count(*) FILTER (WHERE jenis_sasaran = 'CATIN')::integer AS total_catin,
  count(*) FILTER (WHERE jenis_sasaran = 'BUMIL')::integer AS total_bumil,
  count(*) FILTER (WHERE jenis_sasaran = 'BUFAS')::integer AS total_bufas,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS total_balita,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas IS TRUE)::integer AS total_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY coalesce(id_kecamatan, kode_kecamatan, nama_kecamatan, '-');

CREATE OR REPLACE VIEW public.v_summary_pendampingan_tim_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_pendampingan_lite_7er1
)
SELECT
  coalesce(id_tim, '-') AS id_tim,
  count(*)::integer AS total_pendampingan,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS pendampingan_balita,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas_saat_pendampingan IS TRUE)::integer AS pendampingan_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY coalesce(id_tim, '-');

CREATE OR REPLACE VIEW public.v_summary_pendampingan_kecamatan_basic_7er1 AS
WITH base AS (
  SELECT * FROM public.v_pendampingan_lite_7er1
)
SELECT
  coalesce(id_kecamatan, '-') AS id_kecamatan,
  count(*)::integer AS total_pendampingan,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA')::integer AS pendampingan_balita,
  count(*) FILTER (WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas_saat_pendampingan IS TRUE)::integer AS pendampingan_baduta_prioritas,
  public.tpk_taxonomy_version_7er1() AS taxonomy_version
FROM base
GROUP BY coalesce(id_kecamatan, '-');

CREATE OR REPLACE VIEW public.v_production_read_model_health_7er1 AS
SELECT
  public.tpk_taxonomy_version_7er1() AS taxonomy_version,
  (SELECT count(*)::integer FROM public.sasaran) AS sasaran_rows,
  (SELECT count(*)::integer FROM public.pendampingan) AS pendampingan_rows,
  (SELECT count(*)::integer FROM public.v_sasaran_lite_7er1) AS sasaran_lite_rows,
  (SELECT count(*)::integer FROM public.v_pendampingan_lite_7er1) AS pendampingan_lite_rows,
  (SELECT count(*)::integer FROM public.v_summary_tim_basic_7er1) AS summary_tim_rows,
  (SELECT count(*)::integer FROM public.v_summary_kecamatan_basic_7er1) AS summary_kecamatan_rows,
  (SELECT count(*)::integer FROM public.v_sasaran_lite_7er1 WHERE jenis_sasaran = 'BADUTA') AS legacy_baduta_as_jenis_sasaran_rows,
  (SELECT count(*)::integer FROM public.v_sasaran_lite_7er1 WHERE jenis_sasaran = 'BALITA') AS total_balita,
  (SELECT count(*)::integer FROM public.v_sasaran_lite_7er1 WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas IS TRUE) AS total_baduta_prioritas,
  (SELECT count(*)::integer FROM public.v_pendampingan_lite_7er1 WHERE jenis_sasaran = 'BALITA' AND is_baduta_prioritas_saat_pendampingan IS TRUE) AS pendampingan_baduta_prioritas;

CREATE OR REPLACE FUNCTION public.get_production_basic_summary_7er1()
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT jsonb_build_object(
    'taxonomy_version', public.tpk_taxonomy_version_7er1(),
    'summary_tim', coalesce((SELECT jsonb_agg(to_jsonb(t)) FROM public.v_summary_tim_basic_7er1 t), '[]'::jsonb),
    'summary_kecamatan', coalesce((SELECT jsonb_agg(to_jsonb(k)) FROM public.v_summary_kecamatan_basic_7er1 k), '[]'::jsonb),
    'summary_pendampingan_tim', coalesce((SELECT jsonb_agg(to_jsonb(pt)) FROM public.v_summary_pendampingan_tim_basic_7er1 pt), '[]'::jsonb),
    'summary_pendampingan_kecamatan', coalesce((SELECT jsonb_agg(to_jsonb(pk)) FROM public.v_summary_pendampingan_kecamatan_basic_7er1 pk), '[]'::jsonb)
  );
$$;

CREATE OR REPLACE FUNCTION public.check_production_read_model_health_7er1()
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT to_jsonb(h)
  FROM public.v_production_read_model_health_7er1 h
  LIMIT 1;
$$;

COMMIT;
