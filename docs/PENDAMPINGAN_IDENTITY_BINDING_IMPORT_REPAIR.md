# Pendampingan Identity Binding & Import Validation Repair

## Masalah

Validasi Supabase staging menemukan:

```txt
STAGING_REQUIRED_FIELD_EMPTY
Field wajib kosong: nama_sasaran
```

Pada record pendampingan, data identitas sasaran belum cukup lengkap untuk proses promote berikutnya.

## Keputusan Perbaikan

Pendampingan backfill wajib membawa identitas sasaran minimal:

- `sasaran_unique_key`
- `nama_sasaran`
- `jenis_sasaran`
- `periode_bulan`
- `tahun_laporan`
- `tanggal_pendampingan`

Jika NIK tersedia, `sasaran_unique_key` dibentuk sebagai:

```txt
nik|id_tim
```

Contoh:

```txt
5108010101010004|TIM_TJK_001
```

Pendampingan unique key dibentuk sebagai:

```txt
sasaran_unique_key|YYYY-MM
```

Contoh:

```txt
5108010101010004|TIM_TJK_001|2026-01
```

Dengan ini, data pendampingan dapat direlasikan kembali ke sasaran ketika masuk Supabase staging.

## Uji yang Diharapkan

1. Form pendampingan dengan NIK + Nama Sasaran valid.
2. Google Sheet `staging_pendampingan_jan` terisi `nik`, `nama_sasaran`, dan `sasaran_unique_key`.
3. Export CSV pendampingan menghasilkan kolom `nama_sasaran` terisi.
4. Import ke Supabase staging tidak lagi menghasilkan error `Field wajib kosong: nama_sasaran`.
