-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-B — Supabase Import Validation & Promote Dry Run
-- File 02: Dry-run promote functions
-- Version: p7b-20260612-r1
-- ============================================================

create or replace function public.normalize_backfill_bool(p_value text)
returns boolean
language sql
immutable
as $$
  select lower(coalesce(trim(p_value), '')) in ('true', 't', '1', 'yes', 'ya', 'y');
$$;

create or replace function public.build_promote_batch_id()
returns text
language sql
volatile
as $$
  select 'PRMB_' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS') || '_' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

create or replace function public.promote_backfill_batch_dry_run(
  p_import_batch_id text,
  p_record_type text default null,
  p_reset_existing boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_promote_batch_id text;
  v_import_error_rows integer := 0;
  v_sasaran_rows integer := 0;
  v_pendampingan_rows integer := 0;
  v_record_type text;
  v_existing_errors integer := 0;
  v_inserted_sasaran integer := 0;
  v_inserted_pendampingan integer := 0;
begin
  if nullif(trim(coalesce(p_import_batch_id, '')), '') is null then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'message', 'import_batch_id wajib diisi.',
      'error_code', 'IMPORT_BATCH_ID_REQUIRED'
    );
  end if;

  select count(*) into v_import_error_rows
  from public.import_error
  where import_batch_id = p_import_batch_id;

  select count(*) into v_sasaran_rows
  from public.staging_sasaran_import
  where import_batch_id = p_import_batch_id;

  select count(*) into v_pendampingan_rows
  from public.staging_pendampingan_import
  where import_batch_id = p_import_batch_id;

  if v_sasaran_rows = 0 and v_pendampingan_rows = 0 then
    return jsonb_build_object(
      'ok', false,
      'status', 'not_found',
      'message', 'Tidak ada staging row untuk import_batch_id ini.',
      'import_batch_id', p_import_batch_id,
      'error_code', 'IMPORT_BATCH_NOT_FOUND'
    );
  end if;

  if p_record_type is not null and lower(trim(p_record_type)) not in ('sasaran', 'pendampingan', 'mixed') then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'message', 'record_type tidak valid. Gunakan sasaran, pendampingan, atau mixed.',
      'error_code', 'INVALID_RECORD_TYPE'
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

  if v_import_error_rows > 0 then
    v_promote_batch_id := public.build_promote_batch_id();
    insert into public.promote_batch(
      promote_batch_id, import_batch_id, record_type, dry_run, status,
      sasaran_rows, pendampingan_rows, error_rows, promoted_by, notes
    ) values (
      v_promote_batch_id, p_import_batch_id, v_record_type, true, 'blocked_by_import_error',
      v_sasaran_rows, v_pendampingan_rows, v_import_error_rows, 'SQL_EDITOR',
      'Promote dry run diblokir karena import_error masih ada.'
    );

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id, client_mutation_id,
      unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      record_type,
      nullif(source_row_number, '')::bigint,
      client_mutation_id,
      unique_key,
      'IMPORT_BATCH_HAS_ERROR',
      'Batch import masih memiliki import_error. Jalankan validasi dan perbaiki data sebelum promote dry run.',
      field_name,
      field_value,
      raw_row_json::jsonb
    from public.import_error
    where import_batch_id = p_import_batch_id;

    return jsonb_build_object(
      'ok', false,
      'status', 'blocked_by_import_error',
      'promote_batch_id', v_promote_batch_id,
      'import_batch_id', p_import_batch_id,
      'record_type', v_record_type,
      'import_error_rows', v_import_error_rows
    );
  end if;

  if p_reset_existing then
    delete from public.dryrun_pendampingan where import_batch_id = p_import_batch_id;
    delete from public.dryrun_sasaran where import_batch_id = p_import_batch_id;
    delete from public.promote_batch where import_batch_id = p_import_batch_id and dry_run is true;
  end if;

  v_promote_batch_id := public.build_promote_batch_id();

  insert into public.promote_batch(
    promote_batch_id, import_batch_id, record_type, dry_run, status,
    sasaran_rows, pendampingan_rows, error_rows, promoted_by, notes
  ) values (
    v_promote_batch_id, p_import_batch_id, v_record_type, true, 'checking',
    v_sasaran_rows, v_pendampingan_rows, 0, 'SQL_EDITOR',
    'Promote dry run mulai.'
  );

  -- ==========================================================
  -- SASARAN CHECKS
  -- ==========================================================
  if v_record_type in ('sasaran', 'mixed') then
    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'sasaran',
      s.staging_row_id,
      s.client_mutation_id,
      s.sasaran_unique_key,
      'STAGING_ROW_NOT_VALID',
      'Row sasaran belum berstatus valid di staging.',
      'validation_status',
      s.validation_status,
      to_jsonb(s)
    from public.staging_sasaran_import s
    where s.import_batch_id = p_import_batch_id
      and coalesce(s.validation_status, '') <> 'valid';

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'sasaran',
      min(s.staging_row_id),
      min(s.client_mutation_id),
      s.sasaran_unique_key,
      'DRYRUN_DUPLICATE_SASARAN_IN_BATCH',
      'sasaran_unique_key duplikat dalam batch staging yang sama.',
      'sasaran_unique_key',
      s.sasaran_unique_key,
      jsonb_build_object('duplicate_count', count(*))
    from public.staging_sasaran_import s
    where s.import_batch_id = p_import_batch_id
      and coalesce(s.validation_status, '') = 'valid'
    group by s.sasaran_unique_key
    having count(*) > 1;

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'sasaran',
      s.staging_row_id,
      s.client_mutation_id,
      s.sasaran_unique_key,
      'DRYRUN_SASARAN_ALREADY_EXISTS',
      'sasaran_unique_key sudah ada di dryrun_sasaran dari batch lain.',
      'sasaran_unique_key',
      s.sasaran_unique_key,
      to_jsonb(s)
    from public.staging_sasaran_import s
    where s.import_batch_id = p_import_batch_id
      and coalesce(s.validation_status, '') = 'valid'
      and exists (
        select 1 from public.dryrun_sasaran d
        where d.sasaran_unique_key = s.sasaran_unique_key
          and d.import_batch_id <> p_import_batch_id
      );
  end if;

  -- ==========================================================
  -- PENDAMPINGAN CHECKS
  -- ==========================================================
  if v_record_type in ('pendampingan', 'mixed') then
    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      p.staging_row_id,
      p.client_mutation_id,
      p.pendampingan_unique_key,
      'STAGING_ROW_NOT_VALID',
      'Row pendampingan belum berstatus valid di staging.',
      'validation_status',
      p.validation_status,
      to_jsonb(p)
    from public.staging_pendampingan_import p
    where p.import_batch_id = p_import_batch_id
      and coalesce(p.validation_status, '') <> 'valid';

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      min(p.staging_row_id),
      min(p.client_mutation_id),
      p.pendampingan_unique_key,
      'DRYRUN_DUPLICATE_PENDAMPINGAN_IN_BATCH',
      'pendampingan_unique_key duplikat dalam batch staging yang sama.',
      'pendampingan_unique_key',
      p.pendampingan_unique_key,
      jsonb_build_object('duplicate_count', count(*))
    from public.staging_pendampingan_import p
    where p.import_batch_id = p_import_batch_id
      and coalesce(p.validation_status, '') = 'valid'
    group by p.pendampingan_unique_key
    having count(*) > 1;

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      p.staging_row_id,
      p.client_mutation_id,
      p.pendampingan_unique_key,
      'DRYRUN_PENDAMPINGAN_ALREADY_EXISTS',
      'pendampingan_unique_key sudah ada di dryrun_pendampingan dari batch lain.',
      'pendampingan_unique_key',
      p.pendampingan_unique_key,
      to_jsonb(p)
    from public.staging_pendampingan_import p
    where p.import_batch_id = p_import_batch_id
      and coalesce(p.validation_status, '') = 'valid'
      and exists (
        select 1 from public.dryrun_pendampingan d
        where d.pendampingan_unique_key = p.pendampingan_unique_key
          and d.import_batch_id <> p_import_batch_id
      );

    insert into public.promote_error(
      promote_batch_id, import_batch_id, record_type, staging_row_id,
      client_mutation_id, unique_key, error_code, error_message, field_name, field_value, raw_row_json
    )
    select
      v_promote_batch_id,
      p_import_batch_id,
      'pendampingan',
      p.staging_row_id,
      p.client_mutation_id,
      p.pendampingan_unique_key,
      'DRYRUN_PARENT_SASARAN_NOT_FOUND',
      'sasaran_unique_key pendampingan belum ditemukan pada dryrun_sasaran atau staging_sasaran_import valid.',
      'sasaran_unique_key',
      p.sasaran_unique_key,
      to_jsonb(p)
    from public.staging_pendampingan_import p
    where p.import_batch_id = p_import_batch_id
      and coalesce(p.validation_status, '') = 'valid'
      and not exists (
        select 1 from public.dryrun_sasaran ds
        where ds.sasaran_unique_key = p.sasaran_unique_key
      )
      and not exists (
        select 1 from public.staging_sasaran_import ss
        where ss.sasaran_unique_key = p.sasaran_unique_key
          and coalesce(ss.validation_status, '') = 'valid'
      );
  end if;

  select count(*) into v_existing_errors
  from public.promote_error
  where promote_batch_id = v_promote_batch_id;

  if v_existing_errors > 0 then
    update public.promote_batch
    set status = 'invalid',
        error_rows = v_existing_errors,
        notes = 'Promote dry run gagal karena ditemukan error relasi/duplikasi.'
    where promote_batch_id = v_promote_batch_id;

    return jsonb_build_object(
      'ok', false,
      'status', 'invalid',
      'promote_batch_id', v_promote_batch_id,
      'import_batch_id', p_import_batch_id,
      'record_type', v_record_type,
      'sasaran_rows', v_sasaran_rows,
      'pendampingan_rows', v_pendampingan_rows,
      'error_rows', v_existing_errors
    );
  end if;

  if v_record_type in ('sasaran', 'mixed') then
    insert into public.dryrun_sasaran(
      promote_batch_id, import_batch_id, staging_row_id, record_id, client_mutation_id,
      source_mode, app_version, id_kecamatan, kode_kecamatan, nama_kecamatan,
      id_tim, nomor_tim, nama_tim, id_kader, nama_kader, id_wilayah,
      desa_kelurahan, dusun_rw, jenis_sasaran, nik, no_kk, nama_sasaran,
      jenis_kelamin, tanggal_lahir, usia_bulan, alamat_lengkap, nama_ibu_kandung,
      sasaran_unique_key, unique_key_strategy, needs_review, review_reason, raw_row_json
    )
    select
      v_promote_batch_id, s.import_batch_id, s.staging_row_id, s.record_id, s.client_mutation_id,
      s.source_mode, s.app_version, s.id_kecamatan, s.kode_kecamatan, s.nama_kecamatan,
      s.id_tim, s.nomor_tim, s.nama_tim, s.id_kader, s.nama_kader, s.id_wilayah,
      s.desa_kelurahan, s.dusun_rw, s.jenis_sasaran, s.nik, s.no_kk, s.nama_sasaran,
      s.jenis_kelamin, s.tanggal_lahir, s.usia_bulan, s.alamat_lengkap, s.nama_ibu_kandung,
      s.sasaran_unique_key, s.unique_key_strategy, public.normalize_backfill_bool(s.needs_review), s.review_reason, to_jsonb(s)
    from public.staging_sasaran_import s
    where s.import_batch_id = p_import_batch_id
      and coalesce(s.validation_status, '') = 'valid';

    get diagnostics v_inserted_sasaran = row_count;
  end if;

  if v_record_type in ('pendampingan', 'mixed') then
    insert into public.dryrun_pendampingan(
      promote_batch_id, import_batch_id, staging_row_id, record_id, client_mutation_id,
      source_mode, app_version, id_kecamatan, kode_kecamatan, nama_kecamatan,
      id_tim, nomor_tim, nama_tim, id_kader, nama_kader, id_wilayah,
      desa_kelurahan, dusun_rw, id_sasaran, id_sasaran_temp, sasaran_unique_key,
      jenis_sasaran, nik, nama_sasaran, periode_bulan, tahun_laporan, periode_yyyymm,
      tanggal_pendampingan, status_pendampingan, hasil_pendampingan, catatan_pendampingan,
      pendampingan_unique_key, needs_review, review_reason, parent_sasaran_dryrun_id,
      parent_resolution_status, raw_row_json
    )
    select
      v_promote_batch_id, p.import_batch_id, p.staging_row_id, p.record_id, p.client_mutation_id,
      p.source_mode, p.app_version, p.id_kecamatan, p.kode_kecamatan, p.nama_kecamatan,
      p.id_tim, p.nomor_tim, p.nama_tim, p.id_kader, p.nama_kader, p.id_wilayah,
      p.desa_kelurahan, p.dusun_rw, p.id_sasaran, p.id_sasaran_temp, p.sasaran_unique_key,
      p.jenis_sasaran, p.nik, p.nama_sasaran, p.periode_bulan, p.tahun_laporan, p.periode_yyyymm,
      p.tanggal_pendampingan, p.status_pendampingan, p.hasil_pendampingan, p.catatan_pendampingan,
      p.pendampingan_unique_key, public.normalize_backfill_bool(p.needs_review), p.review_reason,
      ds.dryrun_sasaran_id,
      case
        when ds.dryrun_sasaran_id is not null then 'FOUND_DRYRUN_SASARAN'
        else 'FOUND_VALID_STAGING_SASARAN'
      end,
      to_jsonb(p)
    from public.staging_pendampingan_import p
    left join public.dryrun_sasaran ds
      on ds.sasaran_unique_key = p.sasaran_unique_key
    where p.import_batch_id = p_import_batch_id
      and coalesce(p.validation_status, '') = 'valid';

    get diagnostics v_inserted_pendampingan = row_count;
  end if;

  update public.promote_batch
  set status = 'dry_run_valid',
      sasaran_rows = v_inserted_sasaran,
      pendampingan_rows = v_inserted_pendampingan,
      error_rows = 0,
      promoted_at = now(),
      notes = 'Promote dry run berhasil. Data hanya masuk ke tabel dryrun, belum production final.'
  where promote_batch_id = v_promote_batch_id;

  return jsonb_build_object(
    'ok', true,
    'status', 'dry_run_valid',
    'promote_batch_id', v_promote_batch_id,
    'import_batch_id', p_import_batch_id,
    'record_type', v_record_type,
    'sasaran_rows', v_inserted_sasaran,
    'pendampingan_rows', v_inserted_pendampingan,
    'error_rows', 0,
    'dry_run_only', true
  );
