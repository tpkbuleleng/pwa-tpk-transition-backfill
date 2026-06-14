# Paket 7-D — Production Read Model & Basic Query Layer

## Tujuan

Paket 7-D menambahkan read model production dasar setelah Paket 7-C berhasil membuat dan mengisi tabel production base `sasaran` dan `pendampingan`.

Paket ini belum mengaktifkan SupabaseProvider frontend, Supabase Auth, atau RLS role kader. Semua objek read model tetap tertutup dari `anon` dan `authenticated`.

## Objek SQL

Migration yang harus dijalankan berurutan:

1. `supabase/migrations/20260615_10_backfill_production_read_models.sql`
2. `supabase/migrations/20260615_11_backfill_basic_query_functions.sql`
3. `supabase/migrations/20260615_12_backfill_read_model_access_and_health.sql`

Objek utama:

- `v_sasaran_lite`
- `v_pendampingan_lite`
- `v_summary_tim_basic`
- `v_summary_kecamatan_basic`
- `v_production_read_model_health`
- `query_sasaran_lite(...)`
- `query_pendampingan_lite(...)`
- `get_production_basic_summary(...)`
- `check_production_read_model_health()`

## Uji utama

```sql
select public.check_production_read_model_health();

select * from public.v_production_read_model_health;

select * from public.query_sasaran_lite(
  'TJK', 'TIM_TJK_001', null, 'AKTIF', null, 50, 0
);

select * from public.query_pendampingan_lite(
  'TJK', 'TIM_TJK_001', 2026, 1, null, 50, 0
);

select public.get_production_basic_summary('TJK', 'TIM_TJK_001');
```

## Batas Paket

Belum termasuk:

- Supabase Auth.
- SupabaseProvider aktif di frontend.
- Policy RLS untuk KADER/PKB/admin.
- Dashboard production lengkap.
- Sync queue production.

## Status PASS

Paket 7-D dianggap PASS jika:

- Tiga migration SQL berhasil dijalankan.
- `v_sasaran_lite` menampilkan sasaran production base.
- `v_pendampingan_lite` menampilkan pendampingan dengan parent sasaran valid.
- `v_summary_tim_basic` dan `v_summary_kecamatan_basic` menghasilkan ringkasan.
- `query_sasaran_lite()` dan `query_pendampingan_lite()` berhasil dipanggil dari SQL Editor.
- `check_production_read_model_health()` mengembalikan status `healthy`.
- Security Advisor tetap 0 errors / 0 warnings kritikal.
