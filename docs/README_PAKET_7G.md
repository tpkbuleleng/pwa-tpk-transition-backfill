# Paket 7-G — Production Import Batch Finalization & Selective Export Bridge

## Status awal yang diasumsikan

Paket ini dijalankan setelah:

```txt
Paket 7-E-R1  PASS LENGKAP / STABIL / SECURITY CLEAN
Paket 7-F     PASS LENGKAP / STABIL / SECURITY CLEAN
```

## Tujuan

Paket 7-G mengunci dua hal:

```txt
1. Finalisasi administratif import/promote batch di Supabase production.
2. Selective Export Bridge dari Apps Script/Google Sheet BACKFILL agar tidak selalu export semua row.
```

## Batasan aman

Paket ini tidak melakukan:

```txt
- Auth/RLS frontend
- SupabaseProvider aktif ke UI utama
- perubahan backendConfig.js
- perubahan apps-script/Code.gs
- purge data
- perubahan taxonomy
```

## Isi paket

```txt
docs/
  README_PAKET_7G.md
  SELECTIVE_EXPORT_CONTRACT_7G.md
  IMPORT_FINALIZATION_CONTRACT_7G.md
  IMPLEMENTATION_CHECKLIST_7G.md
  PASS_CRITERIA_7G.md

sql/
  01_import_batch_finalization_7g.sql
  02_selective_export_bridge_log_7g.sql
  03_smoke_test_7g.sql
  04_optional_finalize_existing_batch_7g.sql

apps-script/
  SelectiveExportBridge_7G.gs
  README_DEPLOY_APPS_SCRIPT_7G.md

src/contracts/
  selectiveExportContract7G.js
  importBatchFinalizationContract7G.js

src/services/
  BackfillExportBridgeService7G.js

tests/
  frontend_contract_smoke_7g.js
```

## Urutan implementasi

```txt
1. Jalankan sql/01_import_batch_finalization_7g.sql
2. Jalankan sql/02_selective_export_bridge_log_7g.sql
3. Jalankan sql/03_smoke_test_7g.sql
4. Tempel apps-script/SelectiveExportBridge_7G.gs sebagai file baru di Apps Script pusat TPK Backfill
5. Jalankan testSelectiveExportBridge7G_NoWrite
6. Uji previewSelectiveExport7G pada workbook BACKFILL_TPK_TJK
7. Jika preview benar, uji exportSelectiveCsv7G dengan row range kecil
8. Register manifest export ke Supabase memakai register_selective_export_bridge_7g
9. Setelah import/promote batch selesai, jalankan finalize_backfill_import_batch_7g
10. Refresh Supabase Security Advisor
```

## Output final yang diharapkan

```txt
- Selective CSV export bisa berdasarkan row range / key / updated_since / unexported_only.
- Manifest export memiliki export_batch_id, checksum_sha256, row_count, dan selected_record_keys.
- Supabase dapat mencatat bridge export_batch_id → import_batch_id.
- Import batch dapat dicek dan difinalisasi secara administratif.
- Security Advisor tetap bersih.
```
