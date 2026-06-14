# Checklist Implementasi Paket 7-E-R1

## A. Frontend

- [ ] Tambahkan `src/shared/sasaranTaxonomy.js`.
- [ ] Tambahkan `src/shared/sasaranTaxonomyUi.js`.
- [ ] Ubah sumber dropdown menjadi `OFFICIAL_JENIS_SASARAN`.
- [ ] Pastikan `BADUTA` tidak muncul sebagai opsi UI.
- [ ] Tambahkan badge otomatis:
  - `BADUTA PRIORITAS` untuk BALITA 0–23 bulan.
  - `BALITA NON-BADUTA` untuk BALITA 24–59 bulan.
- [ ] Payload sasaran membawa:
  - `usia_bulan`
  - `is_baduta_prioritas`
  - `kelompok_umur_balita`
  - `taxonomy_version`
- [ ] Payload pendampingan membawa:
  - `usia_bulan_saat_pendampingan`
  - `is_baduta_prioritas_saat_pendampingan`
  - `kelompok_umur_saat_pendampingan`
  - `taxonomy_version`

## B. Apps Script BACKFILL

- [ ] Tambahkan `SasaranTaxonomyService_7ER1.gs` pada Apps Script pusat `TPK Backfill`.
- [ ] Jalankan `testTaxonomy7ER1`.
- [ ] Integrasikan validasi sasaran sebelum append staging.
- [ ] Integrasikan validasi pendampingan sebelum append staging.
- [ ] Deploy versi baru Apps Script.
- [ ] Uji submit BALITA 0–23 bulan.
- [ ] Uji submit BALITA 24–59 bulan.
- [ ] Uji submit BADUTA dan pastikan ditolak.

## C. Supabase

Jalankan berurutan:

- [ ] `01_taxonomy_helpers_and_columns.sql`
- [ ] `02_taxonomy_constraints_and_staging_validation.sql`
- [ ] `03_populate_derived_taxonomy_fields.sql`
- [ ] `04_read_models_and_summary_7er1.sql`
- [ ] `05_smoke_tests_7er1.sql`

Opsional:

- [ ] `04b_optional_replace_legacy_read_model_names.sql`
- [ ] `06_optional_migrate_legacy_baduta_to_balita.sql`

## D. PASS test minimal

- [ ] BALITA lahir `2024-02-01`, tanggal acuan `2026-01-31` => usia 23, Baduta Prioritas true.
- [ ] BALITA lahir `2023-12-01`, tanggal acuan `2026-01-31` => usia 25, Baduta Prioritas false.
- [ ] BADUTA sebagai `jenis_sasaran` ditolak.
- [ ] Query `v_production_read_model_health_7er1` memiliki:
  - `total_balita`
  - `total_baduta_prioritas`
  - `legacy_baduta_as_jenis_sasaran_rows = 0` setelah cleanup final.
