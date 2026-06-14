-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-C — Production Base Tables & Controlled Promote
-- File 02: Controlled promote functions
-- Version: p7c-20260614-r1
-- ============================================================

create or replace function public.build_production_promote_batch_id()
returns text
language sql
volatile
as $$
  select 'PPMB_' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS') || '_' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

create or replace function public.safe_text_to_date(p_value text)
returns date
language sql
immutable
as $$
  select case
    when nullif(trim(coalesce(p_value, '')), '') is null then null
    when trim(p_value) ~ '^\d{4}-\d{2}-\d{2}$' then trim(p_value)::date
    else null
  end;
$$;

create or replace function public.safe_text_to_int(p_value text)
returns integer
language sql
immutable
as $$
  select case
    when nullif(trim(coalesce(p_value, '')), '') is null then null
    when trim(p_value) ~ '^\d+$' then trim(p_value)::integer
    else null
  end;
$$;

create or replace function public.promote_backfill_dryrun_to_production(
  p_import_batch_id text,
  p_record_type text default null,
  p_reset_same_batch boolean default false
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_production_promote_batch_id text;
  v_record_type text;
  v_sasaran_rows integer := 0;
  v_pendampingan_rows integer := 0;
  v_error_rows integer := 0;
  v_inserted_sasaran integer := 0;
  v_inserted_pendampingan integer := 0;
begin
  if nullif(trim(coalesce(p_import_batch_id, '')), '') is null then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'error_code', 'IMPORT_BATCH_ID_REQUIRED',
      'message', 'import_batch_id wajib diisi.'
    );
  end if;

  if p_record_type is not null and lower(trim(p_record_type)) not in ('sasaran', 'pendampingan', 'mixed') then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'error_code', 'INVALID_RECORD_TYPE',
      'message', 'record_type tidak valid. Gunakan sasaran, pendampingan, atau mixed.'
    );
  end if;

  select count(*) into v_sasaran_rows
  from public.dryrun_sasaran
  where import_batch_id = p_import_batch_id;

  select count(*) into v_pendampingan_rows
  from public.dryrun_pendampingan
  where import_batch_id = p_import_batch_id;

  if v_sasaran_rows = 0 and v_pendampingan_rows = 0 then
    return jsonb_build_object(
      'ok', false,
      'status', 'not_found',
      'error_code', 'DRYRUN_BATCH_NOT_FOUND',
      'message', 'Tidak ada dry-run row untuk import_batch_id ini.',
      'import_batch_id', p_import_batch_id
    );
  end if;

  v_record_type := coalesce(
    lower(nullif(trim(coalesce(p_record_type, '')), '')),
    case
      when v_sasaran_rows > 0 and v_pendampingan_rows > 0 then 'mixed'
      when v_sasaran_rows > 0 then 'sasaran'
      else 'pendampingan'
    end
  );

  if p_reset_same_batch then
    delete from public.pendampingan p
    where p.source_import_batch_id = p_import_batch_id
       or p.sasaran_id in (
         select s.sasaran_id from public.sasaran s
         where s.source_import_batch_id = p_import_batch_id
       );
    delete from public.sasaran where source_import_batch_id = p_import_batch_id;
    delete from public.production_promote_batch where import_batch_id = p_import_batch_id;
  end if;

  v_production_promote_batch_id := public.build_production_promote_batch_id();

  insert into public.production_promote_batch(
    production_promote_batch_id, import_batch_id, record_type, status,
    sasaran_rows, pendampingan_rows, error_rows, promoted_by, notes
  ) values (
    v_production_promote_batch_id, p_import_batch_id, v_record_type, 'checking',
    v_sasaran_rows, v_pendampingan_rows, 0, 'SQL_EDITOR',
    'Controlled promote ke production base mulai.'
  );

  -- ==========================================================
  -- SASARAN CHECKS
  -- ==========================================================
  if v_record_type in ('sasaran', 'mixed') then
    insert into public.production_promote_error(
      production_promote_batch_id, import_batch_id, record_type, dryrun_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_production_promote_batch_id,
      p_import_batch_id,
      'sasaran',
      d.dryrun_sasaran_id,
      d.client_mutation_id,
      d.sasaran_unique_key,
      'PRODUCTION_DUPLICATE_SASARAN_UNIQUE_KEY',
      'sasaran_unique_key sudah ada di tabel production sasaran.',
      'sasaran_unique_key',
      d.sasaran_unique_key,
      to_jsonb(d)
    from public.dryrun_sasaran d
    where d.import_batch_id = p_import_batch_id
      and exists (
        select 1 from public.sasaran s
        where s.sasaran_unique_key = d.sasaran_unique_key
      );

    insert into public.production_promote_error(
      production_promote_batch_id, import_batch_id, record_type, dryrun_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_production_promote_batch_id,
      p_import_batch_id,
      'sasaran',
      d.dryrun_sasaran_id,
      d.client_mutation_id,
      d.sasaran_unique_key,
      'PRODUCTION_DUPLICATE_SASARAN_CLIENT_MUTATION_ID',
      'client_mutation_id sasaran sudah ada di tabel production sasaran.',
      'client_mutation_id',
      d.client_mutation_id,
      to_jsonb(d)
    from public.dryrun_sasaran d
    where d.import_batch_id = p_import_batch_id
      and nullif(trim(coalesce(d.client_mutation_id, '')), '') is not null
      and exists (
        select 1 from public.sasaran s
        where s.client_mutation_id = d.client_mutation_id
      );
  end if;

  -- ==========================================================
  -- PENDAMPINGAN CHECKS
  -- ==========================================================
  if v_record_type in ('pendampingan', 'mixed') then
    insert into public.production_promote_error(
      production_promote_batch_id, import_batch_id, record_type, dryrun_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_production_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      d.dryrun_pendampingan_id,
      d.client_mutation_id,
      d.pendampingan_unique_key,
      'PRODUCTION_PARENT_SASARAN_NOT_FOUND',
      'sasaran_unique_key pendampingan belum ditemukan pada tabel production sasaran.',
      'sasaran_unique_key',
      d.sasaran_unique_key,
      to_jsonb(d)
    from public.dryrun_pendampingan d
    where d.import_batch_id = p_import_batch_id
      and not exists (
        select 1 from public.sasaran s
        where s.sasaran_unique_key = d.sasaran_unique_key
      );

    insert into public.production_promote_error(
      production_promote_batch_id, import_batch_id, record_type, dryrun_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_production_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      d.dryrun_pendampingan_id,
      d.client_mutation_id,
      d.pendampingan_unique_key,
      'PRODUCTION_DUPLICATE_PENDAMPINGAN_UNIQUE_KEY',
      'pendampingan_unique_key sudah ada di tabel production pendampingan.',
      'pendampingan_unique_key',
      d.pendampingan_unique_key,
      to_jsonb(d)
    from public.dryrun_pendampingan d
    where d.import_batch_id = p_import_batch_id
      and exists (
        select 1 from public.pendampingan p
        where p.pendampingan_unique_key = d.pendampingan_unique_key
      );

    insert into public.production_promote_error(
      production_promote_batch_id, import_batch_id, record_type, dryrun_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_production_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      d.dryrun_pendampingan_id,
      d.client_mutation_id,
      d.pendampingan_unique_key,
      'PRODUCTION_DUPLICATE_PENDAMPINGAN_CLIENT_MUTATION_ID',
      'client_mutation_id pendampingan sudah ada di tabel production pendampingan.',
      'client_mutation_id',
      d.client_mutation_id,
      to_jsonb(d)
    from public.dryrun_pendampingan d
    where d.import_batch_id = p_import_batch_id
      and nullif(trim(coalesce(d.client_mutation_id, '')), '') is not null
      and exists (
        select 1 from public.pendampingan p
        where p.client_mutation_id = d.client_mutation_id
      );
  end if;

  select count(*) into v_error_rows
  from public.production_promote_error
  where production_promote_batch_id = v_production_promote_batch_id;

  if v_error_rows > 0 then
    update public.production_promote_batch
    set status = 'invalid',
      error_rows = v_error_rows,
      promoted_at = now(),
      notes = 'Controlled promote dibatalkan karena production_promote_error ditemukan.'
    where production_promote_batch_id = v_production_promote_batch_id;

    return jsonb_build_object(
      'ok', false,
      'status', 'invalid',
      'production_promote_batch_id', v_production_promote_batch_id,
      'import_batch_id', p_import_batch_id,
      'record_type', v_record_type,
      'sasaran_rows', v_sasaran_rows,
      'pendampingan_rows', v_pendampingan_rows,
      'error_rows', v_error_rows
    );
  end if;

  -- ==========================================================
  -- INSERT SASARAN PRODUCTION BASE
  -- ==========================================================
  if v_record_type in ('sasaran', 'mixed') then
    insert into public.sasaran(
      source_mode, source_import_batch_id, source_promote_batch_id, source_dryrun_sasaran_id,
      source_record_id, client_mutation_id, app_version,
      id_kecamatan, kode_kecamatan, nama_kecamatan, id_tim, nomor_tim, nama_tim,
      id_kader, nama_kader, id_wilayah, desa_kelurahan, dusun_rw,
      jenis_sasaran, nik, no_kk, nama_sasaran, jenis_kelamin, tanggal_lahir,
      usia_bulan, alamat_lengkap, nama_ibu_kandung, sasaran_unique_key,
      unique_key_strategy, needs_review, review_reason, raw_row_json
    )
    select
      coalesce(d.source_mode, 'BACKFILL'), d.import_batch_id, v_production_promote_batch_id, d.dryrun_sasaran_id,
      d.record_id, d.client_mutation_id, d.app_version,
      d.id_kecamatan, d.kode_kecamatan, d.nama_kecamatan, d.id_tim, d.nomor_tim, d.nama_tim,
      d.id_kader, d.nama_kader, d.id_wilayah, d.desa_kelurahan, d.dusun_rw,
      d.jenis_sasaran, d.nik, d.no_kk, d.nama_sasaran, d.jenis_kelamin, public.safe_text_to_date(d.tanggal_lahir),
      public.safe_text_to_int(d.usia_bulan), d.alamat_lengkap, d.nama_ibu_kandung, d.sasaran_unique_key,
      d.unique_key_strategy, d.needs_review, d.review_reason, d.raw_row_json
    from public.dryrun_sasaran d
    where d.import_batch_id = p_import_batch_id;

    get diagnostics v_inserted_sasaran = row_count;

    update public.dryrun_sasaran
    set source_status = 'promoted_to_production_base'
    where import_batch_id = p_import_batch_id;

    update public.staging_sasaran_import
    set promoted_at = now()
    where import_batch_id = p_import_batch_id
      and coalesce(validation_status, '') = 'valid';
  end if;

  -- ==========================================================
  -- INSERT PENDAMPINGAN PRODUCTION BASE
  -- ==========================================================
  if v_record_type in ('pendampingan', 'mixed') then
    insert into public.pendampingan(
      source_mode, source_import_batch_id, source_promote_batch_id, source_dryrun_pendampingan_id,
      source_record_id, client_mutation_id, app_version, sasaran_id, sasaran_unique_key,
      id_kecamatan, kode_kecamatan, nama_kecamatan, id_tim, nomor_tim, nama_tim,
      id_kader, nama_kader, id_wilayah, desa_kelurahan, dusun_rw, id_sasaran_temp,
      jenis_sasaran, nik, nama_sasaran, periode_bulan, tahun_laporan, periode_yyyymm,
      tanggal_pendampingan, status_pendampingan, metode_pendampingan, hasil_pendampingan,
      catatan_pendampingan, pendampingan_unique_key, needs_review, review_reason, raw_row_json
    )
    select
      coalesce(d.source_mode, 'BACKFILL'), d.import_batch_id, v_production_promote_batch_id, d.dryrun_pendampingan_id,
      d.record_id, d.client_mutation_id, d.app_version, s.sasaran_id, d.sasaran_unique_key,
      d.id_kecamatan, d.kode_kecamatan, d.nama_kecamatan, d.id_tim, d.nomor_tim, d.nama_tim,
      d.id_kader, d.nama_kader, d.id_wilayah, d.desa_kelurahan, d.dusun_rw, d.id_sasaran_temp,
      d.jenis_sasaran, d.nik, d.nama_sasaran, public.safe_text_to_int(d.periode_bulan), public.safe_text_to_int(d.tahun_laporan), d.periode_yyyymm,
      public.safe_text_to_date(d.tanggal_pendampingan), d.status_pendampingan, d.status_pendampingan, d.hasil_pendampingan,
      d.catatan_pendampingan, d.pendampingan_unique_key, d.needs_review, d.review_reason, d.raw_row_json
    from public.dryrun_pendampingan d
    join public.sasaran s on s.sasaran_unique_key = d.sasaran_unique_key
    where d.import_batch_id = p_import_batch_id;

    get diagnostics v_inserted_pendampingan = row_count;

    update public.dryrun_pendampingan
    set source_status = 'promoted_to_production_base',
      parent_resolution_status = 'RESOLVED_TO_PRODUCTION_BASE'
    where import_batch_id = p_import_batch_id;

    update public.staging_pendampingan_import
    set promoted_at = now()
    where import_batch_id = p_import_batch_id
      and coalesce(validation_status, '') = 'valid';
  end if;

  update public.production_promote_batch
  set status = 'production_base_promoted',
    sasaran_rows = v_inserted_sasaran,
    pendampingan_rows = v_inserted_pendampingan,
    error_rows = 0,
    promoted_at = now(),
    notes = 'Controlled promote ke production base berhasil.'
  where production_promote_batch_id = v_production_promote_batch_id;

  return jsonb_build_object(
    'ok', true,
    'status', 'production_base_promoted',
    'production_promote_batch_id', v_production_promote_batch_id,
    'import_batch_id', p_import_batch_id,
    'record_type', v_record_type,
    'sasaran_rows', v_inserted_sasaran,
    'pendampingan_rows', v_inserted_pendampingan,
    'error_rows', 0
  );
end;
$$;

create or replace function public.purge_backfill_production_promote(
  p_production_promote_batch_id text default null,
  p_import_batch_id text default null,
  p_include_production_rows boolean default false
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_deleted_errors integer := 0;
  v_deleted_batches integer := 0;
  v_deleted_pendampingan integer := 0;
  v_deleted_sasaran integer := 0;
begin
  if nullif(trim(coalesce(p_production_promote_batch_id, '')), '') is null
     and nullif(trim(coalesce(p_import_batch_id, '')), '') is null then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'error_code', 'PURGE_FILTER_REQUIRED',
      'message', 'Isi production_promote_batch_id atau import_batch_id.'
    );
  end if;

  if p_include_production_rows then
    delete from public.pendampingan p
    where (p_production_promote_batch_id is not null and p.source_promote_batch_id = p_production_promote_batch_id)
       or (p_import_batch_id is not null and p.source_import_batch_id = p_import_batch_id)
       or p.sasaran_id in (
         select s.sasaran_id
         from public.sasaran s
         where (p_production_promote_batch_id is not null and s.source_promote_batch_id = p_production_promote_batch_id)
            or (p_import_batch_id is not null and s.source_import_batch_id = p_import_batch_id)
       );
    get diagnostics v_deleted_pendampingan = row_count;

    delete from public.sasaran s
    where (p_production_promote_batch_id is not null and s.source_promote_batch_id = p_production_promote_batch_id)
       or (p_import_batch_id is not null and s.source_import_batch_id = p_import_batch_id);
    get diagnostics v_deleted_sasaran = row_count;
  end if;

  delete from public.production_promote_error e
  where (p_production_promote_batch_id is not null and e.production_promote_batch_id = p_production_promote_batch_id)
     or (p_import_batch_id is not null and e.import_batch_id = p_import_batch_id);
  get diagnostics v_deleted_errors = row_count;

  delete from public.production_promote_batch b
  where (p_production_promote_batch_id is not null and b.production_promote_batch_id = p_production_promote_batch_id)
     or (p_import_batch_id is not null and b.import_batch_id = p_import_batch_id);
  get diagnostics v_deleted_batches = row_count;

  return jsonb_build_object(
    'ok', true,
    'status', 'purged',
    'deleted_production_promote_error', v_deleted_errors,
    'deleted_production_promote_batch', v_deleted_batches,
    'deleted_pendampingan', v_deleted_pendampingan,
    'deleted_sasaran', v_deleted_sasaran,
    'include_production_rows', p_include_production_rows
  );
end;
$$;

revoke execute on function public.build_production_promote_batch_id() from public, anon, authenticated;
revoke execute on function public.safe_text_to_date(text) from public, anon, authenticated;
revoke execute on function public.safe_text_to_int(text) from public, anon, authenticated;
revoke execute on function public.promote_backfill_dryrun_to_production(text, text, boolean) from public, anon, authenticated;
revoke execute on function public.purge_backfill_production_promote(text, text, boolean) from public, anon, authenticated;

grant execute on function public.build_production_promote_batch_id() to postgres, service_role;
grant execute on function public.safe_text_to_date(text) to postgres, service_role;
grant execute on function public.safe_text_to_int(text) to postgres, service_role;
grant execute on function public.promote_backfill_dryrun_to_production(text, text, boolean) to postgres, service_role;
grant execute on function public.purge_backfill_production_promote(text, text, boolean) to postgres, service_role;
