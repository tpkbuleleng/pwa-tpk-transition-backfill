// src/supabase/promoteDryRunContract.js

export const SUPABASE_PROMOTE_DRY_RUN_CONTRACT_VERSION = "supabase-promote-dryrun-p7b-20260612-r1";

export const SUPABASE_PROMOTE_DRY_RUN_OBJECTS = Object.freeze({
  promote_batch: {
    purpose: "Registry eksekusi promote dry run dari staging import ke tabel dryrun.",
    key: "promote_batch_id",
    dry_run_only: true,
  },
  promote_error: {
    purpose: "Catatan error relasi, duplikasi, atau status staging saat promote dry run.",
    key: "promote_error_id",
    dry_run_only: true,
  },
  dryrun_sasaran: {
    purpose: "Tabel tujuan sementara untuk sasaran yang lolos promote dry run. Bukan production final.",
    unique_key: "sasaran_unique_key",
    dry_run_only: true,
  },
  dryrun_pendampingan: {
    purpose: "Tabel tujuan sementara untuk pendampingan yang lolos promote dry run. Bukan production final.",
    unique_key: "pendampingan_unique_key",
    relation_key: "sasaran_unique_key",
    dry_run_only: true,
  },
});

export const SUPABASE_PROMOTE_DRY_RUN_SQL_FILES = Object.freeze([
  "supabase/migrations/20260612_04_backfill_promote_dryrun_schema.sql",
  "supabase/migrations/20260612_05_backfill_promote_dryrun_functions.sql",
  "supabase/migrations/20260612_06_backfill_promote_dryrun_views.sql",
]);

export function getSupabasePromoteDryRunContractSummary() {
  return {
    ok: true,
    package: "Paket 7-B — Supabase Import Validation & Promote Dry Run",
    contract_version: SUPABASE_PROMOTE_DRY_RUN_CONTRACT_VERSION,
    mode: "SQL_ONLY_DRY_RUN_NO_PRODUCTION_FINAL",
    project_expected: "tpk-backfill-staging",
    objects: SUPABASE_PROMOTE_DRY_RUN_OBJECTS,
    sql_files: SUPABASE_PROMOTE_DRY_RUN_SQL_FILES,
    required_preconditions: [
      "Batch import sasaran sudah valid dengan error_rows = 0.",
      "Batch import pendampingan sudah valid dengan error_rows = 0.",
      "Security Advisor tidak memiliki errors/warnings untuk staging.",
      "CSV pendampingan membawa nama_sasaran dan sasaran_unique_key.",
    ],
    locked_decisions: [
      "Promote Paket 7-B tidak menulis ke tabel production final.",
      "Data valid hanya ditulis ke dryrun_sasaran dan dryrun_pendampingan.",
      "Duplikasi sasaran_unique_key dan pendampingan_unique_key ditolak pada dry run.",
      "Relasi pendampingan ke sasaran dicek melalui sasaran_unique_key.",
      "Semua tabel dry-run memakai RLS tanpa policy publik agar tidak terbuka ke frontend.",
    ],
    main_sql_calls: [
      "select public.promote_backfill_batch_dry_run('IMPB_...', 'sasaran', false);",
      "select public.promote_backfill_batch_dry_run('IMPB_...', 'pendampingan', false);",
      "select public.purge_backfill_promote_dry_run(null, 'IMPB_...');",
    ],
    next_package: "Paket 7-C — Production Base Tables & Controlled Promote",
  };
}
