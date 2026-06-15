/**
 * PWA TPK Kabupaten Buleleng
 * Paket 7-G — Selective Export Contract
 * Pure JS helper. Tidak memanggil Apps Script/Supabase langsung.
 */

export const SELECTIVE_EXPORT_VERSION_7G = 'TPK_SELECTIVE_EXPORT_2026_7G';
export const TAXONOMY_VERSION_7ER1 = 'TPK_TAXONOMY_2026_7E_R1';

export const SELECTIVE_EXPORT_SCOPES_7G = Object.freeze([
  'ALL',
  'ROW_RANGE',
  'CLIENT_MUTATION_IDS',
  'RECORD_KEYS',
  'UPDATED_SINCE',
  'UNEXPORTED_ONLY'
]);

export function normalizeSelectiveExportPayload7G(input = {}) {
  const sourceTable = String(input.source_table || input.sourceTable || '').trim().toLowerCase();
  const exportScope = String(input.export_scope || input.exportScope || 'ALL').trim().toUpperCase();

  return {
    selective_export_version: SELECTIVE_EXPORT_VERSION_7G,
    taxonomy_version: TAXONOMY_VERSION_7ER1,
    spreadsheet_id: String(input.spreadsheet_id || input.spreadsheetId || '').trim(),
    sheet_name: String(input.sheet_name || input.sheetName || '').trim(),
    source_table: sourceTable,
    kode_kecamatan: String(input.kode_kecamatan || input.kodeKecamatan || '').trim().toUpperCase(),
    export_scope: exportScope,
    start_row: input.start_row ?? input.startRow ?? null,
    end_row: input.end_row ?? input.endRow ?? null,
    key_column: String(input.key_column || input.keyColumn || '').trim(),
    record_keys: Array.isArray(input.record_keys) ? input.record_keys : (Array.isArray(input.recordKeys) ? input.recordKeys : []),
    updated_at_column: String(input.updated_at_column || input.updatedAtColumn || 'updated_at').trim(),
    updated_since: String(input.updated_since || input.updatedSince || '').trim(),
    export_batch_column: String(input.export_batch_column || input.exportBatchColumn || 'export_batch_id').trim(),
    folder_id: String(input.folder_id || input.folderId || '').trim(),
    mark_exported: Boolean(input.mark_exported || input.markExported),
    create_manifest_file: input.create_manifest_file === false || input.createManifestFile === false ? false : true
  };
}

export function validateSelectiveExportPayload7G(input = {}) {
  const payload = normalizeSelectiveExportPayload7G(input);
  const errors = [];

  if (!payload.sheet_name) {
    errors.push({ field: 'sheet_name', code: 'SHEET_NAME_REQUIRED', message: 'sheet_name wajib diisi.' });
  }

  if (!['sasaran', 'pendampingan'].includes(payload.source_table)) {
    errors.push({ field: 'source_table', code: 'INVALID_SOURCE_TABLE', message: 'source_table wajib sasaran atau pendampingan.' });
  }

  if (!SELECTIVE_EXPORT_SCOPES_7G.includes(payload.export_scope)) {
    errors.push({ field: 'export_scope', code: 'INVALID_EXPORT_SCOPE', message: 'export_scope tidak valid.' });
  }

  if (payload.export_scope === 'ROW_RANGE') {
    const start = Number(payload.start_row);
    const end = Number(payload.end_row);
    if (!Number.isInteger(start) || start < 2) {
      errors.push({ field: 'start_row', code: 'INVALID_START_ROW', message: 'start_row minimal 2.' });
    }
    if (!Number.isInteger(end) || end < start) {
      errors.push({ field: 'end_row', code: 'INVALID_END_ROW', message: 'end_row harus lebih besar atau sama dengan start_row.' });
    }
  }

  if (['CLIENT_MUTATION_IDS', 'RECORD_KEYS'].includes(payload.export_scope) && payload.record_keys.length === 0) {
    errors.push({ field: 'record_keys', code: 'RECORD_KEYS_REQUIRED', message: 'record_keys wajib diisi untuk scope berbasis key.' });
  }

  if (payload.export_scope === 'UPDATED_SINCE' && !payload.updated_since) {
    errors.push({ field: 'updated_since', code: 'UPDATED_SINCE_REQUIRED', message: 'updated_since wajib diisi untuk scope UPDATED_SINCE.' });
  }

  return {
    ok: errors.length === 0,
    selective_export_version: SELECTIVE_EXPORT_VERSION_7G,
    taxonomy_version: TAXONOMY_VERSION_7ER1,
    payload,
    errors
  };
}
