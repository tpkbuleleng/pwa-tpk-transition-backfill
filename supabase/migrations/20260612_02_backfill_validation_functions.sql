-- Paket 7-A — Supabase Staging Validation Functions
-- Version: supabase-staging-p7a-20260612-r1

create or replace function public.validate_backfill_import_batch(p_import_batch_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_error_count integer := 0;
  v_sasaran_count integer := 0;
  v_pendampingan_count integer := 0;
begin
  if nullif(trim(coalesce(p_import_batch_id, '')), '') is null then
    raise exception 'import_batch_id wajib diisi';
  end if;

  delete from public.import_error
  where import_batch_id = p_import_batch_id
    and coalesce(error_code, '') like 'STAGING_%';

  -- Required field checks: sasaran.
  with required(field_name) as (
    select unnest(array['client_mutation_id', 'source_mode', 'app_version', 'id_kecamatan', 'nama_kecamatan', 'id_tim', 'id_kader', 'id_wilayah', 'desa_kelurahan', 'dusun_rw', 'jenis_sasaran', 'nama_sasaran', 'jenis_kelamin', 'tanggal_lahir', 'sasaran_unique_key', 'unique_key_strategy', 'needs_review'])
  )
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_sasaran_import',
    s.staging_row_id::text,
    s.client_mutation_id,
    'sasaran',
    s.sasaran_unique_key,
    'error',
    'STAGING_REQUIRED_FIELD_EMPTY',
    'Field wajib kosong: ' || r.field_name,
    r.field_name,
    coalesce(to_jsonb(s)->>r.field_name, ''),
    to_jsonb(s)::text,
    now()::text
  from public.staging_sasaran_import s
  cross join required r
  where s.import_batch_id = p_import_batch_id
    and nullif(trim(coalesce(to_jsonb(s)->>r.field_name, '')), '') is null;

  -- Required field checks: pendampingan.
  with required(field_name) as (
    select unnest(array['client_mutation_id', 'source_mode', 'app_version', 'id_kecamatan', 'nama_kecamatan', 'id_tim', 'id_kader', 'id_wilayah', 'desa_kelurahan', 'dusun_rw', 'sasaran_unique_key', 'jenis_sasaran', 'nama_sasaran', 'periode_bulan', 'tahun_laporan', 'periode_yyyymm', 'tanggal_pendampingan', 'pendampingan_unique_key', 'needs_review'])
  )
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_pendampingan_import',
    p.staging_row_id::text,
    p.client_mutation_id,
    'pendampingan',
    p.pendampingan_unique_key,
    'error',
    'STAGING_REQUIRED_FIELD_EMPTY',
    'Field wajib kosong: ' || r.field_name,
    r.field_name,
    coalesce(to_jsonb(p)->>r.field_name, ''),
    to_jsonb(p)::text,
    now()::text
  from public.staging_pendampingan_import p
  cross join required r
  where p.import_batch_id = p_import_batch_id
    and nullif(trim(coalesce(to_jsonb(p)->>r.field_name, '')), '') is null;

  -- NIK format check for sasaran when provided.
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_sasaran_import',
    s.staging_row_id::text,
    s.client_mutation_id,
    'sasaran',
    s.sasaran_unique_key,
    'error',
    'STAGING_INVALID_NIK',
    'NIK wajib 16 digit angka jika diisi.',
    'nik',
    s.nik,
    to_jsonb(s)::text,
    now()::text
  from public.staging_sasaran_import s
  where s.import_batch_id = p_import_batch_id
    and nullif(trim(coalesce(s.nik, '')), '') is not null
    and s.nik !~ '^\d{16}$';

  -- Duplicate sasaran unique key across staging.
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_sasaran_import',
    s.staging_row_id::text,
    s.client_mutation_id,
    'sasaran',
    s.sasaran_unique_key,
    'error',
    'STAGING_DUPLICATE_SASARAN_UNIQUE_KEY',
    'sasaran_unique_key duplikat di staging import.',
    'sasaran_unique_key',
    s.sasaran_unique_key,
    to_jsonb(s)::text,
    now()::text
  from public.staging_sasaran_import s
  where s.import_batch_id = p_import_batch_id
    and nullif(trim(coalesce(s.sasaran_unique_key, '')), '') is not null
    and exists (
      select 1 from public.staging_sasaran_import other
      where other.sasaran_unique_key = s.sasaran_unique_key
        and other.staging_row_id <> s.staging_row_id
    );

  -- Pendampingan period format and date-month alignment.
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_pendampingan_import',
    p.staging_row_id::text,
    p.client_mutation_id,
    'pendampingan',
    p.pendampingan_unique_key,
    'error',
    'STAGING_DATE_MONTH_MISMATCH',
    'tanggal_pendampingan tidak sesuai periode_bulan/tahun_laporan.',
    'tanggal_pendampingan',
    p.tanggal_pendampingan,
    to_jsonb(p)::text,
    now()::text
  from public.staging_pendampingan_import p
  where p.import_batch_id = p_import_batch_id
    and (
      p.tanggal_pendampingan !~ '^\d{4}-\d{2}-\d{2}$'
      or p.periode_bulan !~ '^\d+$'
      or p.tahun_laporan !~ '^\d{4}$'
      or extract(month from p.tanggal_pendampingan::date)::int <> p.periode_bulan::int
      or extract(year from p.tanggal_pendampingan::date)::int <> p.tahun_laporan::int
    );

  -- Duplicate pendampingan unique key across staging.
  insert into public.import_error(
    error_id, import_batch_id, source_sheet, source_row_number, client_mutation_id,
    record_type, unique_key, error_level, error_code, error_message,
    field_name, field_value, raw_row_json, detected_at
  )
  select
    'ERR_' || replace(gen_random_uuid()::text, '-', ''),
    p_import_batch_id,
    'staging_pendampingan_import',
    p.staging_row_id::text,
    p.client_mutation_id,
    'pendampingan',
    p.pendampingan_unique_key,
    'error',
    'STAGING_DUPLICATE_PENDAMPINGAN_UNIQUE_KEY',
    'pendampingan_unique_key duplikat di staging import.',
    'pendampingan_unique_key',
    p.pendampingan_unique_key,
    to_jsonb(p)::text,
    now()::text
  from public.staging_pendampingan_import p
  where p.import_batch_id = p_import_batch_id
    and nullif(trim(coalesce(p.pendampingan_unique_key, '')), '') is not null
    and exists (
      select 1 from public.staging_pendampingan_import other
      where other.pendampingan_unique_key = p.pendampingan_unique_key
        and other.staging_row_id <> p.staging_row_id
    );

  update public.staging_sasaran_import s
  set validation_status = case
      when exists (
        select 1 from public.import_error e
        where e.import_batch_id = p_import_batch_id
          and e.record_type = 'sasaran'
          and e.source_row_number = s.staging_row_id::text
      ) then 'invalid'
      else 'valid'
    end,
    validated_at = now()
  where s.import_batch_id = p_import_batch_id;

  update public.staging_pendampingan_import p
  set validation_status = case
      when exists (
        select 1 from public.import_error e
        where e.import_batch_id = p_import_batch_id
          and e.record_type = 'pendampingan'
          and e.source_row_number = p.staging_row_id::text
      ) then 'invalid'
      else 'valid'
    end,
    validated_at = now()
  where p.import_batch_id = p_import_batch_id;

  select count(*) into v_error_count from public.import_error where import_batch_id = p_import_batch_id;
  select count(*) into v_sasaran_count from public.staging_sasaran_import where import_batch_id = p_import_batch_id;
  select count(*) into v_pendampingan_count from public.staging_pendampingan_import where import_batch_id = p_import_batch_id;

  return jsonb_build_object(
    'ok', v_error_count = 0,
    'import_batch_id', p_import_batch_id,
    'sasaran_rows', v_sasaran_count,
    'pendampingan_rows', v_pendampingan_count,
    'error_rows', v_error_count,
    'status', case when v_error_count = 0 then 'valid' else 'invalid' end
  );
end;
$$;

comment on function public.validate_backfill_import_batch(text) is 'Paket 7-A: validates imported BACKFILL CSV rows and records issues in import_error. Does not promote to production.';
