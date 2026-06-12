/**
 * PWA TPK Kabupaten Buleleng
 * Paket 5 — Apps Script Provider & Sheet Staging
 *
 * Fungsi utama:
 * - healthCheck
 * - setupStagingSheets
 * - submitRegistrasi      -> append staging_sasaran
 * - submitPendampingan    -> append staging_pendampingan_jan/feb/mar/apr/mei/jun
 * - getSubmitStatus       -> cek client_mutation_id di sheet staging
 *
 * Cara pakai paling aman:
 * 1. Buka Google Sheet BACKFILL_TPK_TJK.
 * 2. Extensions -> Apps Script.
 * 3. Paste seluruh isi file ini ke Code.gs.
 * 4. Deploy -> Web app.
 * 5. Execute as: Me.
 * 6. Who has access: Anyone.
 * 7. Copy URL Web App ke src/config/backendConfig.js.
 */

const APP_BACKEND_VERSION = 'gas-backfill-provider-p5-20260612-r1';

/**
 * Jika Apps Script dibuat langsung dari Google Sheet melalui Extensions -> Apps Script,
 * biarkan kosong.
 *
 * Jika memakai Apps Script standalone, isi dengan Spreadsheet ID BACKFILL_TPK_TJK.
 * Contoh:
 * const BACKFILL_SPREADSHEET_ID = '1abcDEFxxxxx';
 */
const BACKFILL_SPREADSHEET_ID = '';

const BACKFILL_YEAR = 2026;
const BACKFILL_MONTH_START = 1;
const BACKFILL_MONTH_END = 6;
const MAX_REPORT_PER_KADER_PER_MONTH = 10;

const STAGING_SHEET_NAMES = Object.freeze({
  SASARAN: 'staging_sasaran',
  PENDAMPINGAN_JAN: 'staging_pendampingan_jan',
  PENDAMPINGAN_FEB: 'staging_pendampingan_feb',
  PENDAMPINGAN_MAR: 'staging_pendampingan_mar',
  PENDAMPINGAN_APR: 'staging_pendampingan_apr',
  PENDAMPINGAN_MEI: 'staging_pendampingan_mei',
  PENDAMPINGAN_JUN: 'staging_pendampingan_jun',
  IMPORT_ERROR: 'import_error',
  EXPORT_LOG: 'export_log',
});

const SASARAN_HEADERS = Object.freeze([
  'record_id',
  'client_mutation_id',
  'source_mode',
  'app_version',
  'import_batch_id',
  'id_kecamatan',
  'kode_kecamatan',
  'nama_kecamatan',
  'id_tim',
  'nomor_tim',
  'nama_tim',
  'id_kader',
  'nama_kader',
  'id_wilayah',
  'desa_kelurahan',
  'dusun_rw',
  'jenis_sasaran',
  'nik',
  'no_kk',
  'nama_sasaran',
  'jenis_kelamin',
  'tanggal_lahir',
  'usia_bulan',
  'alamat_lengkap',
  'nama_kepala_keluarga',
  'nama_ibu_kandung',
  'status_krs',
  'sumber_air_minum_utama',
  'fasilitas_bab',
  'nik_pasangan',
  'nama_pasangan',
  'kabupaten_pasangan',
  'kecamatan_pasangan',
  'desa_pasangan',
  'dusun_pasangan',
  'domisili_setelah_menikah',
  'usia_kehamilan_minggu',
  'bb_sebelum_hamil_kg',
  'kehamilan_diinginkan',
  'tanggal_melahirkan',
  'jenis_persalinan',
  'bb_lahir_kg',
  'pb_lahir_cm',
  'form_id',
  'form_version',
  'sasaran_unique_key',
  'unique_key_strategy',
  'needs_review',
  'review_reason',
  'form_answers_json',
  'raw_payload_json',
  'created_at_client',
  'submitted_at_server',
  'created_by',
  'updated_at',
  'is_deleted',
  'catatan',
]);

const PENDAMPINGAN_HEADERS = Object.freeze([
  'record_id',
  'client_mutation_id',
  'source_mode',
  'app_version',
  'import_batch_id',
  'id_kecamatan',
  'kode_kecamatan',
  'nama_kecamatan',
  'id_tim',
  'nomor_tim',
  'nama_tim',
  'id_kader',
  'nama_kader',
  'id_wilayah',
  'desa_kelurahan',
  'dusun_rw',
  'id_sasaran',
  'id_sasaran_temp',
  'sasaran_unique_key',
  'jenis_sasaran',
  'nik',
  'nama_sasaran',
  'periode_bulan',
  'tahun_laporan',
  'periode_yyyymm',
  'tanggal_pendampingan',
  'metode_pendampingan',
  'status_pendampingan',
  'hasil_pendampingan',
  'catatan_pendampingan',
  'rujukan_diperlukan',
  'jenis_rujukan',
  'form_id',
  'form_version',
  'pendampingan_unique_key',
  'form_answers_json',
  'raw_payload_json',
  'needs_review',
  'review_reason',
  'created_at_client',
  'submitted_at_server',
  'created_by',
  'updated_at',
  'is_deleted',
  'catatan',
]);

