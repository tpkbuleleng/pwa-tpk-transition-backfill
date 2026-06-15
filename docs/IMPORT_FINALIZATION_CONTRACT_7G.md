# Import Finalization Contract 7-G

## Versi

```txt
contract_version       = TPK_IMPORT_BRIDGE_2026_7G
query_contract_version = TPK_QUERY_CONTRACT_2026_7F
taxonomy_version       = TPK_TAXONOMY_2026_7E_R1
```

## RPC utama

```sql
SELECT public.check_import_finalization_health_7g();
SELECT public.check_import_batch_finalization_7g('IMPORT_BATCH_ID');
SELECT public.finalize_backfill_import_batch_7g('{...}'::jsonb);
SELECT public.register_selective_export_bridge_7g('{...}'::jsonb);
SELECT public.get_selective_export_bridge_log_7g('EXPORT_BATCH_ID');
```

## Payload finalize

```json
{
  "import_batch_id": "IMP_20260615_TJK_001",
  "export_batch_id": "EXP7G_TJK_SASARAN_20260615_090000",
  "finalized_by": "postgres",
  "force": false
}
```

## Status finalization

```txt
PRODUCTION_PROMOTED     production rows ditemukan
DRYRUN_READY            dry-run rows ditemukan, production belum ada
STAGING_IMPORTED        staging rows ditemukan, dry-run/production belum ada
BLOCKED_BY_ERRORS       import/promote error masih ada
NO_BATCH_ROWS_FOUND     batch id tidak ditemukan pada staging/dry-run/production
```

## Guard

```txt
force=false akan menolak finalisasi jika ada import/promote error.
force=true hanya untuk administrasi khusus, bukan alur normal.
```

## Catatan schema

`selective_export_bridge_log` dibuat pada schema:

```txt
backfill_internal
```

Tujuannya agar log bridge tidak menjadi tabel public REST yang terbuka ke frontend.
