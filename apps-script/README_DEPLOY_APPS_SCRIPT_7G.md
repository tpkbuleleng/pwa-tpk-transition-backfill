# Deploy Apps Script — Paket 7-G

File baru:

```txt
apps-script/SelectiveExportBridge_7G.gs
```

## Prinsip

- Tidak menimpa `Code.gs`.
- Tidak menimpa `backendConfig.js`.
- Aman ditempel ke project Apps Script pusat **TPK Backfill**.
- Fungsi export tidak menghapus row staging.
- Row hanya ditandai exported jika `mark_exported: true`.

## Langkah

1. Buka Apps Script pusat `TPK Backfill`.
2. Tambah file baru `SelectiveExportBridge_7G.gs`.
3. Tempel seluruh isi file.
4. Jalankan `testSelectiveExportBridge7G_NoWrite`.
5. Untuk uji workbook, jalankan `previewSelectiveExport7G(payload)` dari editor Apps Script atau endpoint internal yang sudah ada.
6. Jika perlu membuat CSV, jalankan `exportSelectiveCsv7G(payload)`.

## Contoh payload preview row range

```js
previewSelectiveExport7G({
  spreadsheet_id: 'ISI_SPREADSHEET_ID_BACKFILL_TPK_TJK',
  sheet_name: 'staging_sasaran',
  source_table: 'sasaran',
  kode_kecamatan: 'TJK',
  export_scope: 'ROW_RANGE',
  start_row: 2,
  end_row: 10,
  key_column: 'sasaran_unique_key'
});
```

## Contoh export CSV unexported only

```js
exportSelectiveCsv7G({
  spreadsheet_id: 'ISI_SPREADSHEET_ID_BACKFILL_TPK_TJK',
  sheet_name: 'staging_pendampingan_januari',
  source_table: 'pendampingan',
  kode_kecamatan: 'TJK',
  export_scope: 'UNEXPORTED_ONLY',
  key_column: 'pendampingan_unique_key',
  export_batch_column: 'export_batch_id',
  folder_id: 'ISI_FOLDER_ID_DRIVE',
  mark_exported: true,
  create_manifest_file: true
});
```

## Output penting

Output export menghasilkan:

```txt
export_batch_id
selected_row_count
selected_record_keys
checksum_sha256
csv_file_id
csv_file_url
manifest
```

Manifest ini dapat diregister ke Supabase melalui:

```sql
SELECT public.register_selective_export_bridge_7g('<manifest_json>'::jsonb);
```
