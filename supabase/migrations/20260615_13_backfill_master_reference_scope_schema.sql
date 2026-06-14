-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E — Production Master Reference & Scope Foundation
-- File 01: Master reference and scope schema
-- Version: p7e-20260615-r1
-- ============================================================

create extension if not exists pgcrypto;

-- ============================================================
-- Master reference: Kecamatan
-- ============================================================
create table if not exists public.master_kecamatan (
  id_kecamatan text primary key,
  kode_kecamatan text not null unique,
  nama_kecamatan text not null,
  kabupaten text not null default 'BULELENG',
  provinsi text not null default 'BALI',
  urutan integer,
  is_active boolean not null default true,
  source_mode text not null default 'BACKFILL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  catatan text
);

create index if not exists idx_master_kecamatan_active
  on public.master_kecamatan(is_active, kode_kecamatan);

-- ============================================================
-- Master reference: Tim
-- ============================================================
create table if not exists public.master_tim (
  id_tim text primary key,
  id_kecamatan text not null references public.master_kecamatan(id_kecamatan),
  kode_kecamatan text,
  nomor_tim text,
  nama_tim text not null,
  status_tim text not null default 'AKTIF',
  is_active boolean not null default true,
  source_mode text not null default 'BACKFILL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  catatan text
);

create index if not exists idx_master_tim_scope
  on public.master_tim(id_kecamatan, is_active, status_tim);

-- ============================================================
-- Master reference: Kader / user operational identity foundation
-- ============================================================
create table if not exists public.master_kader (
  id_kader text primary key,
  id_tim text references public.master_tim(id_tim),
  id_kecamatan text references public.master_kecamatan(id_kecamatan),
  nama_kader text not null,
  jenis_kelamin text,
  jabatan_dalam_tim text,
  unsur_tpk text,
  no_hp text,
  is_active boolean not null default true,
  source_mode text not null default 'BACKFILL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  catatan text
);

create index if not exists idx_master_kader_scope
  on public.master_kader(id_kecamatan, id_tim, is_active);

-- ============================================================
-- Master reference: Wilayah tugas
-- ============================================================
create table if not exists public.master_wilayah (
  id_wilayah text primary key,
  id_kecamatan text references public.master_kecamatan(id_kecamatan),
  kode_kecamatan text,
  nama_kecamatan text,
  desa_kelurahan text not null,
  dusun_rw text,
  nama_wilayah_lengkap text,
  is_active boolean not null default true,
  source_mode text not null default 'BACKFILL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  catatan text
);

create index if not exists idx_master_wilayah_scope
  on public.master_wilayah(id_kecamatan, desa_kelurahan, dusun_rw, is_active);

-- ============================================================
-- Scope foundation: profile table for future Auth/RLS mapping
-- ============================================================
create table if not exists public.scope_profile (
  scope_profile_id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  auth_user_id uuid unique,
  id_user text unique,
  username text,
  display_name text,
  role_akses text not null default 'KADER',
  scope_level text not null default 'TIM',
  scope_code text,
  id_kecamatan text references public.master_kecamatan(id_kecamatan),
  id_tim text references public.master_tim(id_tim),
  id_kader text references public.master_kader(id_kader),
  is_active boolean not null default true,
  source_mode text not null default 'BACKFILL',
  catatan text,
  constraint chk_scope_profile_role check (role_akses in ('SUPER_ADMIN','ADMIN_KABUPATEN','ADMIN_KECAMATAN','PKB','KADER','SYSTEM')),
  constraint chk_scope_profile_level check (scope_level in ('KABUPATEN','KECAMATAN','TIM','KADER','SYSTEM'))
);

create index if not exists idx_scope_profile_scope
  on public.scope_profile(role_akses, scope_level, id_kecamatan, id_tim, id_kader, is_active);

-- Keep master/scope foundation closed from anon/authenticated until auth+RLS package.
alter table public.master_kecamatan enable row level security;
alter table public.master_tim enable row level security;
alter table public.master_kader enable row level security;
alter table public.master_wilayah enable row level security;
alter table public.scope_profile enable row level security;

revoke all on table public.master_kecamatan from anon, authenticated;
revoke all on table public.master_tim from anon, authenticated;
revoke all on table public.master_kader from anon, authenticated;
revoke all on table public.master_wilayah from anon, authenticated;
revoke all on table public.scope_profile from anon, authenticated;
