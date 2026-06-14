// src/supabase/readModelContract.js

export const SUPABASE_READ_MODEL_CONTRACT_VERSION = "supabase-read-model-p7d-20260615-r1";

export const SUPABASE_READ_MODEL_OBJECTS = Object.freeze({
  v_sasaran_lite: {
    purpose: "Read model ringan untuk daftar sasaran production base, termasuk status pendampingan ringkas dan hitungan bulanan.",
    source: "public.sasaran + public.pendampingan",
    key: "sasaran_id",
    unique_key: "sasaran_unique_key",
    query_pattern: "filter id_kecamatan, id_tim, jenis_sasaran, status_sasaran, search nama/NIK",
  },
  v_pendampingan_lite: {
    purpose: "Read model ringan untuk daftar dan riwayat pendampingan production base dengan identitas parent sasaran.",
    source: "public.pendampingan join public.sasaran",
    key: "pendampingan_id",
    unique_key: "pendampingan_unique_key",
    relation_key: "sasaran_id -> sasaran.sasaran_id",
  },
  v_summary_tim_basic: {
    purpose: "Ringkasan dasar per tim untuk jumlah sasaran dan laporan pendampingan Januari–Juni.",
    source: "public.sasaran + public.pendampingan",
    grain: "id_kecamatan + id_tim",
  },
  v_summary_kecamatan_basic: {
    purpose: "Ringkasan dasar per kecamatan untuk validasi awal data production base.",
    source: "public.sasaran + public.pendampingan",
    grain: "id_kecamatan",
  },
  query_sasaran_lite: {
    purpose: "SQL function invoker untuk query sasaran_lite dengan limit, offset, filter, dan search.",
    public_frontend_enabled: false,
    max_limit: 200,
  },
  query_pendampingan_lite: {
    purpose: "SQL function invoker untuk query pendampingan_lite dengan limit, offset, filter periode dan search.",
    public_frontend_enabled: false,
    max_limit: 200,
  },
  get_production_basic_summary: {
    purpose: "SQL function invoker untuk mengambil ringkasan JSON production base.",
    public_frontend_enabled: false,
  },
});

export const SUPABASE_READ_MODEL_SQL_FILES = Object.freeze([
  "supabase/migrations/20260615_10_backfill_production_read_models.sql",
  "supabase/migrations/20260615_11_backfill_basic_query_functions.sql",
  "supabase/migrations/20260615_12_backfill_read_model_access_and_health.sql",
]);

export function getSupabaseReadModelContractSummary() {
  return {
    ok: true,
    package: "Paket 7-D — Production Read Model & Basic Query Layer",
    contract_version: SUPABASE_READ_MODEL_CONTRACT_VERSION,
    mode: "SQL_ONLY_READ_MODEL_NO_FRONTEND_PROVIDER_ACTIVATION",
    project_expected: "tpk-backfill-staging",
    objects: SUPABASE_READ_MODEL_OBJECTS,
    sql_files: SUPABASE_READ_MODEL_SQL_FILES,
    required_preconditions: [
      "Paket 7-C sudah berhasil membuat public.sasaran dan public.pendampingan.",
      "Controlled promote sasaran sudah berhasil minimal satu baris.",
      "Controlled promote pendampingan sudah berhasil minimal satu baris dan relasi sasaran_id valid.",
      "Tabel production base tetap memakai RLS tanpa policy publik.",
    ],
    locked_decisions: [
      "Frontend production belum diaktifkan pada Paket 7-D.",
      "Read model dibuat sebagai view dan SQL query function, bukan tabel permanen/matview dulu.",
      "Read model memakai security_invoker dan akses anon/authenticated tetap ditutup.",
      "Query function dibatasi max 200 row per panggilan untuk mencegah full scan dari client nanti.",
      "Dashboard production penuh belum dibuat; Paket 7-D hanya basic query layer dan ringkasan validasi.",
    ],
    main_sql_calls: [
      "select * from public.query_sasaran_lite('TJK', 'TIM_TJK_001', null, 'AKTIF', null, 50, 0);",
      "select * from public.query_pendampingan_lite('TJK', 'TIM_TJK_001', 2026, 1, null, 50, 0);",
      "select public.get_production_basic_summary('TJK', 'TIM_TJK_001');",
      "select public.check_production_read_model_health();",
    ],
    next_package: "Paket 7-E — Production Master Reference & Scope Foundation",
  };
}
