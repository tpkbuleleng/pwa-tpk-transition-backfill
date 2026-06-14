# Paket 7-E-R1 — Sasaran Taxonomy Realignment

Paket tambahan aman untuk project **PWA TPK Kabupaten Buleleng**.

Fokus:

```txt
BADUTA tidak lagi menjadi jenis_sasaran.
BALITA menjadi jenis_sasaran resmi.
BADUTA menjadi derived priority dari BALITA usia 0–23 bulan.
```

Mulai dari:

```txt
docs/README_PAKET_7E_R1.md
```

Jalankan smoke test frontend/shared:

```bash
node tests/taxonomy_smoke_test.js
```

Urutan Supabase migration:

```txt
sql/01_taxonomy_helpers_and_columns.sql
sql/02_taxonomy_constraints_and_staging_validation.sql
sql/03_populate_derived_taxonomy_fields.sql
sql/04_read_models_and_summary_7er1.sql
sql/05_smoke_tests_7er1.sql
```

Opsional setelah validasi:

```txt
sql/04b_optional_replace_legacy_read_model_names.sql
sql/06_optional_migrate_legacy_baduta_to_balita.sql
```

Apps Script:

```txt
apps-script/SasaranTaxonomyService_7ER1.gs
apps-script/README_DEPLOY_APPS_SCRIPT.md
```

File yang tidak perlu ditimpa:

```txt
backendConfig.js
apps-script/Code.gs
```