const IMPORT_ERROR_HEADERS = Object.freeze([
  'error_id',
  'import_batch_id',
  'source_sheet',
  'source_row_number',
  'client_mutation_id',
  'record_type',
  'unique_key',
  'error_level',
  'error_code',
  'error_message',
  'field_name',
  'field_value',
  'raw_row_json',
  'detected_at',
  'resolved_at',
  'resolved_by',
  'resolution_note',
]);

const EXPORT_LOG_HEADERS = Object.freeze([
  'export_id',
  'export_batch_id',
  'source_workbook',
  'source_sheet',
  'record_type',
  'periode_bulan',
  'tahun_laporan',
  'total_rows',
  'exported_by',
  'exported_at',
  'file_name',
  'checksum_sha256',
  'status',
  'notes',
]);

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('TPK Backfill')
    .addItem('Setup Sheet Staging', 'setupStagingSheetsMenu')
    .addToUi();
}

function setupStagingSheetsMenu() {
  const ss = getSpreadsheet_();
  const result = setupStagingSheets_(ss);
  SpreadsheetApp.getUi().alert('Setup selesai: ' + JSON.stringify(result.summary));
}

function doGet(e) {
  return jsonResponse_(successResponse_({
    message: 'Apps Script BACKFILL Paket 5 endpoint aktif. Gunakan POST untuk action backend.',
    data: {
      method: 'GET',
      query: e && e.parameter ? e.parameter : {},
    },
    meta: buildMeta_({}, 'GET'),
  }));
}

function doPost(e) {
  try {
    const request = parseRequest_(e);
    const action = request.action;
    const payload = request.payload || {};
    const meta = request.meta || {};

    switch (action) {
      case 'healthCheck':
        return jsonResponse_(handleHealthCheck_(payload, meta));

      case 'setupStagingSheets':
        return jsonResponse_(handleSetupStagingSheets_(payload, meta));

      case 'submitRegistrasi':
        return jsonResponse_(handleSubmitRegistrasi_(payload, meta));

      case 'submitPendampingan':
        return jsonResponse_(handleSubmitPendampingan_(payload, meta));

      case 'getSubmitStatus':
        return jsonResponse_(handleGetSubmitStatus_(payload, meta));

      case 'login':
      case 'getMyProfileLite':
      case 'getMasterRefs':
      case 'submitBatch':
        return jsonResponse_(errorResponse_({
          status: 'not_implemented',
          code: 'ACTION_NOT_IMPLEMENTED_IN_PACKAGE_5',
          message: 'Action ' + action + ' belum diimplementasikan pada Paket 5.',
          detail: { action: action },
          meta: buildMeta_(meta, action),
        }));

      default:
        return jsonResponse_(errorResponse_({
          status: 'bad_request',
          code: 'UNKNOWN_ACTION',
          message: 'Action tidak dikenal: ' + action,
          detail: { action: action },
          meta: buildMeta_(meta, action || 'unknown'),
        }));
    }
  } catch (err) {
    return jsonResponse_(errorResponse_({
      status: 'server_error',
      code: 'GAS_SERVER_ERROR',
      message: err && err.message ? err.message : String(err),
      detail: {
        name: err && err.name ? err.name : null,
        stack: err && err.stack ? err.stack : null,
      },
      meta: buildMeta_({}, 'server_error'),
    }));
  }
}

function handleHealthCheck_(payload, meta) {
  let spreadsheetInfo = null;

  try {
    const ss = getSpreadsheet_();
    spreadsheetInfo = {
      spreadsheet_id: ss.getId(),
      spreadsheet_name: ss.getName(),
      sheet_count: ss.getSheets().length,
    };
  } catch (err) {
    spreadsheetInfo = {
      error: err && err.message ? err.message : String(err),
    };
  }

  return successResponse_({
    message: 'Apps Script BACKFILL Paket 5 endpoint sehat.',
    data: {
      received_payload: payload || {},
      server_time: new Date().toISOString(),
      spreadsheet: spreadsheetInfo,
    },
    meta: buildMeta_(meta, 'healthCheck'),
  });
}

