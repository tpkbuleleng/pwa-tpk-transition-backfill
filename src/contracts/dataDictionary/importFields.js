// src/contracts/dataDictionary/importFields.js

import { FIELD_TYPES, FIELD_SCOPES } from "../fieldTypes.js";

export const IMPORT_BATCH_FIELDS = Object.freeze([
  { name: "import_batch_id", label: "Import Batch ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "ID batch import CSV." },
  { name: "source_mode", label: "Source Mode", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "BACKFILL atau PRODUCTION." },
  { name: "kode_kecamatan", label: "Kode Kecamatan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Kode kecamatan sumber import." },
  { name: "nama_kecamatan", label: "Nama Kecamatan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Nama kecamatan sumber import." },
  { name: "record_type", label: "Record Type", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "sasaran atau pendampingan." },
  { name: "periode_bulan", label: "Periode Bulan", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Diisi untuk pendampingan bulanan." },
  { name: "tahun_laporan", label: "Tahun Laporan", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Tahun laporan untuk import." },
  { name: "file_name", label: "File Name", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Nama file CSV sumber." },
  { name: "csv_header_version", label: "CSV Header Version", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Versi kontrak header CSV." },
  { name: "total_rows", label: "Total Rows", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Jumlah baris dalam file." },
  { name: "valid_rows", label: "Valid Rows", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Jumlah baris valid." },
  { name: "error_rows", label: "Error Rows", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Jumlah baris error." },
  { name: "imported_by", label: "Imported By", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "User yang melakukan import." },
  { name: "imported_at", label: "Imported At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.IMPORT, description: "Waktu import." },
  { name: "status", label: "Status", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "draft, validating, valid, error, promoted." },
  { name: "notes", label: "Notes", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Catatan import." },
]);

export const IMPORT_ERROR_FIELDS = Object.freeze([
  { name: "error_id", label: "Error ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "ID error import." },
  { name: "import_batch_id", label: "Import Batch ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "ID batch import." },
  { name: "source_sheet", label: "Source Sheet", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Nama sheet sumber." },
  { name: "source_row_number", label: "Source Row Number", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Nomor baris sumber." },
  { name: "client_mutation_id", label: "Client Mutation ID", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Client mutation ID terkait jika ada." },
  { name: "record_type", label: "Record Type", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "sasaran atau pendampingan." },
  { name: "unique_key", label: "Unique Key", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Unique key terkait error." },
  { name: "error_level", label: "Error Level", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "warning atau error." },
  { name: "error_code", label: "Error Code", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Kode error." },
  { name: "error_message", label: "Error Message", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Pesan error." },
  { name: "field_name", label: "Field Name", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Nama field penyebab error." },
  { name: "field_value", label: "Field Value", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Nilai field penyebab error." },
  { name: "raw_row_json", label: "Raw Row JSON", type: FIELD_TYPES.JSON, required: false, scope: FIELD_SCOPES.IMPORT, description: "Baris sumber dalam JSON." },
  { name: "detected_at", label: "Detected At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.IMPORT, description: "Waktu error terdeteksi." },
  { name: "resolved_at", label: "Resolved At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.IMPORT, description: "Waktu error diselesaikan." },
  { name: "resolved_by", label: "Resolved By", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "User penyelesai error." },
  { name: "resolution_note", label: "Resolution Note", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Catatan penyelesaian error." },
]);

export const EXPORT_LOG_FIELDS = Object.freeze([
  { name: "export_id", label: "Export ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "ID export." },
  { name: "export_batch_id", label: "Export Batch ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "ID batch export." },
  { name: "source_workbook", label: "Source Workbook", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Workbook sumber." },
  { name: "source_sheet", label: "Source Sheet", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Sheet sumber." },
  { name: "record_type", label: "Record Type", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "sasaran atau pendampingan." },
  { name: "periode_bulan", label: "Periode Bulan", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Bulan pendampingan jika relevan." },
  { name: "tahun_laporan", label: "Tahun Laporan", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Tahun laporan." },
  { name: "total_rows", label: "Total Rows", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.IMPORT, description: "Jumlah baris export." },
  { name: "exported_by", label: "Exported By", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "User yang melakukan export." },
  { name: "exported_at", label: "Exported At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.IMPORT, description: "Waktu export." },
  { name: "file_name", label: "File Name", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.IMPORT, description: "Nama file CSV output." },
  { name: "checksum_sha256", label: "Checksum SHA256", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Checksum file export jika dihitung." },
  { name: "status", label: "Status", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.IMPORT, description: "success atau failed." },
  { name: "notes", label: "Notes", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Catatan export." },
]);
