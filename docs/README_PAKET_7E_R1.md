# Paket 7-E-R1 — Sasaran Taxonomy Realignment: BADUTA to BALITA + Baduta Priority

Status paket: **siap uji bertahap**.

Paket ini merapikan taxonomy sasaran untuk integrasi PWA TPK + PWA SPPG.

## Keputusan resmi

Jenis sasaran resmi setelah Paket 7-E-R1:

```txt
CATIN
BUMIL
BUFAS
BALITA
```

`BADUTA` tidak lagi dipakai sebagai `jenis_sasaran` resmi.

`BADUTA` menjadi status prioritas turunan dari `BALITA`:

```txt
BALITA usia 0–23 bulan  => BADUTA PRIORITAS
BALITA usia 24–59 bulan => BALITA NON-BADUTA
```

Untuk pendampingan historis/backfill, Baduta Prioritas dihitung dari:

```txt
tanggal_pendampingan - tanggal_lahir
```

bukan umur saat input, bukan tanggal hari ini.

## Isi paket

```txt
src/shared/sasaranTaxonomy.js
src/shared/sasaranTaxonomyUi.js
apps-script/SasaranTaxonomyService_7ER1.gs
apps-script/README_DEPLOY_APPS_SCRIPT.md
sql/01_taxonomy_helpers_and_columns.sql
sql/02_taxonomy_constraints_and_staging_validation.sql
sql/03_populate_derived_taxonomy_fields.sql
sql/04_read_models_and_summary_7er1.sql
sql/04b_optional_replace_legacy_read_model_names.sql
sql/05_smoke_tests_7er1.sql
sql/06_optional_migrate_legacy_baduta_to_balita.sql
tests/taxonomy_smoke_test.js
```

## File yang tidak disentuh

Paket ini tidak menimpa:

```txt
backendConfig.js
apps-script/Code.gs
```

## Urutan implementasi aman

### Tahap 1 — Frontend shared taxonomy

Tambahkan file baru:

```txt
src/shared/sasaranTaxonomy.js
src/shared/sasaranTaxonomyUi.js
```

Gunakan `OFFICIAL_JENIS_SASARAN` untuk dropdown UI.

Expected dropdown:

```txt
CATIN
BUMIL
BUFAS
BALITA
```

Tidak boleh ada `BADUTA` sebagai opsi dropdown.

### Tahap 2 — Shared validation / payload builder

Sebelum payload dikirim ke backend provider, jalankan:

```js
const validation = SasaranTaxonomy7ER1.validateSasaranTaxonomy(payload, {
  anchorDate: payload.tanggal_registrasi || payload.tanggal_import
});

const decoratedPayload = SasaranTaxonomy7ER1.decorateSasaranPayload(payload, {
  anchorDate: payload.tanggal_registrasi || payload.tanggal_import
});
```

Untuk pendampingan:

```js
const validation = SasaranTaxonomy7ER1.validatePendampinganTaxonomy(payload);
const decoratedPayload = SasaranTaxonomy7ER1.decoratePendampinganPayload(payload);
```

### Tahap 3 — Apps Script BACKFILL

Tambahkan file baru ke Apps Script pusat `TPK Backfill`:

```txt
SasaranTaxonomyService_7ER1.gs
```

Jalankan smoke test:

```txt
testTaxonomy7ER1
```

Setelah itu panggil helper validasi/decorate pada alur append staging sasaran dan pendampingan.

### Tahap 4 — Supabase migration

Jalankan SQL berurutan:

```txt
01_taxonomy_helpers_and_columns.sql
02_taxonomy_constraints_and_staging_validation.sql
03_populate_derived_taxonomy_fields.sql
04_read_models_and_summary_7er1.sql
05_smoke_tests_7er1.sql
```

File berikut hanya dijalankan jika diperlukan:

```txt
04b_optional_replace_legacy_read_model_names.sql
06_optional_migrate_legacy_baduta_to_balita.sql
```

## Kenapa read model default memakai suffix `_7er1`?

Agar tidak merusak dependency Paket 7-D yang sudah PASS.

Default aman:

```txt
v_sasaran_lite_7er1
v_pendampingan_lite_7er1
v_summary_tim_basic_7er1
v_summary_kecamatan_basic_7er1
v_production_read_model_health_7er1
get_production_basic_summary_7er1()
check_production_read_model_health_7er1()
```

Setelah semua smoke test PASS, barulah boleh menjalankan file opsional:

```txt
04b_optional_replace_legacy_read_model_names.sql
```

untuk mengarahkan nama view standar Paket 7-D ke versi 7-E-R1.

## Target PASS

Paket ini dianggap PASS jika:

```txt
1. Dropdown UI hanya menampilkan CATIN/BUMIL/BUFAS/BALITA.
2. BADUTA tidak bisa dikirim sebagai jenis_sasaran input baru.
3. BALITA usia 0–23 bulan menghasilkan is_baduta_prioritas = true.
4. BALITA usia 24–59 bulan menghasilkan is_baduta_prioritas = false.
5. Staging validation menerima BALITA valid.
6. Staging validation menolak BADUTA sebagai input baru.
7. Read model 7-E-R1 menampilkan total_balita dan total_baduta_prioritas.
8. Summary tim/kecamatan tidak menghitung BADUTA sebagai jenis sasaran.
9. Pendampingan historis menghitung prioritas berdasarkan tanggal_pendampingan.
10. Security Advisor tidak memunculkan error/warning kritikal baru.
```
