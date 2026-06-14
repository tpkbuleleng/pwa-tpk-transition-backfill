-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-C — Production Base Tables & Controlled Promote
-- File 01: Production base schema
-- Version: p7c-20260614-r1
-- ============================================================

create extension if not exists pgcrypto;

-- ============================================================
-- Production promote registry
-- ============================================================
create table if not exists public.production_promote_batch (
  production_promote_batch_id text primary key,
  created_at timestamptz not null default now(),
  import_batch_id text not null,
  record_type text not null,
  status text not null default 'pending',
  sasaran_rows integer not null default 0,
  pendampingan_rows integer not null default 0,
  error_rows integer not null default 0,
  promoted_at timestamptz,
  promoted_by text,
  notes text
);

create index if not exists idx_production_promote_batch_import_batch_id
  on public.production_promote_batch(import_batch_id);

create index if not exists idx_production_promote_batch_status
  on public.production_promote_batch(status);

create table if not exists public.production_promote_error (
  production_promote_error_id bigserial primary key,
  created_at timestamptz not null default now(),
  production_promote_batch_id text not null references public.production_promote_batch(production_promote_batch_id) on delete cascade,
  import_batch_id text not null,
  record_type text not null,
  dryrun_row_id bigint,
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

create index if not exists idx_production_promote_error_batch_id
  on public.production_promote_error(production_promote_batch_id);

create index if not exists idx_production_promote_error_import_batch_id
  on public.production_promote_error(import_batch_id);

create index if not exists idx_production_promote_error_code
  on public.production_promote_error(error_code);

-- ============================================================
-- Production base: sasaran
-- ============================================================
create table if not exists public.sasaran (
  sasaran_id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  source_mode text not null default 'BACKFILL',
  source_import_batch_id text,
  source_promote_batch_id text,
  source_dryrun_sasaran_id bigint,
  source_record_id text,
  client_mutation_id text,
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
  nama_sasaran text not null,
  jenis_kelamin text,
  tanggal_lahir date,
  usia_bulan integer,
  alamat_lengkap text,
  nama_ibu_kandung text,
  sasaran_unique_key text not null,
  unique_key_strategy text,
  needs_review boolean not null default false,
  review_reason text,
  status_sasaran text not null default 'AKTIF',
  is_deleted boolean not null default false,
  raw_row_json jsonb,
  constraint uq_production_sasaran_unique_key unique (sasaran_unique_key),
  constraint uq_production_sasaran_client_mutation unique (client_mutation_id)
);

create index if not exists idx_sasaran_id_tim
  on public.sasaran(id_tim);

create index if not exists idx_sasaran_id_kecamatan
  on public.sasaran(id_kecamatan);

create index if not exists idx_sasaran_jenis_sasaran
  on public.sasaran(jenis_sasaran);

create index if not exists idx_sasaran_status
  on public.sasaran(status_sasaran);

-- ============================================================
-- Production base: pendampingan
-- ============================================================
create table if not exists public.pendampingan (
  pendampingan_id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  source_mode text not null default 'BACKFILL',
  source_import_batch_id text,
  source_promote_batch_id text,
  source_dryrun_pendampingan_id bigint,
  source_record_id text,
  client_mutation_id text,
  app_version text,
  sasaran_id uuid not null references public.sasaran(sasaran_id),
  sasaran_unique_key text not null,
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
  id_sasaran_temp text,
  jenis_sasaran text,
  nik text,
  nama_sasaran text,
  periode_bulan integer not null,
  tahun_laporan integer not null,
  periode_yyyymm text not null,
  tanggal_pendampingan date not null,
  status_pendampingan text,
  metode_pendampingan text,
  hasil_pendampingan text,
  catatan_pendampingan text,
  pendampingan_unique_key text not null,
  needs_review boolean not null default false,
  review_reason text,
  is_deleted boolean not null default false,
  raw_row_json jsonb,
  constraint uq_production_pendampingan_unique_key unique (pendampingan_unique_key),
  constraint uq_production_pendampingan_client_mutation unique (client_mutation_id)
);

create index if not exists idx_pendampingan_sasaran_id
  on public.pendampingan(sasaran_id);

create index if not exists idx_pendampingan_sasaran_unique_key
  on public.pendampingan(sasaran_unique_key);

create index if not exists idx_pendampingan_periode
  on public.pendampingan(tahun_laporan, periode_bulan);

create index if not exists idx_pendampingan_id_tim
  on public.pendampingan(id_tim);

-- Keep all production base and control tables closed to anon/authenticated for now.
alter table public.production_promote_batch enable row level security;
alter table public.production_promote_error enable row level security;
alter table public.sasaran enable row level security;
alter table public.pendampingan enable row level security;

revoke all on table public.production_promote_batch from anon, authenticated;
revoke all on table public.production_promote_error from anon, authenticated;
revoke all on table public.sasaran from anon, authenticated;
revoke all on table public.pendampingan from anon, authenticated;
