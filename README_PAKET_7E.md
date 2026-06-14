# Paket 7-E — Production Master Reference & Scope Foundation

Paket ini menambahkan master reference dan scope foundation sebelum Supabase Auth/RLS frontend diaktifkan.

## File utama

- `supabase/migrations/20260615_13_backfill_master_reference_scope_schema.sql`
- `supabase/migrations/20260615_14_backfill_master_reference_seed_functions.sql`
- `supabase/migrations/20260615_15_backfill_scope_enriched_read_models.sql`
- `src/supabase/masterReferenceContract.js`

## Batas paket

Belum termasuk:

- Supabase Auth login
- RLS role final KADER/PKB/admin
- SupabaseProvider frontend aktif
- dashboard production penuh

## Uji utama

```sql
select public.refresh_master_reference_from_production('manual_test_p7e');
select public.check_master_reference_health();
select public.get_scope_foundation_summary('TJK', 'TIM_TJK_001');
select * from public.query_sasaran_lite('TJK', 'TIM_TJK_001', null, 'AKTIF', null, 50, 0);
select * from public.query_pendampingan_lite('TJK', 'TIM_TJK_001', 2026, 1, null, 50, 0);
```
