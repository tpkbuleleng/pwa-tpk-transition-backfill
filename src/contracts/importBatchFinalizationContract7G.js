/**
 * PWA TPK Kabupaten Buleleng
 * Paket 7-G — Import Batch Finalization Contract
 */

export const IMPORT_BRIDGE_VERSION_7G = 'TPK_IMPORT_BRIDGE_2026_7G';
export const QUERY_CONTRACT_VERSION_7F = 'TPK_QUERY_CONTRACT_2026_7F';
export const TAXONOMY_VERSION_7ER1 = 'TPK_TAXONOMY_2026_7E_R1';

export function normalizeImportBatchFinalizationPayload7G(input = {}) {
  return {
    contract_version: IMPORT_BRIDGE_VERSION_7G,
    query_contract_version: QUERY_CONTRACT_VERSION_7F,
    taxonomy_version: TAXONOMY_VERSION_7ER1,
    import_batch_id: String(input.import_batch_id || input.importBatchId || '').trim(),
    export_batch_id: String(input.export_batch_id || input.exportBatchId || input.selective_export_batch_id || '').trim(),
    finalized_by: String(input.finalized_by || input.finalizedBy || input.actor || 'frontend-readiness').trim(),
    force: Boolean(input.force)
  };
}

export function validateImportBatchFinalizationPayload7G(input = {}) {
  const payload = normalizeImportBatchFinalizationPayload7G(input);
  const errors = [];

  if (!payload.import_batch_id) {
    errors.push({ field: 'import_batch_id', code: 'IMPORT_BATCH_ID_REQUIRED', message: 'import_batch_id wajib diisi.' });
  }

  return {
    ok: errors.length === 0,
    contract_version: IMPORT_BRIDGE_VERSION_7G,
    query_contract_version: QUERY_CONTRACT_VERSION_7F,
    taxonomy_version: TAXONOMY_VERSION_7ER1,
    payload,
    errors
  };
}

export function normalizeSelectiveExportManifestForRegister7G(manifest = {}) {
  return {
    export_batch_id: String(manifest.export_batch_id || '').trim(),
    import_batch_id: String(manifest.import_batch_id || '').trim() || null,
    kode_kecamatan: String(manifest.kode_kecamatan || '').trim().toUpperCase(),
    source_workbook: String(manifest.source_workbook || '').trim(),
    source_sheet: String(manifest.source_sheet || '').trim(),
    source_table: String(manifest.source_table || '').trim().toLowerCase(),
    export_scope: String(manifest.export_scope || '').trim().toUpperCase(),
    selected_row_count: Number(manifest.selected_row_count || 0),
    selected_record_keys: Array.isArray(manifest.selected_record_keys) ? manifest.selected_record_keys : [],
    checksum_sha256: String(manifest.checksum_sha256 || '').trim(),
    status: String(manifest.status || 'REGISTERED').trim().toUpperCase(),
    manifest
  };
}
