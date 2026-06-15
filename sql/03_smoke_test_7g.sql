-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-G
-- Smoke Test 03: Import Finalization + Selective Export Bridge
-- ============================================================
-- Jalankan setelah 01_import_batch_finalization_7g.sql dan
-- 02_selective_export_bridge_log_7g.sql.
-- Semua query bersifat aman. Hanya test register bridge yang menulis 1 row
-- metadata internal dengan export_batch_id TEST_7G_SMOKE.
-- ============================================================

-- 1) Health finalization.
SELECT public.check_import_finalization_health_7g() AS import_finalization_health_7g;

-- 2) Health bridge log.
SELECT public.check_selective_export_bridge_health_7g() AS selective_export_bridge_health_7g;

-- 3) Check batch tanpa id harus ditolak.
SELECT public.check_import_batch_finalization_7g(NULL) AS missing_batch_should_be_rejected_7g;

-- 4) Register sample manifest internal untuk memastikan bridge log berfungsi.
SELECT public.register_selective_export_bridge_7g(
  jsonb_build_object(
    'export_batch_id', 'TEST_7G_SMOKE',
    'kode_kecamatan', 'TJK',
    'source_workbook', 'BACKFILL_TPK_TJK',
    'source_sheet', 'staging_sasaran',
    'source_table', 'sasaran',
    'export_scope', 'SMOKE_TEST',
    'selected_row_count', 0,
    'selected_record_keys', '[]'::jsonb,
    'checksum_sha256', 'SMOKE_TEST_ONLY',
    'status', 'REGISTERED',
    'manifest', jsonb_build_object(
      'note', 'Smoke test metadata only. No CSV data inserted.'
    )
  )
) AS register_bridge_smoke_7g;

-- 5) Read bridge sample.
SELECT public.get_selective_export_bridge_log_7g('TEST_7G_SMOKE') AS bridge_log_smoke_7g;

-- 6) Ringkasan PASS.
SELECT jsonb_build_object(
  'ok', true,
  'contract_version', public.tpk_import_bridge_version_7g(),
  'query_contract_version', public.tpk_query_contract_version_7f(),
  'taxonomy_version', public.tpk_taxonomy_version_7er1(),
  'finalization_health_ok', (public.check_import_finalization_health_7g() ->> 'ok')::boolean,
  'bridge_health_ok', (public.check_selective_export_bridge_health_7g() ->> 'ok')::boolean,
  'security_views_without_invoker', public.check_import_finalization_health_7g() #>> '{checks,public_views_without_security_invoker}'
) AS smoke_summary_7g;
