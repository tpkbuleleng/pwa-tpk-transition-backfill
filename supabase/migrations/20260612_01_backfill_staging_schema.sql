-- Paket 7-A — Supabase Staging Schema & Import Contract
-- Version: supabase-staging-p7a-20260612-r1
-- Purpose: create staging tables for CSV exported from BACKFILL Google Sheet.

begin;

create table if not exists public.import_batch (
  batch_row_id bigserial primary key,
  created_at timestamptz not null default now(),
  import_batch_id text,
  source_mode text,
  kode_kecamatan text,
  nama_kecamatan text,
  record_type text,
  periode_bulan text,
  tahun_laporan text,
  file_name text,
  csv_header_version text,
  total_rows text,
  valid_rows text,
  error_rows text,
  imported_by text,
  imported_at text,
  status text,
  notes text
);

create table if not exists public.import_error (
  error_row_id bigserial primary key,
  created_at timestamptz not null default now(),
  error_id text,
  import_batch_id text,
  source_sheet text,
  source_row_number text,
  client_mutation_id text,
  record_type text,
  unique_key text,
  error_level text,
  error_code text,
  error_message text,
  field_name text,
  field_value text,
  raw_row_json text,
  detected_at text,
  resolved_at text,
  resolved_by text,
  resolution_note text
);

create table if not exists public.staging_sasaran_import (
  staging_row_id bigserial primary key,
  loaded_at timestamptz not null default now(),
  validation_status text not null default 'pending',
  validated_at timestamptz,
  promoted_at timestamptz,
  record_id text,
  client_mutation_id text,
  source_mode text,
  app_version text,
  import_batch_id text,
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
  nama_kepala_keluarga text,
  nama_ibu_kandung text,
  status_krs text,
  sumber_air_minum_utama text,
  fasilitas_bab text,
  nik_pasangan text,
  nama_pasangan text,
  kabupaten_pasangan text,
  kecamatan_pasangan text,
  desa_pasangan text,
  dusun_pasangan text,
  domisili_setelah_menikah text,
  usia_kehamilan_minggu text,
  bb_sebelum_hamil_kg text,
  kehamilan_diinginkan text,
  tanggal_melahirkan text,
  jenis_persalinan text,
  bb_lahir_kg text,
  pb_lahir_cm text,
  form_id text,
  form_version text,
  sasaran_unique_key text,
  unique_key_strategy text,
  needs_review text,
  review_reason text,
  form_answers_json text,
  raw_payload_json text,
  created_at_client text,
  submitted_at_server text,
  created_by text,
  updated_at text,
  is_deleted text,
  catatan text
);

create table if not exists public.staging_pendampingan_import (
  staging_row_id bigserial primary key,
  loaded_at timestamptz not null default now(),
  validation_status text not null default 'pending',
  validated_at timestamptz,
  promoted_at timestamptz,
  record_id text,
  client_mutation_id text,
  source_mode text,
  app_version text,
  import_batch_id text,
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
  sasaran_unique_key text,
  jenis_sasaran text,
  nik text,
  nama_sasaran text,
  periode_bulan text,
  tahun_laporan text,
  periode_yyyymm text,
  tanggal_pendampingan text,
  metode_pendampingan text,
  status_pendampingan text,
  hasil_pendampingan text,
  catatan_pendampingan text,
  rujukan_diperlukan text,
  jenis_rujukan text,
  form_id text,
  form_version text,
  pendampingan_unique_key text,
  form_answers_json text,
  raw_payload_json text,
  needs_review text,
  review_reason text,
  created_at_client text,
  submitted_at_server text,
  created_by text,
  updated_at text,
  is_deleted text,
  catatan text
);

create index if not exists idx_import_batch_import_batch_id on public.import_batch(import_batch_id);
create index if not exists idx_import_batch_record_type on public.import_batch(record_type);
create index if not exists idx_import_error_import_batch_id on public.import_error(import_batch_id);
create index if not exists idx_import_error_record_type on public.import_error(record_type);
create index if not exists idx_staging_sasaran_import_batch_id on public.staging_sasaran_import(import_batch_id);
create index if not exists idx_staging_sasaran_unique_key on public.staging_sasaran_import(sasaran_unique_key);
create index if not exists idx_staging_sasaran_client_mutation_id on public.staging_sasaran_import(client_mutation_id);
create index if not exists idx_staging_pendampingan_import_batch_id on public.staging_pendampingan_import(import_batch_id);
create index if not exists idx_staging_pendampingan_unique_key on public.staging_pendampingan_import(pendampingan_unique_key);
create index if not exists idx_staging_pendampingan_client_mutation_id on public.staging_pendampingan_import(client_mutation_id);

alter table public.import_batch enable row level security;
alter table public.import_error enable row level security;
alter table public.staging_sasaran_import enable row level security;
alter table public.staging_pendampingan_import enable row level security;

comment on table public.staging_sasaran_import is 'Paket 7-A: CSV staging for BACKFILL sasaran import. All CSV columns are text; validation runs after import.';
comment on table public.staging_pendampingan_import is 'Paket 7-A: CSV staging for BACKFILL pendampingan import. All CSV columns are text; validation runs after import.';
comment on table public.import_batch is 'Paket 7-A: CSV import batch registry from Google Sheet BACKFILL export.';
comment on table public.import_error is 'Paket 7-A: validation errors detected before promoting staging data to production.';

commit;
