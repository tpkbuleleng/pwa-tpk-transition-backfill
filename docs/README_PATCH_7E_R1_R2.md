# Patch 7-E-R1-R2 — Summary Naming Alignment Repair

Patch ini memperbaiki error pada patch 7-E-R1-R1:

```txt
function public.tpk_is_baduta_priority_7er1(unknown, integer) does not exist
```

Penyebab:

```txt
Nama helper yang benar adalah:
public.tpk_is_baduta_prioritas_7er1(p_jenis_sasaran text, p_usia_bulan integer)

Nama helper yang salah pada patch R1:
public.tpk_is_baduta_priority_7er1(...)
```

## Urutan Eksekusi

Jalankan di Supabase SQL Editor:

```txt
1. sql/07_summary_naming_alignment_7er1_r2.sql
2. sql/08_smoke_test_summary_naming_7er1_r2.sql
```

Tidak perlu mengulang migration 01-06 bila sebelumnya sudah sukses.

## Target PASS

```txt
legacy_total_baduta_columns_should_be_0 = 0
v_summary_*_7er1 memiliki total_balita dan total_baduta_prioritas
v_summary_*_7er1 tidak memiliki total_baduta
BADUTA tetap ditolak sebagai jenis_sasaran resmi
BALITA 23 bulan -> baduta prioritas true
BALITA 25 bulan -> baduta prioritas false
summary pendampingan tetap tersedia
```

## Catatan Aman

- Tidak mengubah RLS/policy.
- Tidak menyentuh Auth/SupabaseProvider.
- Tidak menambah function alias baru yang tidak perlu.
- Menggunakan `v_sasaran_lite_7er1` sebagai base agar parsing field tetap konsisten dengan migration 04.
