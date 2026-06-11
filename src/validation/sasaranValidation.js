// src/validation/sasaranValidation.js

import { FIELD_GROUPS, JENIS_KELAMIN, JENIS_SASARAN } from "./constants.js";
import { diffInCompletedMonths, toIsoDateOnly } from "./dateUtils.js";
import { createIssue, VALIDATION_MESSAGES } from "./validationMessages.js";
import {
  buildValidationResult,
  isBlank,
  validateClientMutationId,
  validateIsoDate,
  validateNik,
  validateNoKk,
  validateNotFutureDate,
  validateRequiredFields,
} from "./validators.js";

const ALLOWED_JENIS_SASARAN = Object.values(JENIS_SASARAN);

export function validateJenisSasaran(payload) {
  const jenis = String(payload?.jenis_sasaran || "").trim().toUpperCase();

  if (!ALLOWED_JENIS_SASARAN.includes(jenis)) {
    return [
      createIssue({
        field: "jenis_sasaran",
        code: "INVALID_JENIS_SASARAN",
        message: VALIDATION_MESSAGES.INVALID_JENIS_SASARAN,
        detail: {
          allowed: ALLOWED_JENIS_SASARAN,
        },
      }),
    ];
  }

  return [];
}

export function validateSasaranCategoryRules(payload, options = {}) {
  const issues = [];
  const jenis = String(payload?.jenis_sasaran || "").trim().toUpperCase();
  const jenisKelamin = String(payload?.jenis_kelamin || "").trim().toUpperCase();
  const referenceDate = options.reference_date || toIsoDateOnly(new Date());

  if (jenis === JENIS_SASARAN.BADUTA) {
    const ageMonths = diffInCompletedMonths(payload?.tanggal_lahir, referenceDate);

    if (ageMonths !== null && ageMonths > 24) {
      issues.push(
        createIssue({
          field: "tanggal_lahir",
          code: "BADUTA_MAX_24_MONTHS",
          message: VALIDATION_MESSAGES.BADUTA_MAX_24_MONTHS,
          detail: {
            age_months: ageMonths,
            reference_date: referenceDate,
          },
        }),
      );
    }
  }

  if (jenis === JENIS_SASARAN.BUMIL && jenisKelamin !== JENIS_KELAMIN.PEREMPUAN) {
    issues.push(
      createIssue({
        field: "jenis_kelamin",
        code: "BUMIL_MUST_BE_FEMALE",
        message: VALIDATION_MESSAGES.BUMIL_MUST_BE_FEMALE,
      }),
    );
  }

  if (jenis === JENIS_SASARAN.BUFAS && jenisKelamin !== JENIS_KELAMIN.PEREMPUAN) {
    issues.push(
      createIssue({
        field: "jenis_kelamin",
        code: "BUFAS_MUST_BE_FEMALE",
        message: VALIDATION_MESSAGES.BUFAS_MUST_BE_FEMALE,
      }),
    );
  }

  if (jenis === JENIS_SASARAN.CATIN && isBlank(payload?.nama_pasangan)) {
    issues.push(
      createIssue({
        field: "nama_pasangan",
        code: "CATIN_PARTNER_REQUIRED",
        message: VALIDATION_MESSAGES.CATIN_PARTNER_REQUIRED,
      }),
    );
  }

  return issues;
}

export function buildSasaranUniqueKey(payload) {
  const nik = String(payload?.nik || "").trim();
  const idTim = String(payload?.id_tim || "").trim();

  if (/^\d{16}$/.test(nik) && idTim) {
    return {
      unique_key: `${nik}|${idTim}`,
      strategy: "nik_id_tim",
      needs_review: false,
    };
  }

  const nama = String(payload?.nama_sasaran || "").trim().toUpperCase();
  const tanggalLahir = String(payload?.tanggal_lahir || "").trim();
  const namaIbu = String(payload?.nama_ibu_kandung || "").trim().toUpperCase();

  return {
    unique_key: `${nama}|${tanggalLahir}|${namaIbu}|${idTim}`,
    strategy: "fallback_nama_tanggal_lahir_nama_ibu_id_tim",
    needs_review: true,
  };
}

export function validateSasaranPayload(payload, options = {}) {
  const issues = [
    ...validateRequiredFields(payload, FIELD_GROUPS.SASARAN_BASE_REQUIRED),
    ...validateClientMutationId(payload?.client_mutation_id, "reg"),
    ...validateJenisSasaran(payload),
    ...validateNik(payload?.nik, "nik"),
    ...validateNoKk(payload?.no_kk, "no_kk"),
    ...validateIsoDate(payload?.tanggal_lahir, "tanggal_lahir"),
    ...validateNotFutureDate(payload?.tanggal_lahir, "tanggal_lahir", options.today || new Date()),
    ...validateSasaranCategoryRules(payload, options),
  ];

  const uniqueKey = buildSasaranUniqueKey(payload);

  return buildValidationResult(issues, {
    entity: "sasaran",
    unique_key: uniqueKey.unique_key,
    unique_key_strategy: uniqueKey.strategy,
    needs_review: uniqueKey.needs_review,
  });
}
