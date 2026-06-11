// src/utils/providerResponse.js

export function successResponse({
  data = null,
  message = "OK",
  meta = {},
} = {}) {
  return {
    ok: true,
    status: "success",
    message,
    data,
    error: null,
    meta,
  };
}

export function errorResponse({
  status = "server_error",
  code = "UNKNOWN_ERROR",
  message = "Terjadi kesalahan.",
  detail = null,
  meta = {},
} = {}) {
  return {
    ok: false,
    status,
    message,
    data: null,
    error: {
      code,
      message,
      detail,
    },
    meta,
  };
}

export function normalizeProviderError(error, meta = {}) {
  const isAbort = error?.name === "AbortError";

  return errorResponse({
    status: isAbort ? "timeout" : "server_error",
    code: isAbort ? "REQUEST_TIMEOUT" : "PROVIDER_ERROR",
    message: isAbort
      ? "Request backend melewati batas waktu."
      : error?.message || "Provider backend gagal dipanggil.",
    detail: {
      name: error?.name || null,
      message: error?.message || String(error),
    },
    meta,
  });
}
