/**
 * PWA TPK Kabupaten Buleleng
 * Paket 7-G — Selective Export Bridge
 * ------------------------------------------------------------
 * File baru. Tidak menimpa Code.gs.
 * Tujuan:
 * - Preview/export CSV selektif dari workbook BACKFILL staging.
 * - Membuat manifest JSON untuk bridge ke Supabase import_batch.
 * - Mendukung row range, selected keys, updated_since, dan unexported_only.
 * - Aman: tidak menghapus row. Mark export hanya bila mark_exported=true.
 */

var TPK_7G_SELECTIVE_EXPORT_VERSION = 'TPK_SELECTIVE_EXPORT_2026_7G';
var TPK_7G_TAXONOMY_VERSION = 'TPK_TAXONOMY_2026_7E_R1';

function getSelectiveExportVersion7G() {
  return TPK_7G_SELECTIVE_EXPORT_VERSION;
}

/**
 * Preview tanpa membuat file CSV.
 * Payload contoh:
 * {
 *   spreadsheet_id: '...',              // opsional; jika kosong pakai active spreadsheet
 *   sheet_name: 'staging_sasaran',
 *   source_table: 'sasaran',            // sasaran | pendampingan
 *   kode_kecamatan: 'TJK',
 *   export_scope: 'ROW_RANGE',          // ALL | ROW_RANGE | CLIENT_MUTATION_IDS | RECORD_KEYS | UPDATED_SINCE | UNEXPORTED_ONLY
 *   start_row: 2,
 *   end_row: 20,
 *   key_column: 'client_mutation_id',
 *   record_keys: ['...'],
 *   updated_at_column: 'updated_at',
 *   updated_since: '2026-01-01T00:00:00Z',
 *   export_batch_column: 'export_batch_id'
 * }
 */
function previewSelectiveExport7G(payload) {
  var plan = buildSelectiveExportPlan7G_(payload || {});
  var rows = selectRowsForExport7G_(plan);
  return buildSelectiveExportResponse7G_(plan, rows, null, null, false);
}

/**
 * Export CSV selektif ke Google Drive.
 * Payload tambahan:
 * {
 *   folder_id: '...',                   // opsional
 *   mark_exported: true,                // opsional; default false
 *   create_manifest_file: true          // opsional; default true
 * }
 */
function exportSelectiveCsv7G(payload) {
  var plan = buildSelectiveExportPlan7G_(payload || {});
  var rows = selectRowsForExport7G_(plan);

  var csv = buildCsv7G_(plan.headers, rows.map(function (r) { return r.values; }));
  var checksum = sha256Hex7G_(csv);
  var folder = plan.folderId ? DriveApp.getFolderById(plan.folderId) : DriveApp.getRootFolder();
  var baseName = [
    plan.exportBatchId,
    plan.kodeKecamatan || 'NA',
    plan.sourceTable,
    plan.sheetName
  ].join('_');

  var csvFile = folder.createFile(baseName + '.csv', csv, MimeType.CSV);
  var manifest = buildManifest7G_(plan, rows, checksum, csvFile.getId(), csvFile.getUrl());
  var manifestFile = null;

  if (plan.createManifestFile) {
    manifestFile = folder.createFile(
      baseName + '_manifest.json',
      JSON.stringify(manifest, null, 2),
      MimeType.JSON
    );
  }

  if (plan.markExported) {
    markRowsExported7G_(plan, rows, checksum);
  }

  appendExportLog7G_(plan, rows, checksum, csvFile, manifestFile);

  return buildSelectiveExportResponse7G_(plan, rows, csvFile, manifestFile, true, checksum, manifest);
}