function handleSetupStagingSheets_(payload, meta) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);

  try {
    const ss = getSpreadsheet_();
    const result = setupStagingSheets_(ss);

    return successResponse_({
      message: 'Sheet staging berhasil disiapkan.',
      data: result,
      meta: buildMeta_(meta, 'setupStagingSheets'),
    });
  } finally {
    lock.releaseLock();
  }
}

function handleSubmitRegistrasi_(payload, meta) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);

  try {
    const ss = getSpreadsheet_();
    setupStagingSheets_(ss);

    const validation = validateSasaranBackend_(payload);
    if (!validation.ok) {
      logImportError_(ss, {
        source_sheet: STAGING_SHEET_NAMES.SASARAN,
        client_mutation_id: payload.client_mutation_id,
        record_type: 'sasaran',
        unique_key: payload.sasaran_unique_key,
        error_code: validation.error_code,
        error_message: validation.message,
        raw_payload: payload,
      });

      return errorResponse_({
        status: 'validation_error',
        code: validation.error_code,
        message: validation.message,
        detail: { issues: validation.issues },
        meta: buildMeta_(meta, 'submitRegistrasi'),
      });
    }

    const sheet = ss.getSheetByName(STAGING_SHEET_NAMES.SASARAN);
    const duplicateMutation = findRowByColumnValue_(sheet, SASARAN_HEADERS, 'client_mutation_id', payload.client_mutation_id);
    if (duplicateMutation) {
      return duplicateResponse_({
        message: 'client_mutation_id registrasi sudah pernah diproses.',
        sheetName: STAGING_SHEET_NAMES.SASARAN,
        rowNumber: duplicateMutation.rowNumber,
        recordType: 'sasaran',
        clientMutationId: payload.client_mutation_id,
        meta: buildMeta_(meta, 'submitRegistrasi'),
      });
    }

    const duplicateUniqueKey = findRowByColumnValue_(sheet, SASARAN_HEADERS, 'sasaran_unique_key', payload.sasaran_unique_key);
    if (duplicateUniqueKey) {
      return errorResponse_({
        status: 'duplicate',
        code: 'DUPLICATE_SASARAN_UNIQUE_KEY',
        message: 'Sasaran dengan unique key ini sudah ada di staging_sasaran.',
        detail: {
          sheet_name: STAGING_SHEET_NAMES.SASARAN,
          row_number: duplicateUniqueKey.rowNumber,
          sasaran_unique_key: payload.sasaran_unique_key,
        },
        meta: buildMeta_(meta, 'submitRegistrasi'),
      });
    }

    const rowObject = buildSasaranRowObject_(payload, meta);
    const appendResult = appendObjectRow_(sheet, SASARAN_HEADERS, rowObject);

    return successResponse_({
      message: 'Registrasi sasaran berhasil disimpan ke staging_sasaran.',
      data: {
        record_type: 'sasaran',
        sheet_name: STAGING_SHEET_NAMES.SASARAN,
        row_number: appendResult.row_number,
        record_id: rowObject.record_id,
        client_mutation_id: payload.client_mutation_id,
        sasaran_unique_key: payload.sasaran_unique_key,
      },
      meta: buildMeta_(meta, 'submitRegistrasi'),
    });
  } finally {
    lock.releaseLock();
  }
}

