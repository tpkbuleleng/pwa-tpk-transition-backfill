/**
 * PWA TPK Kabupaten Buleleng
 * Paket 7-G — Backfill Export Bridge Service
 *
 * Service skeleton. UI tetap tidak memanggil Apps Script/Supabase langsung.
 * Wiring aktual menunggu provider resmi pada paket berikutnya.
 */

import { validateSelectiveExportPayload7G } from '../contracts/selectiveExportContract7G.js';
import {
  normalizeImportBatchFinalizationPayload7G,
  validateImportBatchFinalizationPayload7G,
  normalizeSelectiveExportManifestForRegister7G
} from '../contracts/importBatchFinalizationContract7G.js';

export class BackfillExportBridgeService7G {
  constructor({ backend }) {
    if (!backend) throw new Error('BackfillExportBridgeService7G requires backend provider contract.');
    this.backend = backend;
  }

  async previewSelectiveExport(filters) {
    const validation = validateSelectiveExportPayload7G(filters);
    if (!validation.ok) return validation;
    return this.backend.previewSelectiveExport(validation.payload);
  }

  async exportSelectiveCsv(filters) {
    const validation = validateSelectiveExportPayload7G(filters);
    if (!validation.ok) return validation;
    return this.backend.exportSelectiveCsv(validation.payload);
  }

  async registerSelectiveExportManifest(manifest) {
    const payload = normalizeSelectiveExportManifestForRegister7G(manifest);
    if (!payload.export_batch_id) {
      return {
        ok: false,
        errors: [{ field: 'export_batch_id', code: 'EXPORT_BATCH_ID_REQUIRED', message: 'export_batch_id wajib diisi.' }]
      };
    }
    return this.backend.registerSelectiveExportBridge(payload);
  }

  async checkImportBatchFinalization(importBatchId) {
    return this.backend.checkImportBatchFinalization({ import_batch_id: importBatchId });
  }

  async finalizeImportBatch(input) {
    const validation = validateImportBatchFinalizationPayload7G(input);
    if (!validation.ok) return validation;
    return this.backend.finalizeBackfillImportBatch(normalizeImportBatchFinalizationPayload7G(input));
  }
}
