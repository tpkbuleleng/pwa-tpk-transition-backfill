/**
 * Apps Script minimal untuk Paket 1.
 *
 * Fungsi utama tahap ini hanya healthCheck dan standard response envelope.
 * Append ke Google Sheet staging belum dimasukkan pada Paket 1.
 */

const APP_BACKEND_VERSION = 'gas-backfill-provider-p1-20260612-r1';

function doGet(e) {
  return jsonResponse_(successResponse_({
    message: 'Apps Script BACKFILL endpoint aktif. Gunakan POST untuk action backend.',
    data: {
      method: 'GET',
      query: e && e.parameter ? e.parameter : {},
    },
    meta: {
      backend_version: APP_BACKEND_VERSION,
    },
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

      case 'login':
      case 'getMyProfileLite':
      case 'getMasterRefs':
      case 'submitRegistrasi':
      case 'submitPendampingan':
      case 'submitBatch':
      case 'getSubmitStatus':
        return jsonResponse_(errorResponse_({
          status: 'not_implemented',
          code: 'ACTION_NOT_IMPLEMENTED_IN_PACKAGE_1',
          message: 'Action ' + action + ' belum diimplementasikan pada Paket 1.',
          detail: {
            action: action,
          },
          meta: buildMeta_(meta, action),
        }));

      default:
        return jsonResponse_(errorResponse_({
          status: 'bad_request',
          code: 'UNKNOWN_ACTION',
          message: 'Action tidak dikenal: ' + action,
          detail: {
            action: action,
          },
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
      meta: {
        backend_version: APP_BACKEND_VERSION,
      },
    }));
  }
}

function handleHealthCheck_(payload, meta) {
  return successResponse_({
    message: 'Apps Script BACKFILL endpoint sehat.',
    data: {
      received_payload: payload || {},
      server_time: new Date().toISOString(),
    },
    meta: buildMeta_(meta, 'healthCheck'),
  });
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