function handleSubmitPendampingan_(payload, meta) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);

  try {
    const ss = getSpreadsheet_();
    setupStagingSheets_(ss);

    const validation = validatePendampinganBackend_(payload);
    const sheetName = getPendampinganSheetName_(Number(payload.periode_bulan));

    if (!validation.ok) {
      logImportError_(ss, {
        source_sheet: sheetName || 'staging_pendampingan_unknown',
        client_mutation_id: payload.client_mutation_id,
        record_type: 'pendampingan',
        unique_key: payload.pendampingan_unique_key,
        error_code: validation.error_code,
        error_message: validation.message,
        raw_payload: payload,
      });

      return errorResponse_({
        status: 'validation_error',
        code: validation.error_code,
        message: validation.message,
        detail: { issues: validation.issues },
        meta: buildMeta_(meta, 'submitPendampingan'),
      });
    }

    const sheet = ss.getSheetByName(sheetName);

    const duplicateMutation = findRowByColumnValue_(sheet, PENDAMPINGAN_HEADERS, 'client_mutation_id', payload.client_mutation_id);
    if (duplicateMutation) {
      return duplicateResponse_({
        message: 'client_mutation_id pendampingan sudah pernah diproses.',
        sheetName: sheetName,
        rowNumber: duplicateMutation.rowNumber,
        recordType: 'pendampingan',
        clientMutationId: payload.client_mutation_id,
        meta: buildMeta_(meta, 'submitPendampingan'),
      });
    }

    const duplicateUniqueKey = findRowByColumnValue_(sheet, PENDAMPINGAN_HEADERS, 'pendampingan_unique_key', payload.pendampingan_unique_key);
    if (duplicateUniqueKey) {
      return errorResponse_({
        status: 'duplicate',
        code: 'DUPLICATE_PENDAMPINGAN_UNIQUE_KEY',
        message: 'Pendampingan untuk sasaran dan periode ini sudah ada di sheet staging bulan terkait.',
        detail: {
          sheet_name: sheetName,
          row_number: duplicateUniqueKey.rowNumber,
          pendampingan_unique_key: payload.pendampingan_unique_key,
        },
        meta: buildMeta_(meta, 'submitPendampingan'),
      });
    }

    const countForKader = countRowsByCriteria_(sheet, PENDAMPINGAN_HEADERS, {
      id_kader: payload.id_kader,
      tahun_laporan: String(payload.tahun_laporan),
      periode_bulan: String(payload.periode_bulan),
    });

    if (countForKader >= MAX_REPORT_PER_KADER_PER_MONTH) {
      return errorResponse_({
        status: 'validation_error',
        code: 'MAX_MONTHLY_REPORT',
        message: 'Maksimal 10 laporan per kader per bulan sudah tercapai di sheet staging.',
        detail: {
          id_kader: payload.id_kader,
          periode_bulan: payload.periode_bulan,
          tahun_laporan: payload.tahun_laporan,
          existing_count: countForKader,
          max: MAX_REPORT_PER_KADER_PER_MONTH,
        },
        meta: buildMeta_(meta, 'submitPendampingan'),
      });
    }

    const rowObject = buildPendampinganRowObject_(payload, meta);
    const appendResult = appendObjectRow_(sheet, PENDAMPINGAN_HEADERS, rowObject);

    return successResponse_({
      message: 'Pendampingan berhasil disimpan ke ' + sheetName + '.',
      data: {
        record_type: 'pendampingan',
        sheet_name: sheetName,
        row_number: appendResult.row_number,
        record_id: rowObject.record_id,
        client_mutation_id: payload.client_mutation_id,
        pendampingan_unique_key: payload.pendampingan_unique_key,
      },
      meta: buildMeta_(meta, 'submitPendampingan'),
    });
  } finally {
    lock.releaseLock();
  }
}

function handleGetSubmitStatus_(payload, meta) {
  const ss = getSpreadsheet_();
  setupStagingSheets_(ss);

  const clientMutationId = text_(payload.client_mutation_id);
  if (!clientMutationId) {
    return errorResponse_({
      status: 'bad_request',
      code: 'CLIENT_MUTATION_ID_REQUIRED',
      message: 'client_mutation_id wajib diisi.',
      meta: buildMeta_(meta, 'getSubmitStatus'),
    });
  }

  const sheetsToSearch = [
    { name: STAGING_SHEET_NAMES.SASARAN, headers: SASARAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_JAN, headers: PENDAMPINGAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_FEB, headers: PENDAMPINGAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_MAR, headers: PENDAMPINGAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_APR, headers: PENDAMPINGAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_MEI, headers: PENDAMPINGAN_HEADERS },
    { name: STAGING_SHEET_NAMES.PENDAMPINGAN_JUN, headers: PENDAMPINGAN_HEADERS },
  ];

  for (const item of sheetsToSearch) {
    const sheet = ss.getSheetByName(item.name);
    const found = findRowByColumnValue_(sheet, item.headers, 'client_mutation_id', clientMutationId);
    if (found) {
      return successResponse_({
        message: 'Submit ditemukan di staging.',
        data: {
          found: true,
          sheet_name: item.name,
          row_number: found.rowNumber,
          client_mutation_id: clientMutationId,
        },
        meta: buildMeta_(meta, 'getSubmitStatus'),
      });
    }
  }

  return successResponse_({
    message: 'Submit belum ditemukan di staging.',
    data: {
      found: false,
      client_mutation_id: clientMutationId,
    },
    meta: buildMeta_(meta, 'getSubmitStatus'),
  });
}

function setupStagingSheets_(ss) {
  const result = [];

  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.SASARAN, SASARAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_JAN, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_FEB, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_MAR, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_APR, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_MEI, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.PENDAMPINGAN_JUN, PENDAMPINGAN_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.IMPORT_ERROR, IMPORT_ERROR_HEADERS));
  result.push(ensureSheetWithHeaders_(ss, STAGING_SHEET_NAMES.EXPORT_LOG, EXPORT_LOG_HEADERS));

  return {
    spreadsheet_id: ss.getId(),
    spreadsheet_name: ss.getName(),
    backend_version: APP_BACKEND_VERSION,
    sheets: result,
    summary: {
      total: result.length,
      created: result.filter(function (item) { return item.created; }).length,
      header_written: result.filter(function (item) { return item.header_written; }).length,
    },
  };
}

