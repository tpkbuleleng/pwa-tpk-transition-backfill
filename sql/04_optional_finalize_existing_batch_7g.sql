-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G
-- Optional 04: Finalize Existing Import Batch
-- ============================================================
-- Ganti nilai import_batch_id/export_batch_id sesuai batch nyata.
-- Jalankan hanya setelah import -> validate -> dry-run -> promote production selesai.
-- ============================================================

-- 1) Cek dulu state batch.
SELECT public.check_import_batch_finalization_7g('GANTI_IMPORT_BATCH_ID') AS batch_check_before_finalize_7g;

-- 2) Finalisasi administratif batch.
SELECT public.finalize_backfill_import_batch_7g(
  jsonb_build_object(
    'import_batch_id', 'GANTI_IMPORT_BATCH_ID',
    'export_batch_id', 'GANTI_EXPORT_BATCH_ID',
    'finalized_by', 'postgres',
    'force', false
  )
) AS finalize_batch_7g;

-- 3) Cek ulang setelah finalisasi.
SELECT public.check_import_batch_finalization_7g('GANTI_IMPORT_BATCH_ID') AS batch_check_after_finalize_7g;
