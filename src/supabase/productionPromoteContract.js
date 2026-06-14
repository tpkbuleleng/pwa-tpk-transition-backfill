// src/supabase/productionPromoteContract.js

export const SUPABASE_PRODUCTION_PROMOTE_CONTRACT_VERSION = "supabase-production-promote-p7c-20260614-r1";

export const SUPABASE_PRODUCTION_PROMOTE_OBJECTS = Object.freeze({
  sasaran: {
    purpose: "Tabel production base untuk sasaran hasil backfill yang sudah lolos staging dan dry-run.",
    primary_key: "sasaran_id",
    unique_key: "sasaran_unique_key",
    source: "dryrun_sasaran",
  },
  pendampingan: {
    purpose: "Tabel production base untuk pendampingan hasil backfill yang sudah lolos staging dan dry-run.",
    primary_key: "pendampingan_id",
    unique_key: "pendampingan_unique_key",
    relation_key: "sasaran_id -> sasaran.sasaran_id",
    source: "dryrun_pendampingan",
  },
  production_promote_batch: {
    purpose: "Registry eksekusi controlled promote dari tabel dry-run ke tabel production base.",
    key: "production_promote_batch_id",
    production_write: true,
  },
  production_promote_error: {
    purpose: "Catatan error saat controlled promote ke production base, termasuk duplikasi dan parent sasaran tidak ditemukan.",
    key: "production_promote_error_id",
    production_write: true,
  },
});

export const SUPABASE_PRODUCTION_PROMOTE_SQL_FILES = Object.freeze([
  "supabase/migrations/20260614_07_backfill_production_base_schema.sql",
  "supabase/migrations/20260614_08_backfill_controlled_promote_functions.sql",
  "supabase/migrations/20260614_09_backfill_production_promote_views.sql",
]);

export function getSupabaseProductionPromoteContractSummary() {
  return {
    ok: true,
    package: "Paket 7-C — Production Base Tables & Controlled Promote",
    contract_version: SUPABASE_PRODUCTION_PROMOTE_CONTRACT_VERSION,
    mode: "SQL_ONLY_CONTROLLED_PRODUCTION_BASE_PROMOTE",
    project_expected: "tpk-backfill-staging",
    objects: SUPABASE_PRODUCTION_PROMOTE_OBJECTS,
    sql_files: SUPABASE_PRODUCTION_PROMOTE_SQL_FILES,
    required_preconditions: [
      "Batch sasaran sudah valid di Supabase staging.",
      "Batch pendampingan sudah valid di Supabase staging.",
      "Data sasaran sudah berhasil masuk ke dryrun_sasaran.",
      "Data pendampingan sudah berhasil masuk ke dryrun_pendampingan.",
      "Pendampingan memiliki parent sasaran yang tersedia di tabel sasaran production base.",
      "Security Advisor tidak memiliki errors/warnings kritikal sebelum controlled promote.",
    ],
    locked_decisions: [
      "Paket 7-C mulai membuat tabel production base: sasaran dan pendampingan.",
      "Promote production base hanya dilakukan dari tabel dry-run, bukan langsung dari CSV staging.",
      "Duplikasi sasaran_unique_key dan pendampingan_unique_key ditolak sebelum insert production.",
      "Pendampingan wajib memiliki parent sasaran di production base.",
      "Tabel production base tetap memakai RLS tanpa policy publik pada tahap ini.",
      "Frontend production, Supabase Auth, dan RLS role kader belum diaktifkan pada Paket 7-C.",
    ],
    main_sql_calls: [
      "select public.promote_backfill_dryrun_to_production('IMPB_...', 'sasaran', false);",
      "select public.promote_backfill_dryrun_to_production('IMPB_...', 'pendampingan', false);",
      "select public.purge_backfill_production_promote(null, 'IMPB_...', false);"
    ],
    next_package: "Paket 7-D — Production Read Model & Basic Query Layer",
  };
}
