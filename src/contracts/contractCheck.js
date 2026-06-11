// src/contracts/contractCheck.js

import { CSV_HEADER_VERSION, getGoogleSheetHeaderContract, getSupabaseStagingHeaderContract } from "./csvHeaders.js";
import { SASARAN_FIELDS } from "./dataDictionary/sasaranFields.js";
import { PENDAMPINGAN_FIELDS } from "./dataDictionary/pendampinganFields.js";
import { IMPORT_BATCH_FIELDS, IMPORT_ERROR_FIELDS, EXPORT_LOG_FIELDS } from "./dataDictionary/importFields.js";
import { buildPendampinganUniqueKey, buildSasaranUniqueKey } from "./uniqueKeyRules.js";

export function getRequiredFieldNames(fields) {
  return fields.filter((field) => field.required).map((field) => field.name);
}

export function getContractSummary() {
  const sampleSasaranWithNik = buildSasaranUniqueKey({
    nik: "5108010101010001",
    id_tim: "TIM_TJK_001",
    nama_sasaran: "NI LUH CONTOH",
    tanggal_lahir: "2024-01-15",
    nama_ibu_kandung: "NI MADE IBU",
  });

  const sampleSasaranFallback = buildSasaranUniqueKey({
    nik: "",
    id_tim: "TIM_TJK_001",
    nama_sasaran: "NI LUH CONTOH",
    tanggal_lahir: "2024-01-15",
    nama_ibu_kandung: "NI MADE IBU",
  });

  const samplePendampingan = buildPendampinganUniqueKey({
    sasaran_unique_key: sampleSasaranWithNik.sasaran_unique_key,
    periode_bulan: 1,
    tahun_laporan: 2026,
  });

  return {
    ok: true,
    package: "Paket 2 — Data Dictionary & CSV Contract",
    csv_header_version: CSV_HEADER_VERSION,
    dictionary_counts: {
      sasaran_fields: SASARAN_FIELDS.length,
      pendampingan_fields: PENDAMPINGAN_FIELDS.length,
      import_batch_fields: IMPORT_BATCH_FIELDS.length,
      import_error_fields: IMPORT_ERROR_FIELDS.length,
      export_log_fields: EXPORT_LOG_FIELDS.length,
    },
    required_fields: {
      sasaran: getRequiredFieldNames(SASARAN_FIELDS),
      pendampingan: getRequiredFieldNames(PENDAMPINGAN_FIELDS),
      import_batch: getRequiredFieldNames(IMPORT_BATCH_FIELDS),
      import_error: getRequiredFieldNames(IMPORT_ERROR_FIELDS),
      export_log: getRequiredFieldNames(EXPORT_LOG_FIELDS),
    },
    google_sheet_headers: getGoogleSheetHeaderContract(),
    supabase_staging_headers: getSupabaseStagingHeaderContract(),
    unique_key_samples: {
      sasaran_with_valid_nik: sampleSasaranWithNik,
      sasaran_fallback_needs_review: sampleSasaranFallback,
      pendampingan_one_sasaran_per_month: samplePendampingan,
    },
  };
}
