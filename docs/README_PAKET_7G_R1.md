# Paket 7-G-R1 — Selective CSV Raw Import Bridge

Patch ini dibuat karena CSV hasil **Selective Export 7-G** memakai header sumber dari Google Sheet staging, sedangkan `public.staging_sasaran_import` memiliki header metadata internal Supabase yang berbeda (`staging_row_id`, `loaded_at`, `validation_status`, dan seterusnya).

Karena itu CSV selective export **tidak diimpor langsung** ke `public.staging_sasaran_import`.

Alur yang benar:

```txt
CSV Selective Export 7-G
  ↓ import via Supabase Table Editor
backfill_internal.selective_sasaran_export_raw_7g
  ↓ load_selective_sasaran_raw_to_staging_7g()
public.staging_sasaran_import
  ↓ validate_backfill_import_batch()
Pipeline 7-A → 7-B → 7-C → finalization 7-G
```

## Urutan eksekusi

1. Jalankan:

```sql
sql/05_selective_sasaran_raw_import_bridge_7g_r1.sql
```

2. Di Supabase Table Editor, buka:

```txt
backfill_internal.selective_sasaran_export_raw_7g
```

3. Sebelum import uji, kosongkan raw table bila perlu:

```sql
TRUNCATE backfill_internal.selective_sasaran_export_raw_7g;
```

4. Import CSV:

```txt
EXP7G_TJK_SASARAN_20260615_094204_TJK_sasaran_staging_sasaran.csv
```

ke table raw tersebut, bukan ke `public.staging_sasaran_import`.

Jika Supabase menanyakan RLS, pilih:

```txt
Run and enable RLS
```

5. Jalankan smoke test:

```sql
sql/06_smoke_test_selective_sasaran_raw_import_bridge_7g_r1.sql
```

## Catatan penting BADUTA

CSV batch yang sedang diuji masih memuat setidaknya satu row:

```txt
jenis_sasaran = BADUTA
```

Sesuai Paket 7-E-R1, BADUTA tidak boleh lagi masuk sebagai `jenis_sasaran` input baru. Karena itu function loader akan mengembalikan:

```txt
ok=false
code=BADUTA_LEGACY_ROWS_FOUND
```

Itu bukan error bridge. Itu guard taxonomy yang benar.

Untuk import final, gunakan salah satu pilihan:

1. Re-export hanya record yang valid secara taxonomy, misalnya `BUMIL`, `BUFAS`, `CATIN`, `BALITA`.
2. Bersihkan/migrasikan data legacy BADUTA di sumber menjadi `BALITA + baduta priority` melalui paket cleanup legacy khusus.
3. Untuk uji infrastruktur saja, set `p_reject_legacy_baduta=false`, tetapi ini tidak direkomendasikan untuk lock final karena dapat melanggar kontrak 7-E-R1 bila constraint staging menolak BADUTA.

## Contoh load setelah raw CSV masuk

```sql
SELECT public.load_selective_sasaran_raw_to_staging_7g(
  'EXP7G_TJK_SASARAN_20260615_094204',
  'IMP7G_TJK_SASARAN_20260615_094204',
  true,
  false
);
```

Jika CSV masih memuat BADUTA, hasil yang benar adalah `ok=false` dengan `BADUTA_LEGACY_ROWS_FOUND`.

