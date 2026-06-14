-- Paket 7-C — Test Queries
-- Ganti import_batch_id sesuai hasil uji Anda.

-- 1. Promote sasaran dari dry-run ke production base.
select public.promote_backfill_dryrun_to_production(
  'IMPB_20260614231213957_083C56B6',
  'sasaran',
  false
);

-- 2. Cek production sasaran.
select
  sasaran_id,
  source_import_batch_id,
  sasaran_unique_key,
  nama_sasaran,
  nik,
  jenis_sasaran,
  created_at
from public.sasaran
order by created_at desc;

-- 3. Promote pendampingan dari dry-run ke production base.
select public.promote_backfill_dryrun_to_production(
  'IMPB_20260612160646488_BFF20131',
  'pendampingan',
  false
);

-- 4. Cek production pendampingan beserta parent sasaran.
select
  p.pendampingan_id,
  p.source_import_batch_id,
  p.pendampingan_unique_key,
  p.sasaran_unique_key,
  s.nama_sasaran as parent_nama_sasaran,
  p.periode_bulan,
  p.tahun_laporan,
  p.tanggal_pendampingan,
  p.created_at
from public.pendampingan p
join public.sasaran s on s.sasaran_id = p.sasaran_id
order by p.created_at desc;

-- 5. Cek production promote error.
select
  production_promote_batch_id,
  import_batch_id,
  record_type,
  error_code,
  error_message,
  unique_key,
  field_name,
  field_value,
  created_at
from public.production_promote_error
order by created_at desc;

-- 6. Purge metadata promote saja, tanpa menghapus tabel production base.
select public.purge_backfill_production_promote(
  null,
  'IMPB_20260612160646488_BFF20131',
  false
);

-- 7. Purge metadata + production rows dari batch tertentu. Gunakan hanya untuk uji staging.
select public.purge_backfill_production_promote(
  null,
  'IMPB_20260612160646488_BFF20131',
  true
);