function ensureSheetWithHeaders_(ss, sheetName, headers) {
  let sheet = ss.getSheetByName(sheetName);
  let created = false;

  if (!sheet) {
    sheet = ss.insertSheet(sheetName);
    created = true;
  }

  const existingHeader = sheet.getRange(1, 1, 1, headers.length).getValues()[0];
  const existingJoined = existingHeader.map(String).join('|');
  const expectedJoined = headers.join('|');
  let headerWritten = false;

  if (existingJoined !== expectedJoined) {
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    sheet.setFrozenRows(1);
    headerWritten = true;
  }

  sheet.getRange(1, 1, Math.max(sheet.getMaxRows(), 1), headers.length).setNumberFormat('@');
  sheet.autoResizeColumns(1, Math.min(headers.length, 20));

  return {
    sheet_name: sheetName,
    created: created,
    header_written: headerWritten,
    column_count: headers.length,
  };
}

function validateSasaranBackend_(payload) {
  const issues = [];

  required_(payload, issues, [
    'client_mutation_id',
    'source_mode',
    'app_version',
    'id_kecamatan',
    'nama_kecamatan',
    'id_tim',
    'id_kader',
    'id_wilayah',
    'desa_kelurahan',
    'dusun_rw',
    'jenis_sasaran',
    'nama_sasaran',
    'jenis_kelamin',
    'tanggal_lahir',
    'sasaran_unique_key',
    'unique_key_strategy',
  ]);

  if (!/^reg_\d{17}_[a-z0-9]{8,}$/i.test(text_(payload.client_mutation_id))) {
    issues.push(issue_('client_mutation_id', 'INVALID_CLIENT_MUTATION_ID', 'client_mutation_id registrasi tidak valid.'));
  }

  if (text_(payload.nik) && !/^\d{16}$/.test(text_(payload.nik))) {
    issues.push(issue_('nik', 'INVALID_NIK', 'NIK wajib 16 digit angka.'));
  }

  if (text_(payload.no_kk) && !/^\d{16}$/.test(text_(payload.no_kk))) {
    issues.push(issue_('no_kk', 'INVALID_KK', 'No. KK wajib 16 digit angka.'));
  }

  if (!isIsoDate_(payload.tanggal_lahir)) {
    issues.push(issue_('tanggal_lahir', 'INVALID_DATE', 'Tanggal lahir harus format YYYY-MM-DD.'));
  }

  if (!['CATIN', 'BUMIL', 'BUFAS', 'BADUTA'].includes(text_(payload.jenis_sasaran))) {
    issues.push(issue_('jenis_sasaran', 'INVALID_JENIS_SASARAN', 'Jenis sasaran tidak valid.'));
  }

  return validationResult_(issues);
}

function validatePendampinganBackend_(payload) {
  const issues = [];

  required_(payload, issues, [
    'client_mutation_id',
    'source_mode',
    'app_version',
    'id_kecamatan',
    'nama_kecamatan',
    'id_tim',
    'id_kader',
    'id_wilayah',
    'jenis_sasaran',
    'periode_bulan',
    'tahun_laporan',
    'tanggal_pendampingan',
    'pendampingan_unique_key',
    'unique_key_strategy',
  ]);

  if (!/^pdg_\d{17}_[a-z0-9]{8,}$/i.test(text_(payload.client_mutation_id))) {
    issues.push(issue_('client_mutation_id', 'INVALID_CLIENT_MUTATION_ID', 'client_mutation_id pendampingan tidak valid.'));
  }

  const month = Number(payload.periode_bulan);
  const year = Number(payload.tahun_laporan);

  if (month < BACKFILL_MONTH_START || month > BACKFILL_MONTH_END) {
    issues.push(issue_('periode_bulan', 'INVALID_BACKFILL_MONTH', 'Periode BACKFILL hanya Januari sampai Juni 2026.'));
  }

  if (year !== BACKFILL_YEAR) {
    issues.push(issue_('tahun_laporan', 'INVALID_YEAR', 'Tahun laporan harus 2026.'));
  }

  if (!isIsoDate_(payload.tanggal_pendampingan)) {
    issues.push(issue_('tanggal_pendampingan', 'INVALID_DATE', 'Tanggal pendampingan harus format YYYY-MM-DD.'));
  } else {
    const parts = text_(payload.tanggal_pendampingan).split('-').map(Number);
    if (parts[0] !== year || parts[1] !== month) {
      issues.push(issue_('tanggal_pendampingan', 'DATE_MONTH_MISMATCH', 'Tanggal pendampingan harus sesuai periode bulan laporan.'));
    }
  }

  if (!text_(payload.id_sasaran) && !text_(payload.id_sasaran_temp)) {
    issues.push(issue_('id_sasaran_temp', 'SASARAN_ID_REQUIRED', 'id_sasaran atau id_sasaran_temp wajib diisi.'));
  }

  return validationResult_(issues);
}

