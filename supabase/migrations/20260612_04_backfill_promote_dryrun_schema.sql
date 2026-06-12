-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-B — Supabase Import Validation & Promote Dry Run
-- File 01: Dry-run promote schema
-- Version: p7b-20260612-r1
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.promote_batch (
  promote_batch_id text primary key,
  created_at timestamptz not null default now(),
  import_batch_id text not null,
  record_type text not null,
  dry_run boolean not null default true,
  status text not null default 'pending',
  sasaran_rows integer not null default 0,
  pendampingan_rows integer not null default 0,
  error_rows integer not null default 0,
  promoted_at timestamptz,
  promoted_by text,
  notes text
);

create index if not exists idx_promote_batch_import_batch_id
  on public.promote_batch(import_batch_id);

create index if not exists idx_promote_batch_status
  on public.promote_batch(status);

create table if not exists public.promote_error (
  promote_error_id bigserial primary key,
  created_at timestamptz not null default now(),
  promote_batch_id text not null references public.promote_batch(promote_batch_id) on delete cascade,
  import_batch_id text not null,
  record_type text not null,
  staging_row_id bigint,
  client_mutation_id text,
  unique_key text,
  error_level text not null default 'error',
  error_code text not null,
  error_message text not null,
  field_name text,
  field_value text,
  raw_row_json jsonb,
  resolved_at timestamptz,
  resolved_by text,
  resolution_note text
);

create index if not exists idx_promote_error_promote_batch_id
  on public.promote_error(promote_batch_id);

create index if not exists idx_promote_error_import_batch_id
  on public.promote_error(import_batch_id);

create index if not exists idx_promote_error_code
  on public.promote_error(error_code);

create table if not exists public.dryrun_sasaran (
  dryrun_sasaran_id bigserial primary key,
  created_at timestamptz not null default now(),
  promote_batch_id text not null references public.promote_batch(promote_batch_id) on delete cascade,
  import_batch_id text not null,
  staging_row_id bigint not null,
  record_id text,
  client_mutation_id text,
  source_mode text,
  app_version text,
  id_kecamatan text,
  kode_kecamatan text,
  nama_kecamatan text,
  id_tim text,
  nomor_tim text,
  nama_tim text,
  id_kader text,
  nama_kader text,
  id_wilayah text,
  desa_kelurahan text,
  dusun_rw text,
  jenis_sasaran text,
  nik text,
  no_kk text,
  nama_sasaran text,
  jenis_kelamin text,
  tanggal_lahir text,
  usia_bulan text,
  alamat_lengkap text,
  nama_ibu_kandung text,
  sasaran_unique_key text not null,
  unique_key_strategy text,
  needs_review boolean not null default false,
  review_reason text,
  raw_row_json jsonb,
  source_status text not null default 'dry_run_only',
  constraint uq_dryrun_sasaran_unique_key unique (sasaran_unique_key),
  constraint uq_dryrun_sasaran_client_mutation unique (client_mutation_id)
);

create index if not exists idx_dryrun_sasaran_import_batch_id
  on public.dryrun_sasaran(import_batch_id);

create index if not exists idx_dryrun_sasaran_id_tim
  on public.dryrun_sasaran(id_tim);

create table if not exists public.dryrun_pendampingan (
  dryrun_pendampingan_id bigserial primary key,
  created_at timestamptz not null default now(),
  promote_batch_id text not null references public.promote_batch(promote_batch_id) on delete cascade,
  import_batch_id text not null,
  staging_row_id bigint not null,
  record_id text,
  client_mutation_id text,
  source_mode text,
  app_version text,
  id_kecamatan text,
  kode_kecamatan text,
  nama_kecamatan text,
  id_tim text,
  nomor_tim text,
  nama_tim text,
  id_kader text,
  nama_kader text,
  id_wilayah text,
  desa_kelurahan text,
  dusun_rw text,
  id_sasaran text,
  id_sasaran_temp text,
  sasaran_unique_key text not null,
  jenis_sasaran text,
  nik text,
  nama_sasaran text,
  periode_bulan text,
  tahun_laporan text,
  periode_yyyymm text,
  tanggal_pendampingan text,
  status_pendampingan text,
  hasil_pendampingan text,
  catatan_pendampingan text,
  pendampingan_unique_key text not null,
  needs_review boolean not null default false,
  review_reason text,
  parent_sasaran_dryrun_id bigint references public.dryrun_sasaran(dryrun_sasaran_id),
  parent_resolution_status text not null default 'UNRESOLVED',
  raw_row_json jsonb,
  source_status text not null default 'dry_run_only',
  constraint uq_dryrun_pendampingan_unique_key unique (pendampingan_unique_key),
  constraint uq_dryrun_pendampingan_client_mutation unique (client_mutation_id)
);

create index if not exists idx_dryrun_pendampingan_import_batch_id
  on public.dryrun_pendampingan(import_batch_id);

create index if not exists idx_dryrun_pendampingan_sasaran_unique_key
  on public.dryrun_pendampingan(sasaran_unique_key);

create index if not exists idx_dryrun_pendampingan_periode
  on public.dryrun_pendampingan(tahun_laporan, periode_bulan);

alter table public.promote_batch enable row level security;
alter table public.promote_error enable row level security;
alter table public.dryrun_sasaran enable row level security;
alter table public.dryrun_pendampingan enable row level security;

revoke all on table public.promote_batch from anon, authenticated;
revoke all on table public.promote_error from anon, authenticated;
revoke all on table public.dryrun_sasaran from anon, authenticated;
revoke all on table public.dryrun_pendampingan from anon, authenticated;
