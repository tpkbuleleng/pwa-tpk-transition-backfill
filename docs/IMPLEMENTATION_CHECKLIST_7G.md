# Implementation Checklist 7-G

## Supabase

```txt
[ ] Jalankan sql/01_import_batch_finalization_7g.sql
[ ] Jalankan sql/02_selective_export_bridge_log_7g.sql
[ ] Jalankan sql/03_smoke_test_7g.sql
[ ] Pastikan check_import_finalization_health_7g ok=true
[ ] Pastikan check_selective_export_bridge_health_7g ok=true
[ ] Pastikan public_views_without_security_invoker = 0
[ ] Refresh Supabase Security Advisor
```

## Apps Script

```txt
[ ] Tambahkan file baru SelectiveExportBridge_7G.gs
[ ] Jalankan testSelectiveExportBridge7G_NoWrite
[ ] Jalankan previewSelectiveExport7G dengan ROW_RANGE kecil
[ ] Pastikan selected_row_count sesuai
[ ] Jalankan exportSelectiveCsv7G dengan mark_exported=false dahulu
[ ] Jika CSV benar, ulangi dengan mark_exported=true bila dibutuhkan
[ ] Simpan manifest JSON
```

## Bridge

```txt
[ ] Register manifest ke register_selective_export_bridge_7g
[ ] Import CSV ke Supabase staging seperti alur 7-A
[ ] Validate import batch
[ ] Promote dry-run sesuai alur 7-B/7-C
[ ] Finalize batch dengan finalize_backfill_import_batch_7g
```

## Commit

```bash
git add .
git commit -m "feat: add production import finalization and selective export bridge"
```