function required_(payload, issues, fields) {
  fields.forEach(function (field) {
    if (!text_(payload[field])) {
      issues.push(issue_(field, 'REQUIRED', 'Field wajib diisi.'));
    }
  });
}

function issue_(field, code, message) {
  return {
    field: field,
    code: code,
    message: message,
    severity: 'error',
  };
}

function validationResult_(issues) {
  if (!issues.length) {
    return {
      ok: true,
      issues: [],
      error_code: null,
      message: 'Valid.',
    };
  }

  return {
    ok: false,
    issues: issues,
    error_code: issues[0].code || 'VALIDATION_ERROR',
    message: issues[0].message || 'Data belum valid.',
  };
}

function buildSasaranRowObject_(payload, meta) {
  const now = new Date().toISOString();

  return {
    record_id: makeRecordId_('SAS'),
    client_mutation_id: text_(payload.client_mutation_id),
    source_mode: text_(payload.source_mode),
    app_version: text_(payload.app_version),
    import_batch_id: text_(payload.import_batch_id),
    id_kecamatan: text_(payload.id_kecamatan),
    kode_kecamatan: text_(payload.kode_kecamatan || payload.id_kecamatan),
    nama_kecamatan: text_(payload.nama_kecamatan),
    id_tim: text_(payload.id_tim),
    nomor_tim: text_(payload.nomor_tim),
    nama_tim: text_(payload.nama_tim),
    id_kader: text_(payload.id_kader),
    nama_kader: text_(payload.nama_kader),
    id_wilayah: text_(payload.id_wilayah),
    desa_kelurahan: text_(payload.desa_kelurahan),
    dusun_rw: text_(payload.dusun_rw),
    jenis_sasaran: text_(payload.jenis_sasaran),
    nik: text_(payload.nik),
    no_kk: text_(payload.no_kk),
    nama_sasaran: text_(payload.nama_sasaran),
    jenis_kelamin: text_(payload.jenis_kelamin),
    tanggal_lahir: text_(payload.tanggal_lahir),
    usia_bulan: text_(payload.usia_bulan),
    alamat_lengkap: text_(payload.alamat_lengkap),
    nama_kepala_keluarga: text_(payload.nama_kepala_keluarga),
    nama_ibu_kandung: text_(payload.nama_ibu_kandung),
    status_krs: text_(payload.status_krs),
    sumber_air_minum_utama: text_(payload.sumber_air_minum_utama),
    fasilitas_bab: text_(payload.fasilitas_bab),
    nik_pasangan: text_(payload.nik_pasangan),
    nama_pasangan: text_(payload.nama_pasangan),
    kabupaten_pasangan: text_(payload.kabupaten_pasangan),
    kecamatan_pasangan: text_(payload.kecamatan_pasangan),
    desa_pasangan: text_(payload.desa_pasangan),
    dusun_pasangan: text_(payload.dusun_pasangan),
    domisili_setelah_menikah: text_(payload.domisili_setelah_menikah),
    usia_kehamilan_minggu: text_(payload.usia_kehamilan_minggu),
    bb_sebelum_hamil_kg: text_(payload.bb_sebelum_hamil_kg),
    kehamilan_diinginkan: text_(payload.kehamilan_diinginkan),
    tanggal_melahirkan: text_(payload.tanggal_melahirkan),
    jenis_persalinan: text_(payload.jenis_persalinan),
    bb_lahir_kg: text_(payload.bb_lahir_kg),
    pb_lahir_cm: text_(payload.pb_lahir_cm),
    form_id: text_(payload.form_id || 'BACKFILL_REGISTRASI_SASARAN'),
    form_version: text_(payload.form_version || payload.app_version),
    sasaran_unique_key: text_(payload.sasaran_unique_key),
    unique_key_strategy: text_(payload.unique_key_strategy),
    needs_review: boolText_(payload.needs_review),
    review_reason: text_(payload.review_reason),
    form_answers_json: stringify_(payload.form_answers_json || {}),
    raw_payload_json: stringify_(payload),
    created_at_client: text_(payload.created_at_client || meta.client_time),
    submitted_at_server: now,
    created_by: text_(payload.created_by || payload.id_kader),
    updated_at: now,
    is_deleted: 'FALSE',
    catatan: text_(payload.catatan || payload.catatan_backfill),
  };
}

