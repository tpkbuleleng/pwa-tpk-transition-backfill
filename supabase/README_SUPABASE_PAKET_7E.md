# Paket 7-E — Production Master Reference & Scope Foundation

Jalankan migration berikut secara berurutan di Supabase project `tpk-backfill-staging`:

1. `20260615_13_backfill_master_reference_scope_schema.sql`
2. `20260615_14_backfill_master_reference_seed_functions.sql`
3. `20260615_15_backfill_scope_enriched_read_models.sql`

Paket ini membuat master reference dasar dan scope foundation, lalu memperkaya read model dari Paket 7-D. Paket ini belum membuka akses frontend production dan belum menerapkan RLS role final.
