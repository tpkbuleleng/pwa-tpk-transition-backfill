# PASS Criteria 7-G

Paket 7-G dianggap PASS jika:

```txt
1. sql/01_import_batch_finalization_7g.sql sukses.
2. sql/02_selective_export_bridge_log_7g.sql sukses.
3. sql/03_smoke_test_7g menghasilkan ok=true.
4. public_views_without_security_invoker = 0.
5. Apps Script testSelectiveExportBridge7G_NoWrite sukses.
6. previewSelectiveExport7G dapat memilih row sesuai filter.
7. exportSelectiveCsv7G membuat CSV dan manifest.
8. register_selective_export_bridge_7g menerima manifest.
9. check_import_batch_finalization_7g dapat membaca state batch.
10. finalize_backfill_import_batch_7g menolak batch error jika force=false.
11. Security Advisor tidak memunculkan warning/error kritikal baru.
```

Status lock yang diharapkan:

```txt
Paket 7-G — Production Import Batch Finalization & Selective Export Bridge
Status: PASS LENGKAP / STABIL / SECURITY CLEAN
```