function buildPendampinganRowObject_(payload, meta) {
  const now = new Date().toISOString();
  const month = String(payload.periode_bulan).padStart(2, '0');
  const periodeYyyymm = String(payload.tahun_laporan) + month;

  return {
    record_id: makeRecordId_('PDG'),
    client_mutation_id: text_(payload.client_mutation_id),
    source_mode: text_(payload.source_mode),
    app_version: text_(payload.app_version),
    import_batch_id: text_(payload.import_batch_id),
    id_kecamatan: text_(payload.id_kecamatan),
    kode_kecamatan: text_(payload.kode_kecamatan || payload.id_kecamatan),
    nama_kecamatan: text_(payload.nama_kecamatan),
    id_tim: text_(payload.id_tim),
    nomor_tim: text_(payload.nomor_tim),
    nama_tim: text_(payload.nama_tim),
    id_kader: text_(payload.id_kader),
    nama_kader: text_(payload.nama_kader),
    id_wilayah: text_(payload.id_wilayah),
    desa_kelurahan: text_(payload.desa_kelurahan),
    dusun_rw: text_(payload.dusun_rw),
    id_sasaran: text_(payload.id_sasaran),
    id_sasaran_temp: text_(payload.id_sasaran_temp),
    sasaran_unique_key: text_(payload.sasaran_unique_key || payload.id_sasaran || payload.id_sasaran_temp),
    jenis_sasaran: text_(payload.jenis_sasaran),
    nik: text_(payload.nik),
    nama_sasaran: text_(payload.nama_sasaran),
    periode_bulan: text_(payload.periode_bulan),
    tahun_laporan: text_(payload.tahun_laporan),
    periode_yyyymm: periodeYyyymm,
    tanggal_pendampingan: text_(payload.tanggal_pendampingan),
    metode_pendampingan: text_(payload.metode_pendampingan || payload.status_pendampingan),
    status_pendampingan: text_(payload.status_pendampingan),
    hasil_pendampingan: text_(payload.hasil_pendampingan),
    catatan_pendampingan: text_(payload.catatan_pendampingan),
    rujukan_diperlukan: text_(payload.rujukan_diperlukan),
    jenis_rujukan: text_(payload.jenis_rujukan),
    form_id: text_(payload.form_id || 'BACKFILL_PENDAMPINGAN'),
    form_version: text_(payload.form_version || payload.app_version),
    pendampingan_unique_key: text_(payload.pendampingan_unique_key),
    form_answers_json: stringify_(payload.form_answers_json || {}),
    raw_payload_json: stringify_(payload),
    needs_review: boolText_(payload.needs_review),
    review_reason: text_(payload.review_reason),
    created_at_client: text_(payload.created_at_client || meta.client_time),
    submitted_at_server: now,
    created_by: text_(payload.created_by || payload.id_kader),
    updated_at: now,
    is_deleted: 'FALSE',
    catatan: text_(payload.catatan || payload.catatan_pendampingan),
  };
}

function appendObjectRow_(sheet, headers, rowObject) {
  const row = headers.map(function (header) {
    return Object.prototype.hasOwnProperty.call(rowObject, header) ? rowObject[header] : '';
  });

  sheet.appendRow(row);
  const rowNumber = sheet.getLastRow();
  sheet.getRange(rowNumber, 1, 1, row.length).setNumberFormat('@');

  return {
    row_number: rowNumber,
  };
}

function findRowByColumnValue_(sheet, headers, columnName, expectedValue) {
  if (!sheet || !expectedValue) return null;

  const colIndex = headers.indexOf(columnName) + 1;
  if (colIndex <= 0) return null;

  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return null;

  const values = sheet.getRange(2, colIndex, lastRow - 1, 1).getDisplayValues();
  const expected = text_(expectedValue);

  for (let i = 0; i < values.length; i++) {
    if (text_(values[i][0]) === expected) {
      return {
        rowNumber: i + 2,
        value: expected,
      };
    }
  }

  return null;
}

function countRowsByCriteria_(sheet, headers, criteria) {
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return 0;

  const values = sheet.getRange(2, 1, lastRow - 1, headers.length).getDisplayValues();
  let count = 0;

  values.forEach(function (row) {
    const matched = Object.keys(criteria).every(function (key) {
      const index = headers.indexOf(key);
      if (index < 0) return false;
      return text_(row[index]) === text_(criteria[key]);
    });

    if (matched) count++;
  });

  return count;
}

