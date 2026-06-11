// src/validation/backfillValidation.js

import { BACKFILL_CONFIG } from "./constants.js";
import { getMonthNumber, getYearNumber, parseIsoDate } from "./dateUtils.js";
import { createIssue, VALIDATION_MESSAGES } from "./validationMessages.js";
import { isBlank } from "./validators.js";

export function validateBackfillPeriod(payload, config = BACKFILL_CONFIG) {
  const issues = [];
  const periodeBulan = Number(payload?.periode_bulan);
  const tahunLaporan = Number(payload?.tahun_laporan);
  const tanggalPendampingan = payload?.tanggal_pendampingan;

  if (Number.isNaN(periodeBulan) || periodeBulan < config.bulanAwal || periodeBulan > config.bulanAkhir) {
    issues.push(
      createIssue({
        field: "periode_bulan",
        code: "INVALID_BACKFILL_MONTH",
        message: VALIDATION_MESSAGES.INVALID_BACKFILL_MONTH,
        detail: {
          allowed_month_start: config.bulanAwal,
          allowed_month_end: config.bulanAkhir,
        },
      }),
    );
  }

  if (tahunLaporan !== config.tahunLaporan) {
    issues.push(
      createIssue({
        field: "tahun_laporan",
        code: "INVALID_YEAR",
        message: VALIDATION_MESSAGES.INVALID_YEAR,
        detail: {
          expected_year: config.tahunLaporan,
        },
      }),
    );
  }

  if (!isBlank(tanggalPendampingan)) {
    const parsed = parseIsoDate(tanggalPendampingan);

    if (parsed) {
      const month = getMonthNumber(tanggalPendampingan);
      const year = getYearNumber(tanggalPendampingan);

      if (month !== periodeBulan || year !== tahunLaporan) {
        issues.push(
          createIssue({
            field: "tanggal_pendampingan",
            code: "DATE_MONTH_MISMATCH",
            message: VALIDATION_MESSAGES.DATE_MONTH_MISMATCH,
            detail: {
              expected_month: periodeBulan,
              actual_month: month,
              expected_year: tahunLaporan,
              actual_year: year,
            },
          }),
        );
      }
    }
  }

  return issues;
}

export function validateMonthlyReportLimit(context = {}, config = BACKFILL_CONFIG) {
  const existingCount = Number(context.existing_count_for_kader_month || 0);
  const newCount = Number(context.new_count || 1);

  if (existingCount + newCount > config.maxLaporanPerKaderPerBulan) {
    return [
      createIssue({
        field: "id_kader",
        code: "MAX_MONTHLY_REPORT",
        message: VALIDATION_MESSAGES.MAX_MONTHLY_REPORT,
        detail: {
          existing_count: existingCount,
          new_count: newCount,
          max: config.maxLaporanPerKaderPerBulan,
        },
      }),
    ];
  }

  return [];
}