end;
$$;

create or replace function public.purge_backfill_promote_dry_run(
  p_promote_batch_id text default null,
  p_import_batch_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted_promote_batch integer := 0;
  v_target_batches text[];
begin
  if nullif(trim(coalesce(p_promote_batch_id, '')), '') is null
     and nullif(trim(coalesce(p_import_batch_id, '')), '') is null then
    return jsonb_build_object(
      'ok', false,
      'status', 'invalid_request',
      'message', 'Isi promote_batch_id atau import_batch_id untuk purge dry run.',
      'error_code', 'PURGE_KEY_REQUIRED'
    );
  end if;

  select array_agg(promote_batch_id) into v_target_batches
  from public.promote_batch
  where (p_promote_batch_id is null or promote_batch_id = p_promote_batch_id)
    and (p_import_batch_id is null or import_batch_id = p_import_batch_id)
    and dry_run is true;

  if v_target_batches is null then
    return jsonb_build_object(
      'ok', true,
      'status', 'no_rows',
      'message', 'Tidak ada promote dry run batch yang cocok.',
      'deleted_promote_batch', 0
    );
  end if;

  delete from public.promote_batch
  where promote_batch_id = any(v_target_batches);

  get diagnostics v_deleted_promote_batch = row_count;

  return jsonb_build_object(
    'ok', true,
    'status', 'purged',
    'deleted_promote_batch', v_deleted_promote_batch,
    'promote_batch_ids', v_target_batches
  );
end;
$$;

revoke execute on function public.promote_backfill_batch_dry_run(text, text, boolean) from public;
revoke execute on function public.promote_backfill_batch_dry_run(text, text, boolean) from anon;
revoke execute on function public.promote_backfill_batch_dry_run(text, text, boolean) from authenticated;
revoke execute on function public.purge_backfill_promote_dry_run(text, text) from public;
revoke execute on function public.purge_backfill_promote_dry_run(text, text) from anon;
revoke execute on function public.purge_backfill_promote_dry_run(text, text) from authenticated;

grant execute on function public.promote_backfill_batch_dry_run(text, text, boolean) to postgres;
grant execute on function public.promote_backfill_batch_dry_run(text, text, boolean) to service_role;
grant execute on function public.purge_backfill_promote_dry_run(text, text) to postgres;
grant execute on function public.purge_backfill_promote_dry_run(text, text) to service_role;
