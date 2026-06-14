-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1 — Sasaran Taxonomy Realignment
-- Migration 03: Populate derived taxonomy fields
-- ============================================================
-- Mengisi field turunan pada staging, dry-run, dan production.
-- Tidak mengubah BADUTA legacy menjadi BALITA. Cleanup/migrasi legacy ada
-- pada migration opsional 06.
-- ============================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.staging_sasaran_import') IS NOT NULL THEN
    UPDATE public.staging_sasaran_import s
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran'),
      usia_bulan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_balita = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;

  IF to_regclass('public.staging_pendampingan_import') IS NOT NULL THEN
    UPDATE public.staging_pendampingan_import p
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran'),
      usia_bulan_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;

  IF to_regclass('public.dryrun_sasaran') IS NOT NULL THEN
    UPDATE public.dryrun_sasaran s
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran'),
      usia_bulan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_balita = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;

  IF to_regclass('public.dryrun_pendampingan') IS NOT NULL THEN
    UPDATE public.dryrun_pendampingan p
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran'),
      usia_bulan_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;

  IF to_regclass('public.sasaran') IS NOT NULL THEN
    UPDATE public.sasaran s
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran'),
      usia_bulan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
          public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_balita = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
            public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;

  IF to_regclass('public.pendampingan') IS NOT NULL THEN
    UPDATE public.pendampingan p
    SET
      jenis_sasaran = public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran'),
      usia_bulan_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_age_months_7er1(
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
          public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
        )
        ELSE NULL
      END,
      is_baduta_prioritas_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_is_baduta_prioritas_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE false
      END,
      kelompok_umur_saat_pendampingan = CASE
        WHEN public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BALITA'
        THEN public.tpk_kelompok_umur_balita_7er1(
          'BALITA',
          public.tpk_age_months_7er1(
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
            public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
          )
        )
        ELSE NULL
      END,
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') <> 'BADUTA';
  END IF;
END $$;

COMMIT;
