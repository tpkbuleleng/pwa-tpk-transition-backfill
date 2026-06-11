// src/validation/validationMessages.js

export const VALIDATION_MESSAGES = Object.freeze({
  REQUIRED: "Field wajib diisi.",
  INVALID_NIK: "NIK wajib 16 digit angka.",
  INVALID_KK: "No. KK wajib 16 digit angka.",
  INVALID_DATE: "Tanggal tidak valid.",
  FUTURE_DATE: "Tanggal tidak boleh lebih dari hari ini.",
  INVALID_JENIS_SASARAN: "Jenis sasaran tidak valid.",
  BADUTA_MAX_24_MONTHS: "BADUTA maksimal berusia 24 bulan.",
  BUMIL_MUST_BE_FEMALE: "BUMIL wajib berjenis kelamin Perempuan.",
  BUFAS_MUST_BE_FEMALE: "BUFAS wajib berjenis kelamin Perempuan.",
  CATIN_PARTNER_REQUIRED: "Data pasangan CATIN wajib diisi minimal nama pasangan.",
  INVALID_BACKFILL_MONTH: "Periode BACKFILL hanya Januari sampai Juni 2026.",
  DATE_MONTH_MISMATCH: "Tanggal pendampingan harus sesuai periode bulan laporan.",
  INVALID_YEAR: "Tahun laporan tidak sesuai periode BACKFILL.",
  MAX_MONTHLY_REPORT: "Maksimal 10 laporan per kader per bulan.",
  INVALID_CLIENT_MUTATION_ID: "client_mutation_id tidak valid.",
  INVALID_SCOPE: "Data tidak sesuai cakupan tim/wilayah kader.",
});

export function createIssue({ field, code, message, severity = "error", detail = null }) {
  return {
    field,
    code,
    message,
    severity,
    detail,
  };
}
