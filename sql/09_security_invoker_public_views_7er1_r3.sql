-- ============================================================
-- PWA TPK Kabupaten Buleleng
-- Paket 7-E-R1-R3
-- Patch 09: Security Invoker for Public Views
-- ============================================================
-- Tujuan:
-- 1. Menghapus warning Supabase Security Advisor: Security Definer View.
-- 2. Mengubah view public/read-model agar berjalan sebagai SECURITY INVOKER.
-- 3. Membuat view mengikuti permission/RLS caller, bukan owner postgres.
-- 4. Aman dijalankan berulang.
-- 5. Tidak mengubah RLS/policy, tabel, function, atau data.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v RECORD;
BEGIN
  -- Patch semua view di schema public, karena public termasuk exposed schema Supabase.
  -- Relkind 'v' = ordinary view; materialized view tidak disentuh.
  FOR v IN
    SELECT
      n.nspname AS schema_name,
      c.relname AS view_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relkind = 'v'
    ORDER BY c.relname
  LOOP
    EXECUTE format(
      'ALTER VIEW %I.%I SET (security_invoker = true)',
      v.schema_name,
      v.view_name
    );
  END LOOP;
END $$;

COMMIT;
