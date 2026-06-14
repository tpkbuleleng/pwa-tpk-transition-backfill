-- ============================================================
-- OPSIONAL — Legacy BADUTA cleanup/migration
-- Paket 7-E-R1 — BADUTA as input type -> BALITA + derived priority
-- ============================================================
-- Jalankan hanya jika ada data lama dengan jenis_sasaran = BADUTA yang memang
-- ingin dimigrasikan. Jika belum ada data BADUTA lama, file ini tidak perlu.
--
-- Prinsip:
-- - BADUTA lama dimigrasikan menjadi jenis_sasaran = BALITA.
-- - is_baduta_prioritas dihitung ulang dari umur 0-23 bulan.
-- - Untuk sasaran: anchor memakai tanggal_registrasi/tanggal_import/created_at/imported_at/current_date.
-- - Untuk pendampingan: anchor wajib tanggal_pendampingan.
-- ============================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.staging_sasaran_import') IS NOT NULL THEN
    UPDATE public.staging_sasaran_import s
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas = true,
      kelompok_umur_balita = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;

  IF to_regclass('public.dryrun_sasaran') IS NOT NULL THEN
    UPDATE public.dryrun_sasaran s
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas = true,
      kelompok_umur_balita = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;

  IF to_regclass('public.sasaran') IS NOT NULL THEN
    UPDATE public.sasaran s
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_registrasi', 'tanggal_import', 'created_at', 'imported_at'], current_date),
        public.tpk_first_date_from_json_7er1(to_jsonb(s), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas = true,
      kelompok_umur_balita = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(s) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;

  IF to_regclass('public.staging_pendampingan_import') IS NOT NULL THEN
    UPDATE public.staging_pendampingan_import p
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan_saat_pendampingan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas_saat_pendampingan = true,
      kelompok_umur_saat_pendampingan = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;

  IF to_regclass('public.dryrun_pendampingan') IS NOT NULL THEN
    UPDATE public.dryrun_pendampingan p
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan_saat_pendampingan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas_saat_pendampingan = true,
      kelompok_umur_saat_pendampingan = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;

  IF to_regclass('public.pendampingan') IS NOT NULL THEN
    UPDATE public.pendampingan p
    SET
      jenis_sasaran = 'BALITA',
      usia_bulan_saat_pendampingan = public.tpk_age_months_7er1(
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_pendampingan'], NULL),
        public.tpk_first_date_from_json_7er1(to_jsonb(p), ARRAY['tanggal_lahir'], NULL)
      ),
      is_baduta_prioritas_saat_pendampingan = true,
      kelompok_umur_saat_pendampingan = 'BADUTA_0_23',
      taxonomy_version = public.tpk_taxonomy_version_7er1()
    WHERE public.tpk_norm_jenis_sasaran_7er1(to_jsonb(p) ->> 'jenis_sasaran') = 'BADUTA';
  END IF;
END $$;

COMMIT;
