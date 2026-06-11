// src/contracts/csvHeaders.js

import { SASARAN_FIELDS } from "./dataDictionary/sasaranFields.js";
import { PENDAMPINGAN_FIELDS } from "./dataDictionary/pendampinganFields.js";
import {
  IMPORT_BATCH_FIELDS,
  IMPORT_ERROR_FIELDS,
  EXPORT_LOG_FIELDS,
} from "./dataDictionary/importFields.js";
import { MONTHS_BACKFILL } from "./enums.js";

export const CSV_HEADER_VERSION = "csv-contract-p2-20260612-r1";

export const STAGING_SASARAN_HEADER = Object.freeze(
  SASARAN_FIELDS.map((field) => field.name)
);

export const STAGING_PENDAMPINGAN_HEADER = Object.freeze(
  PENDAMPINGAN_FIELDS.map((field) => field.name)
);

export const IMPORT_BATCH_HEADER = Object.freeze(
  IMPORT_BATCH_FIELDS.map((field) => field.name)
);

export const IMPORT_ERROR_HEADER = Object.freeze(
  IMPORT_ERROR_FIELDS.map((field) => field.name)
);

export const EXPORT_LOG_HEADER = Object.freeze(
  EXPORT_LOG_FIELDS.map((field) => field.name)
);

export const BACKFILL_SHEET_NAMES = Object.freeze({
  SASARAN: "staging_sasaran",
  PENDAMPINGAN_BY_MONTH: Object.freeze(
    MONTHS_BACKFILL.reduce((acc, month) => {
      acc[month.code] = `staging_pendampingan_${month.code}`;
      return acc;
    }, {})
  ),
  IMPORT_ERROR: "import_error",
  EXPORT_LOG: "export_log",
});

export const SUPABASE_STAGING_TABLES = Object.freeze({
  SASARAN_IMPORT: "staging_sasaran_import",
  PENDAMPINGAN_IMPORT: "staging_pendampingan_import",
  IMPORT_BATCH: "import_batch",
  IMPORT_ERROR: "import_error",
});

export function toCsvHeaderLine(header) {
  return header.join(",");
}

export function getPendampinganSheetHeaderMap() {
  return MONTHS_BACKFILL.reduce((acc, month) => {
    acc[`staging_pendampingan_${month.code}`] = STAGING_PENDAMPINGAN_HEADER;
    return acc;
  }, {});
}

export function getGoogleSheetHeaderContract() {
  return {
    staging_sasaran: STAGING_SASARAN_HEADER,
    ...getPendampinganSheetHeaderMap(),
    import_error: IMPORT_ERROR_HEADER,
    export_log: EXPORT_LOG_HEADER,
  };
}

export function getSupabaseStagingHeaderContract() {
  return {
    staging_sasaran_import: STAGING_SASARAN_HEADER,
    staging_pendampingan_import: STAGING_PENDAMPINGAN_HEADER,
    import_batch: IMPORT_BATCH_HEADER,
    import_error: IMPORT_ERROR_HEADER,
  };
}
