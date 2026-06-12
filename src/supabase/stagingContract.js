// src/supabase/stagingContract.js

export const SUPABASE_STAGING_CONTRACT_VERSION = "supabase-staging-p7a-r1-20260612-r1";

export const SUPABASE_STAGING_TABLES = Object.freeze({
  staging_sasaran_import: {
    purpose: "CSV staging untuk registrasi sasaran hasil BACKFILL Google Sheet.",
    csv_header_fields: 57,
    extra_system_fields: ["staging_row_id", "loaded_at", "validation_status", "validated_at", "promoted_at"],
    import_key: "import_batch_id",
    unique_key: "sasaran_unique_key",
  },
  staging_pendampingan_import: {
    purpose: "CSV staging untuk laporan pendampingan Januari–Juni hasil BACKFILL Google Sheet.",
    csv_header_fields: 45,
    extra_system_fields: ["staging_row_id", "loaded_at", "validation_status", "validated_at", "promoted_at"],
    import_key: "import_batch_id",
    unique_key: "pendampingan_unique_key",
  },
  import_batch: {
    purpose: "Registry batch import CSV dari Google Sheet BACKFILL ke Supabase staging.",
    csv_header_fields: 16,
    import_key: "import_batch_id",
  },
  import_error: {
    purpose: "Catatan error validasi staging sebelum promote ke production.",
    csv_header_fields: 17,
    import_key: "import_batch_id",
  },
});

export const SUPABASE_STAGING_SQL_FILES = Object.freeze([
  "supabase/migrations/20260612_01_backfill_staging_schema.sql",
  "supabase/migrations/20260612_02_backfill_validation_functions.sql",
  "supabase/migrations/20260612_03_backfill_import_readiness_views.sql",
]);

export function getSupabaseStagingContractSummary() {
  return {
    ok: true,
    package: "Paket 7-A — Supabase Staging Schema & Import Contract",
    contract_version: SUPABASE_STAGING_CONTRACT_VERSION,
    mode: "SQL_ONLY_NO_PRODUCTION_PROMOTE",
    tables: SUPABASE_STAGING_TABLES,
    sql_files: SUPABASE_STAGING_SQL_FILES,
    locked_decisions: [
      "CSV dari Google Sheet masuk ke Supabase staging terlebih dahulu.",
      "Tabel production belum disentuh pada Paket 7-A.",
      "Kolom CSV staging dibuat sebagai text agar import tidak gagal prematur.",
      "Validasi dilakukan setelah import melalui SQL function validate_backfill_import_batch(import_batch_id).",
      "RLS diaktifkan tanpa policy publik agar staging tidak terbuka ke frontend.",
    ],
    next_package: "Paket 7-B — Supabase Import Validation & Promote Dry Run (aktif pada package ini)",
  };
}
