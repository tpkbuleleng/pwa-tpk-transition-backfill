# Selective Export Contract 7-G

## Versi

```txt
selective_export_version = TPK_SELECTIVE_EXPORT_2026_7G
taxonomy_version         = TPK_TAXONOMY_2026_7E_R1
```

## Scope export resmi

```txt
ALL
ROW_RANGE
CLIENT_MUTATION_IDS
RECORD_KEYS
UPDATED_SINCE
UNEXPORTED_ONLY
```

## Payload minimal preview

```json
{
  "spreadsheet_id": "ISI_SPREADSHEET_ID",
  "sheet_name": "staging_sasaran",
  "source_table": "sasaran",
  "kode_kecamatan": "TJK",
  "export_scope": "ROW_RANGE",
  "start_row": 2,
  "end_row": 10,
  "key_column": "sasaran_unique_key"
}
```

## Payload export CSV

```json
{
  "spreadsheet_id": "ISI_SPREADSHEET_ID",
  "sheet_name": "staging_pendampingan_januari",
  "source_table": "pendampingan",
  "kode_kecamatan": "TJK",
  "export_scope": "UNEXPORTED_ONLY",
  "key_column": "pendampingan_unique_key",
  "export_batch_column": "export_batch_id",
  "folder_id": "ISI_FOLDER_ID_DRIVE",
  "mark_exported": true,
  "create_manifest_file": true
}
```

## Output manifest

```json
{
  "selective_export_version": "TPK_SELECTIVE_EXPORT_2026_7G",
  "taxonomy_version": "TPK_TAXONOMY_2026_7E_R1",
  "export_batch_id": "EXP7G_TJK_SASARAN_20260615_090000",
  "kode_kecamatan": "TJK",
  "source_workbook": "BACKFILL_TPK_TJK",
  "source_spreadsheet_id": "...",
  "source_sheet": "staging_sasaran",
  "source_table": "sasaran",
  "export_scope": "ROW_RANGE",
  "selected_row_count": 9,
  "selected_record_keys": ["..."],
  "selected_sheet_rows": [2,3,4],
  "checksum_sha256": "...",
  "csv_file_id": "...",
  "csv_file_url": "...",
  "created_at": "2026-06-15T00:00:00.000Z"
}
```

## Prinsip penting

```txt
mark_exported=false  → preview/export tidak menandai row.
mark_exported=true   → kolom export_batch_id/export_checksum_sha256/exported_at diisi.
Tidak ada row yang dihapus.
```
