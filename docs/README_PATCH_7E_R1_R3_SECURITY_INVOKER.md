# Patch 7-E-R1-R3 — Security Invoker Public Views

## Masalah

Supabase Security Advisor menampilkan warning/critical:

```txt
Security Definer View
public.v_sasaran_lite_7er1
public.v_pendampingan_lite_7er1
public.v_summary_tim_basic_7er1
...
```

Ini muncul karena view PostgreSQL di `public` secara default berjalan sebagai security definer, sehingga dapat melewati RLS dari tabel dasar jika kelak view dibuka ke role `anon` atau `authenticated`.

## Perbaikan

Patch ini menjalankan:

```sql
ALTER VIEW public.<view_name> SET (security_invoker = true);
```

untuk semua ordinary view di schema `public`.

## Yang Tidak Diubah

- Tidak mengubah tabel.
- Tidak mengubah data.
- Tidak mengubah RLS.
- Tidak membuat policy baru.
- Tidak mengubah function.
- Tidak mengubah Apps Script.
- Tidak mengubah frontend.

## Urutan Eksekusi

Jalankan di Supabase SQL Editor:

```txt
1. sql/09_security_invoker_public_views_7er1_r3.sql
2. sql/10_smoke_test_security_invoker_views_7er1_r3.sql
```

## Target Smoke Test

```txt
public_views_without_security_invoker = 0
```

Jika SQL Editor masih bisa membaca view sebagai role `postgres`, itu normal.
Nanti ketika view dibuka ke frontend dengan role `anon/authenticated`, akses akan mengikuti RLS/policy tabel dasar.

## Setelah Patch

Buka Supabase Advisor Center lalu jalankan ulang Security Advisor / refresh.
Kadang daftar advisor tidak langsung hilang sampai scan ulang selesai.