function buildSelectiveExportPlan7G_(payload) {
  var spreadsheetId = normString7G_(payload.spreadsheet_id || payload.spreadsheetId || '');
  var ss = spreadsheetId ? SpreadsheetApp.openById(spreadsheetId) : SpreadsheetApp.getActiveSpreadsheet();
  if (!ss) throw new Error('Spreadsheet tidak ditemukan. Isi spreadsheet_id atau jalankan dari container workbook.');

  var sheetName = normString7G_(payload.sheet_name || payload.sheetName || '');
  if (!sheetName) throw new Error('sheet_name wajib diisi.');

  var sheet = ss.getSheetByName(sheetName);
  if (!sheet) throw new Error('Sheet tidak ditemukan: ' + sheetName);

  var sourceTable = normString7G_(payload.source_table || payload.sourceTable || '').toLowerCase();
  if (['sasaran', 'pendampingan'].indexOf(sourceTable) === -1) {
    throw new Error('source_table wajib sasaran atau pendampingan.');
  }

  var exportScope = normString7G_(payload.export_scope || payload.exportScope || 'ALL').toUpperCase();
  var allowedScopes = ['ALL', 'ROW_RANGE', 'CLIENT_MUTATION_IDS', 'RECORD_KEYS', 'UPDATED_SINCE', 'UNEXPORTED_ONLY'];
  if (allowedScopes.indexOf(exportScope) === -1) {
    throw new Error('export_scope tidak valid: ' + exportScope);
  }

  var values = sheet.getDataRange().getValues();
  if (!values || values.length < 1) throw new Error('Sheet kosong: ' + sheetName);

  var headers = values[0].map(function (h) { return normString7G_(h); });
  var headerMap = buildHeaderMap7G_(headers);
  var exportBatchId = normString7G_(payload.export_batch_id || payload.exportBatchId || '');
  if (!exportBatchId) {
    exportBatchId = makeExportBatchId7G_(sourceTable, payload.kode_kecamatan || payload.kodeKecamatan || 'NA');
  }

  return {
    spreadsheet: ss,
    spreadsheetId: ss.getId(),
    spreadsheetName: ss.getName(),
    sheet: sheet,
    sheetName: sheetName,
    sourceTable: sourceTable,
    kodeKecamatan: normString7G_(payload.kode_kecamatan || payload.kodeKecamatan || ''),
    exportScope: exportScope,
    exportBatchId: exportBatchId,
    folderId: normString7G_(payload.folder_id || payload.folderId || ''),
    markExported: Boolean(payload.mark_exported || payload.markExported),
    createManifestFile: payload.create_manifest_file === false || payload.createManifestFile === false ? false : true,
    startRow: toInt7G_(payload.start_row || payload.startRow || 2, 2),
    endRow: toInt7G_(payload.end_row || payload.endRow || values.length, values.length),
    keyColumn: normString7G_(payload.key_column || payload.keyColumn || defaultKeyColumn7G_(sourceTable)),
    recordKeys: Array.isArray(payload.record_keys) ? payload.record_keys.map(normString7G_).filter(Boolean) :
      (Array.isArray(payload.recordKeys) ? payload.recordKeys.map(normString7G_).filter(Boolean) : []),
    updatedAtColumn: normString7G_(payload.updated_at_column || payload.updatedAtColumn || 'updated_at'),
    updatedSince: normString7G_(payload.updated_since || payload.updatedSince || ''),
    exportBatchColumn: normString7G_(payload.export_batch_column || payload.exportBatchColumn || 'export_batch_id'),
    checksumColumn: normString7G_(payload.checksum_column || payload.checksumColumn || 'export_checksum_sha256'),
    exportedAtColumn: normString7G_(payload.exported_at_column || payload.exportedAtColumn || 'exported_at'),
    headers: headers,
    headerMap: headerMap,
    values: values
  };
}