function logImportError_(ss, options) {
  try {
    const sheet = ss.getSheetByName(STAGING_SHEET_NAMES.IMPORT_ERROR);
    if (!sheet) return;

    const rowObject = {
      error_id: makeRecordId_('ERR'),
      import_batch_id: '',
      source_sheet: text_(options.source_sheet),
      source_row_number: '',
      client_mutation_id: text_(options.client_mutation_id),
      record_type: text_(options.record_type),
      unique_key: text_(options.unique_key),
      error_level: 'error',
      error_code: text_(options.error_code),
      error_message: text_(options.error_message),
      field_name: '',
      field_value: '',
      raw_row_json: stringify_(options.raw_payload || {}),
      detected_at: new Date().toISOString(),
      resolved_at: '',
      resolved_by: '',
      resolution_note: '',
    };

    appendObjectRow_(sheet, IMPORT_ERROR_HEADERS, rowObject);
  } catch (err) {
    console.error('Gagal menulis import_error:', err);
  }
}

function duplicateResponse_(options) {
  return errorResponse_({
    status: 'duplicate',
    code: 'DUPLICATE_CLIENT_MUTATION_ID',
    message: options.message,
    detail: {
      record_type: options.recordType,
      sheet_name: options.sheetName,
      row_number: options.rowNumber,
      client_mutation_id: options.clientMutationId,
    },
    meta: options.meta || {},
  });
}

function getPendampinganSheetName_(month) {
  const map = {
    1: STAGING_SHEET_NAMES.PENDAMPINGAN_JAN,
    2: STAGING_SHEET_NAMES.PENDAMPINGAN_FEB,
    3: STAGING_SHEET_NAMES.PENDAMPINGAN_MAR,
    4: STAGING_SHEET_NAMES.PENDAMPINGAN_APR,
    5: STAGING_SHEET_NAMES.PENDAMPINGAN_MEI,
    6: STAGING_SHEET_NAMES.PENDAMPINGAN_JUN,
  };

  return map[Number(month)] || null;
}

function getSpreadsheet_() {
  if (BACKFILL_SPREADSHEET_ID) {
    return SpreadsheetApp.openById(BACKFILL_SPREADSHEET_ID);
  }

  const active = SpreadsheetApp.getActiveSpreadsheet();
  if (!active) {
    throw new Error('Spreadsheet aktif tidak ditemukan. Jika memakai Apps Script standalone, isi BACKFILL_SPREADSHEET_ID di Code.gs.');
  }

  return active;
}

function parseRequest_(e) {
  if (!e || !e.postData || !e.postData.contents) {
    throw new Error('Request body kosong.');
  }

  try {
    return JSON.parse(e.postData.contents);
  } catch (err) {
    throw new Error('Request body bukan JSON valid.');
  }
}

function buildMeta_(clientMeta, action) {
  return {
    provider: 'GASProvider',
    app_mode: 'BACKFILL',
    action: action,
    backend_version: APP_BACKEND_VERSION,
    server_time: new Date().toISOString(),
    client_meta: clientMeta || {},
  };
}

function successResponse_(options) {
  options = options || {};

  return {
    ok: true,
    status: 'success',
    message: options.message || 'OK',
    data: options.data || null,
    error: null,
    meta: options.meta || {},
  };
}

function errorResponse_(options) {
  options = options || {};

  return {
    ok: false,
    status: options.status || 'server_error',
    message: options.message || 'Terjadi kesalahan.',
    data: null,
    error: {
      code: options.code || 'UNKNOWN_ERROR',
      message: options.message || 'Terjadi kesalahan.',
      detail: options.detail || null,
    },
    meta: options.meta || {},
  };
}

function jsonResponse_(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function makeRecordId_(prefix) {
  const stamp = Utilities.formatDate(new Date(), 'Asia/Makassar', 'yyyyMMddHHmmssSSS');
  const random = Utilities.getUuid().replace(/-/g, '').slice(0, 8).toUpperCase();
  return prefix + '_' + stamp + '_' + random;
}

function text_(value) {
  if (value === null || value === undefined) return '';
  return String(value).trim();
}

function boolText_(value) {
  if (value === true || text_(value).toUpperCase() === 'TRUE' || text_(value).toUpperCase() === 'YA') {
    return 'TRUE';
  }

  return 'FALSE';
}

function stringify_(value) {
  if (typeof value === 'string') return value;
  try {
    return JSON.stringify(value || {});
  } catch (err) {
    return '{}';
  }
}

function isIsoDate_(value) {
  const text = text_(value);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(text)) return false;

  const parts = text.split('-').map(Number);
  const date = new Date(text + 'T00:00:00');

  return (
    !isNaN(date.getTime()) &&
    date.getFullYear() === parts[0] &&
    date.getMonth() + 1 === parts[1] &&
    date.getDate() === parts[2]
  );
}
