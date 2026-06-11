// src/validation/pendampinganValidation.js

import { FIELD_GROUPS } from "./constants.js";
import { validateBackfillPeriod, validateMonthlyReportLimit } from "./backfillValidation.js";
import {
  buildValidationResult,
  validateClientMutationId,
  validateIsoDate,
  validateNotFutureDate,
  validateRequiredFields,
} from "./validators.js";

export function buildPendampinganUniqueKey(payload) {
  const idSasaran = String(payload?.id_sasaran || payload?.id_sasaran_temp || "").trim();
  const periodeBulan = String(payload?.periode_bulan || "").trim().padStart(2, "0");
  const tahunLaporan = String(payload?.tahun_laporan || "").trim();

  return {
    unique_key: `${idSasaran}|${tahunLaporan}-${periodeBulan}`,
    strategy: "id_sasaran_periode_bulan_tahun_laporan",
    needs_review: !idSasaran,
  };
}

export function validatePendampinganPayload(payload, options = {}) {
  const issues = [
    ...validateRequiredFields(payload, FIELD_GROUPS.PENDAMPINGAN_BASE_REQUIRED),
    ...validateClientMutationId(payload?.client_mutation_id, "pdg"),
    ...validateIsoDate(payload?.tanggal_pendampingan, "tanggal_pendampingan"),
    ...validateNotFutureDate(payload?.tanggal_pendampingan, "tanggal_pendampingan", options.today || new Date()),
    ...validateBackfillPeriod(payload, options.backfill_config),
    ...validateMonthlyReportLimit(options.monthly_report_context || {}, options.backfill_config),
  ];

  const uniqueKey = buildPendampinganUniqueKey(payload);

  return buildValidationResult(issues, {
    entity: "pendampingan",
    unique_key: uniqueKey.unique_key,
    unique_key_strategy: uniqueKey.strategy,
    needs_review: uniqueKey.needs_review,
  });
}
