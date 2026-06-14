# Supabase Production Master Reference & Scope Foundation

Paket 7-E menambahkan fondasi referensi production:

- `master_kecamatan`
- `master_tim`
- `master_kader`
- `master_wilayah`
- `scope_profile`

Data awal dapat direfresh dari `public.sasaran` dan `public.pendampingan` memakai:

```sql
select public.refresh_master_reference_from_production('manual_test_p7e');
```

Read model Paket 7-D diperbarui agar field seperti `nama_tim`, `nomor_tim`, `nama_kader`, `desa_kelurahan`, dan `dusun_rw` diperkaya dari master reference.

Akses `anon` dan `authenticated` tetap ditutup sampai paket Auth/RLS final.