function selectRowsForExport7G_(plan) {
  var rows = [];
  var keyIdx = plan.headerMap[plan.keyColumn];
  var updatedIdx = plan.headerMap[plan.updatedAtColumn];
  var exportBatchIdx = plan.headerMap[plan.exportBatchColumn];
  var keySet = {};
  plan.recordKeys.forEach(function (k) { keySet[k] = true; });
  var sinceDate = plan.updatedSince ? new Date(plan.updatedSince) : null;

  for (var r = 1; r < plan.values.length; r++) {
    var sheetRowNumber = r + 1;
    var row = plan.values[r];
    if (isBlankRow7G_(row)) continue;

    var include = true;
    if (plan.exportScope === 'ROW_RANGE') {
      include = sheetRowNumber >= plan.startRow && sheetRowNumber <= plan.endRow;
    } else if (plan.exportScope === 'CLIENT_MUTATION_IDS' || plan.exportScope === 'RECORD_KEYS') {
      if (keyIdx === undefined) throw new Error('Kolom key tidak ditemukan: ' + plan.keyColumn);
      include = Boolean(keySet[normString7G_(row[keyIdx])]);
    } else if (plan.exportScope === 'UPDATED_SINCE') {
      if (updatedIdx === undefined) throw new Error('Kolom updated_at tidak ditemukan: ' + plan.updatedAtColumn);
      include = isDateOnOrAfter7G_(row[updatedIdx], sinceDate);
    } else if (plan.exportScope === 'UNEXPORTED_ONLY') {
      if (exportBatchIdx === undefined) throw new Error('Kolom export_batch_id tidak ditemukan: ' + plan.exportBatchColumn);
      include = !normString7G_(row[exportBatchIdx]);
    }

    if (!include) continue;

    rows.push({
      rowNumber: sheetRowNumber,
      key: keyIdx === undefined ? '' : normString7G_(row[keyIdx]),
      values: row
    });
  }
  return rows;
}

function markRowsExported7G_(plan, rows, checksum) {
  if (!rows.length) return;

  var exportBatchIdx = ensureColumn7G_(plan.sheet, plan.headers, plan.headerMap, plan.exportBatchColumn);
  var checksumIdx = ensureColumn7G_(plan.sheet, plan.headers, plan.headerMap, plan.checksumColumn);
  var exportedAtIdx = ensureColumn7G_(plan.sheet, plan.headers, plan.headerMap, plan.exportedAtColumn);
  var now = new Date();

  rows.forEach(function (r) {
    plan.sheet.getRange(r.rowNumber, exportBatchIdx + 1).setValue(plan.exportBatchId);
    plan.sheet.getRange(r.rowNumber, checksumIdx + 1).setValue(checksum);
    plan.sheet.getRange(r.rowNumber, exportedAtIdx + 1).setValue(now);
  });
}

function ensureColumn7G_(sheet, headers, headerMap, columnName) {
  if (headerMap[columnName] !== undefined) return headerMap[columnName];
  var newIndex = headers.length;
  sheet.getRange(1, newIndex + 1).setValue(columnName);
  headers.push(columnName);
  headerMap[columnName] = newIndex;
  return newIndex;
}

function appendExportLog7G_(plan, rows, checksum, csvFile, manifestFile) {
  var ss = plan.spreadsheet;
  var logSheet = ss.getSheetByName('export_log') || ss.insertSheet('export_log');
  if (logSheet.getLastRow() === 0) {
    logSheet.appendRow([
      'created_at', 'export_batch_id', 'kode_kecamatan', 'source_table', 'source_sheet',
      'export_scope', 'row_count', 'checksum_sha256', 'csv_file_id', 'csv_file_url',
      'manifest_file_id', 'selective_export_version', 'taxonomy_version'
    ]);
  }
  logSheet.appendRow([
    new Date(), plan.exportBatchId, plan.kodeKecamatan, plan.sourceTable, plan.sheetName,
    plan.exportScope, rows.length, checksum, csvFile ? csvFile.getId() : '', csvFile ? csvFile.getUrl() : '',
    manifestFile ? manifestFile.getId() : '', TPK_7G_SELECTIVE_EXPORT_VERSION, TPK_7G_TAXONOMY_VERSION
  ]);
}

function buildSelectiveExportResponse7G_(plan, rows, csvFile, manifestFile, exported, checksum, manifest) {
  return {
    ok: true,
    selective_export_version: TPK_7G_SELECTIVE_EXPORT_VERSION,
    taxonomy_version: TPK_7G_TAXONOMY_VERSION,
    export_batch_id: plan.exportBatchId,
    kode_kecamatan: plan.kodeKecamatan,
    source_workbook: plan.spreadsheetName,
    source_sheet: plan.sheetName,
    source_table: plan.sourceTable,
    export_scope: plan.exportScope,
    selected_row_count: rows.length,
    selected_record_keys: rows.map(function (r) { return r.key; }).filter(Boolean),
    selected_sheet_rows: rows.map(function (r) { return r.rowNumber; }),
    checksum_sha256: checksum || null,
    exported: Boolean(exported),
    csv_file_id: csvFile ? csvFile.getId() : null,
    csv_file_url: csvFile ? csvFile.getUrl() : null,
    manifest_file_id: manifestFile ? manifestFile.getId() : null,
    manifest: manifest || buildManifest7G_(plan, rows, checksum || null, csvFile ? csvFile.getId() : null, csvFile ? csvFile.getUrl() : null)
  };
}

