// src/validation/validators.js

import { parseIsoDate, isFutureDate } from "./dateUtils.js";
import { createIssue, VALIDATION_MESSAGES } from "./validationMessages.js";

export function isBlank(value) {
  return value === null || value === undefined || String(value).trim() === "";
}

export function isSixteenDigitNumber(value) {
  return /^\d{16}$/.test(String(value || "").trim());
}

export function validateRequiredFields(payload, requiredFields = []) {
  const issues = [];

  for (const field of requiredFields) {
    if (isBlank(payload?.[field])) {
      issues.push(
        createIssue({
          field,
          code: "REQUIRED",
          message: VALIDATION_MESSAGES.REQUIRED,
        }),
      );
    }
  }

  return issues;
}

export function validateNik(value, field = "nik") {
  if (isBlank(value)) return [];

  if (!isSixteenDigitNumber(value)) {
    return [
      createIssue({
        field,
        code: "INVALID_NIK",
        message: VALIDATION_MESSAGES.INVALID_NIK,
      }),
    ];
  }

  return [];
}

export function validateNoKk(value, field = "no_kk") {
  if (isBlank(value)) return [];

  if (!isSixteenDigitNumber(value)) {
    return [
      createIssue({
        field,
        code: "INVALID_KK",
        message: VALIDATION_MESSAGES.INVALID_KK,
      }),
    ];
  }

  return [];
}

export function validateIsoDate(value, field) {
  if (isBlank(value)) return [];

  if (!parseIsoDate(value)) {
    return [
      createIssue({
        field,
        code: "INVALID_DATE",
        message: VALIDATION_MESSAGES.INVALID_DATE,
      }),
    ];
  }

  return [];
}

export function validateNotFutureDate(value, field, referenceDate = new Date()) {
  if (isBlank(value)) return [];

  if (!parseIsoDate(value)) {
    return validateIsoDate(value, field);
  }

  if (isFutureDate(value, referenceDate)) {
    return [
      createIssue({
        field,
        code: "FUTURE_DATE",
        message: VALIDATION_MESSAGES.FUTURE_DATE,
      }),
    ];
  }

  return [];
}

export function validateClientMutationId(value, expectedPrefix = null) {
  if (isBlank(value)) {
    return [
      createIssue({
        field: "client_mutation_id",
        code: "REQUIRED",
        message: VALIDATION_MESSAGES.REQUIRED,
      }),
    ];
  }

  const id = String(value).trim();
  const prefixPattern = expectedPrefix ? expectedPrefix : "[a-z]{3}";
  const regex = new RegExp(`^${prefixPattern}_\\d{17}_[a-z0-9]{8,}$`);

  if (!regex.test(id)) {
    return [
      createIssue({
        field: "client_mutation_id",
        code: "INVALID_CLIENT_MUTATION_ID",
        message: VALIDATION_MESSAGES.INVALID_CLIENT_MUTATION_ID,
        detail: { expected_prefix: expectedPrefix },
      }),
    ];
  }

  return [];
}

export function buildValidationResult(issues = [], meta = {}) {
  const errorCount = issues.filter((issue) => issue.severity !== "warning").length;

  return {
    ok: errorCount === 0,
    status: errorCount === 0 ? "valid" : "invalid",
    error_count: errorCount,
    warning_count: issues.length - errorCount,
    issues,
    meta,
  };
}
