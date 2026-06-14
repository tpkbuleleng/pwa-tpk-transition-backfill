-- ============================================================
-- OPSIONAL — Jalankan hanya setelah 04_read_models_and_summary_7er1.sql PASS.
-- Paket 7-E-R1 — Replace nama read model lama ke versi 7-E-R1.
-- ============================================================
-- Tujuan:
-- - Mengarahkan nama standar Paket 7-D ke definisi 7-E-R1.
-- Risiko:
-- - Jika ada dependency ketat pada kolom/order lama, CREATE OR REPLACE VIEW
--   bisa gagal. Karena itu file ini OPSIONAL.
-- Rekomendasi:
-- - Uji dulu query *_7er1.
-- - Jalankan file ini hanya saat sudah siap mengunci Paket 7-D-R2.
-- ============================================================

BEGIN;

DROP VIEW IF EXISTS public.v_production_read_model_health CASCADE;
DROP VIEW IF EXISTS public.v_summary_pendampingan_kecamatan_basic CASCADE;
DROP VIEW IF EXISTS public.v_summary_pendampingan_tim_basic CASCADE;
DROP VIEW IF EXISTS public.v_summary_kecamatan_basic CASCADE;
DROP VIEW IF EXISTS public.v_summary_tim_basic CASCADE;
DROP VIEW IF EXISTS public.v_pendampingan_lite CASCADE;
DROP VIEW IF EXISTS public.v_sasaran_lite CASCADE;

CREATE VIEW public.v_sasaran_lite AS SELECT * FROM public.v_sasaran_lite_7er1;
CREATE VIEW public.v_pendampingan_lite AS SELECT * FROM public.v_pendampingan_lite_7er1;
CREATE VIEW public.v_summary_tim_basic AS SELECT * FROM public.v_summary_tim_basic_7er1;
CREATE VIEW public.v_summary_kecamatan_basic AS SELECT * FROM public.v_summary_kecamatan_basic_7er1;
CREATE VIEW public.v_summary_pendampingan_tim_basic AS SELECT * FROM public.v_summary_pendampingan_tim_basic_7er1;
CREATE VIEW public.v_summary_pendampingan_kecamatan_basic AS SELECT * FROM public.v_summary_pendampingan_kecamatan_basic_7er1;
CREATE VIEW public.v_production_read_model_health AS SELECT * FROM public.v_production_read_model_health_7er1;

COMMIT;
