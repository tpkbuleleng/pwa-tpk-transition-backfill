# Test Notes — Paket 7-A-R1

## Test 1 — Pendampingan identity binding

Input form pendampingan:

- NIK Sasaran: 5108010101010004
- Nama Sasaran: ANAK CONTOH 4
- Sasaran Unique Key: kosong
- ID Tim: TIM_TJK_001

Expected payload:

- sasaran_unique_key = 5108010101010004|TIM_TJK_001
- pendampingan_unique_key = 5108010101010004|TIM_TJK_001|2026-01

## Test 2 — Sheet staging

Setelah submit, cek `staging_pendampingan_jan`:

- kolom `nik` terisi
- kolom `nama_sasaran` terisi
- kolom `sasaran_unique_key` terisi

## Test 3 — Export CSV

Export pendampingan Januari. CSV harus membawa `nama_sasaran` terisi.

## Test 4 — Supabase validation

Import CSV baru ke `staging_pendampingan_import`, lalu jalankan:

```sql
select public.validate_backfill_import_batch('IMPB_...');
```

Expected: tidak ada error `STAGING_REQUIRED_FIELD_EMPTY` untuk `nama_sasaran`.
