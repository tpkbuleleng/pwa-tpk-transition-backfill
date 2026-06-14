# Supabase Paket 7-D

Jalankan migration 10–12 di project `tpk-backfill-staging` setelah Paket 7-C PASS.

Paket ini membuat read model berbasis view dan query function. Semua akses publik tetap ditutup sampai Paket Auth/RLS role model.

Urutan:

```text
Paket 7-C production base
  ↓
public.sasaran / public.pendampingan
  ↓
v_sasaran_lite / v_pendampingan_lite
  ↓
query_sasaran_lite() / query_pendampingan_lite()
  ↓
Paket 7-E Auth & RLS nanti
```
