// src/contracts/enums.js

export const JENIS_SASARAN = Object.freeze({
  CATIN: "CATIN",
  BUMIL: "BUMIL",
  BUFAS: "BUFAS",
  BADUTA: "BADUTA",
  PUS: "PUS",
});

export const SOURCE_MODES = Object.freeze({
  BACKFILL: "BACKFILL",
  PRODUCTION: "PRODUCTION",
});

export const UNIQUE_KEY_STRATEGIES = Object.freeze({
  NIK_TIM: "NIK_TIM",
  FALLBACK_IDENTITY_TIM: "FALLBACK_IDENTITY_TIM",
});

export const REVIEW_FLAGS = Object.freeze({
  YES: "TRUE",
  NO: "FALSE",
});

export const MONTHS_BACKFILL = Object.freeze([
  { value: 1, code: "jan", label: "Januari" },
  { value: 2, code: "feb", label: "Februari" },
  { value: 3, code: "mar", label: "Maret" },
  { value: 4, code: "apr", label: "April" },
  { value: 5, code: "mei", label: "Mei" },
  { value: 6, code: "jun", label: "Juni" },
]);

export const BOOLEAN_TEXT = Object.freeze({
  TRUE: "TRUE",
  FALSE: "FALSE",
});