function buildManifest7G_(plan, rows, checksum, csvFileId, csvFileUrl) {
  return {
    selective_export_version: TPK_7G_SELECTIVE_EXPORT_VERSION,
    taxonomy_version: TPK_7G_TAXONOMY_VERSION,
    export_batch_id: plan.exportBatchId,
    kode_kecamatan: plan.kodeKecamatan,
    source_workbook: plan.spreadsheetName,
    source_spreadsheet_id: plan.spreadsheetId,
    source_sheet: plan.sheetName,
    source_table: plan.sourceTable,
    export_scope: plan.exportScope,
    selected_row_count: rows.length,
    selected_record_keys: rows.map(function (r) { return r.key; }).filter(Boolean),
    selected_sheet_rows: rows.map(function (r) { return r.rowNumber; }),
    checksum_sha256: checksum,
    csv_file_id: csvFileId,
    csv_file_url: csvFileUrl,
    created_at: new Date().toISOString()
  };
}

function buildCsv7G_(headers, dataRows) {
  var rows = [headers].concat(dataRows);
  return rows.map(function (row) {
    return row.map(csvEscape7G_).join(',');
  }).join('\n');
}

function csvEscape7G_(value) {
  var s = value === null || value === undefined ? '' : String(value);
  if (value instanceof Date) s = value.toISOString();
  if (/[",\n\r]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
  return s;
}

function sha256Hex7G_(text) {
  var bytes = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, text, Utilities.Charset.UTF_8);
  return bytes.map(function (b) {
    var v = (b < 0 ? b + 256 : b).toString(16);
    return v.length === 1 ? '0' + v : v;
  }).join('');
}

function makeExportBatchId7G_(sourceTable, kodeKecamatan) {
  var tz = Session.getScriptTimeZone() || 'Asia/Makassar';
  var stamp = Utilities.formatDate(new Date(), tz, 'yyyyMMdd_HHmmss');
  return ['EXP7G', String(kodeKecamatan || 'NA').toUpperCase(), String(sourceTable || 'DATA').toUpperCase(), stamp].join('_');
}

function defaultKeyColumn7G_(sourceTable) {
  return sourceTable === 'pendampingan' ? 'pendampingan_unique_key' : 'sasaran_unique_key';
}

function buildHeaderMap7G_(headers) {
  var map = {};
  headers.forEach(function (h, i) {
    if (h) map[h] = i;
  });
  return map;
}

function isBlankRow7G_(row) {
  return row.every(function (v) { return normString7G_(v) === ''; });
}

function normString7G_(value) {
  return value === null || value === undefined ? '' : String(value).trim();
}

function toInt7G_(value, fallback) {
  var n = parseInt(value, 10);
  return isNaN(n) ? fallback : n;
}

function isDateOnOrAfter7G_(value, sinceDate) {
  if (!sinceDate || isNaN(sinceDate.getTime())) return true;
  var d = value instanceof Date ? value : new Date(value);
  if (isNaN(d.getTime())) return false;
  return d.getTime() >= sinceDate.getTime();
}

/** Smoke test ringan tanpa membaca spreadsheet. */
function testSelectiveExportBridge7G_NoWrite() {
  Logger.log(JSON.stringify({
    ok: true,
    selective_export_version: getSelectiveExportVersion7G(),
    taxonomy_version: TPK_7G_TAXONOMY_VERSION,
    scopes: ['ALL', 'ROW_RANGE', 'CLIENT_MUTATION_IDS', 'RECORD_KEYS', 'UPDATED_SINCE', 'UNEXPORTED_ONLY']
  }, null, 2));
}
