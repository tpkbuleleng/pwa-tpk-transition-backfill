-- Paket 7-B — Test queries

-- 1) Promote dry-run sasaran
select public.promote_backfill_batch_dry_run(
  'IMPB_BATCH_SASARAN',
  'sasaran',
  false
);

-- 2) Promote dry-run pendampingan
select public.promote_backfill_batch_dry_run(
  'IMPB_BATCH_PENDAMPINGAN',
  'pendampingan',
  false
);

-- 3) Lihat summary promote batch
select *
from public.v_backfill_promote_batch_summary
order by created_at desc;

-- 4) Lihat error promote dry run
select *
from public.v_backfill_promote_error_summary
order by created_at desc;

-- 5) Lihat relasi pendampingan -> sasaran
select *
from public.v_backfill_dryrun_relation_summary
order by dryrun_pendampingan_id desc;

-- 6) Purge dry-run by import batch bila perlu
select public.purge_backfill_promote_dry_run(
  null,
  'IMPB_BATCH_ID'
);
