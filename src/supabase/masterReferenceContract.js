// src/supabase/masterReferenceContract.js

export const SUPABASE_MASTER_REFERENCE_CONTRACT_VERSION = "supabase-master-reference-p7e-20260615-r1";

export const SUPABASE_MASTER_REFERENCE_OBJECTS = Object.freeze({
  master_kecamatan: {
    purpose: "Referensi kecamatan production untuk scope, query, dan RLS foundation.",
    primary_key: "id_kecamatan",
    unique_key: "kode_kecamatan",
    frontend_enabled: false,
  },
  master_tim: {
    purpose: "Referensi tim TPK per kecamatan untuk binding read model dan scope TIM.",
    primary_key: "id_tim",
    relation_key: "id_kecamatan -> master_kecamatan.id_kecamatan",
    frontend_enabled: false,
  },
  master_kader: {
    purpose: "Referensi kader / aktor operasional untuk scope KADER dan binding nama_kader.",
    primary_key: "id_kader",
    relation_key: "id_tim -> master_tim.id_tim",
    frontend_enabled: false,
  },
  master_wilayah: {
    purpose: "Referensi wilayah tugas untuk binding desa_kelurahan dan dusun_rw.",
    primary_key: "id_wilayah",
    relation_key: "id_kecamatan -> master_kecamatan.id_kecamatan",
    frontend_enabled: false,
  },
  scope_profile: {
    purpose: "Fondasi mapping user/auth ke role dan scope. Belum dipakai untuk Supabase Auth final.",
    primary_key: "scope_profile_id",
    future_auth_key: "auth_user_id",
    current_seed_key: "id_user / id_kader",
    frontend_enabled: false,
  },
  refresh_master_reference_from_production: {
    purpose: "SQL function untuk seed/refresh master references dari public.sasaran dan public.pendampingan.",
    public_frontend_enabled: false,
  },
  check_master_reference_health: {
    purpose: "SQL function untuk mengecek kesehatan master reference dan unresolved rows.",
    public_frontend_enabled: false,
  },
  get_scope_foundation_summary: {
    purpose: "SQL function untuk melihat ringkasan master reference dan scope profile per kecamatan/tim.",
    public_frontend_enabled: false,
  },
});

export const SUPABASE_MASTER_REFERENCE_SQL_FILES = Object.freeze([
  "supabase/migrations/20260615_13_backfill_master_reference_scope_schema.sql",
  "supabase/migrations/20260615_14_backfill_master_reference_seed_functions.sql",
  "supabase/migrations/20260615_15_backfill_scope_enriched_read_models.sql",
]);

export function getSupabaseMasterReferenceContractSummary() {
  return {
    ok: true,
    package: "Paket 7-E — Production Master Reference & Scope Foundation",
    contract_version: SUPABASE_MASTER_REFERENCE_CONTRACT_VERSION,
    mode: "SQL_ONLY_MASTER_REFERENCE_SCOPE_FOUNDATION_NO_AUTH_ACTIVATION",
    project_expected: "tpk-backfill-staging",
    objects: SUPABASE_MASTER_REFERENCE_OBJECTS,
    sql_files: SUPABASE_MASTER_REFERENCE_SQL_FILES,
    required_preconditions: [
      "Paket 7-C sudah berhasil menulis public.sasaran dan public.pendampingan.",
      "Paket 7-D sudah berhasil membuat read model dan query function dasar.",
      "Minimal satu sasaran dan satu pendampingan production base tersedia untuk seed master reference.",
    ],
    locked_decisions: [
      "Paket 7-E belum mengaktifkan SupabaseProvider frontend.",
      "Paket 7-E belum membuka policy RLS untuk anon/authenticated.",
      "scope_profile hanya fondasi mapping role/scope, bukan login final.",
      "master reference boleh diseed dari production base untuk backfill awal, lalu nanti diganti/dirapikan dari master resmi.",
      "Read model Paket 7-D diperkaya dengan master_kecamatan, master_tim, master_kader, dan master_wilayah tanpa mengubah kontrak kolom utama.",
    ],
    main_sql_calls: [
      "select public.refresh_master_reference_from_production('manual_test_p7e');",
      "select public.check_master_reference_health();",
      "select public.get_scope_foundation_summary('TJK', 'TIM_TJK_001');",
      "select * from public.query_sasaran_lite('TJK', 'TIM_TJK_001', null, 'AKTIF', null, 50, 0);",
      "select * from public.query_pendampingan_lite('TJK', 'TIM_TJK_001', 2026, 1, null, 50, 0);",
    ],
    next_package: "Paket 7-F — Supabase Auth & RLS Role Model Preparation",
  };
}
