# Paket 7-F-R1 — JSONB Filter Overload Patch

Patch ini menambahkan overload function:

```sql
public.query_sasaran_lite_7f(p_filters jsonb)
public.query_pendampingan_lite_7f(p_filters jsonb)
```

## Alasan

Paket 7-F awal membuat function RPC positional:

```sql
public.query_sasaran_lite_7f(
  p_id_kecamatan,
  p_id_tim,
  p_jenis_sasaran,
  p_is_baduta_prioritas,
  p_search,
  p_limit,
  p_offset
)
```

Karena itu pemanggilan berikut gagal:

```sql
SELECT public.query_sasaran_lite_7f('{}'::jsonb);
```

Patch R1 membuat pemanggilan berbasis object JSONB valid, tanpa menghapus function positional lama.

## Urutan Eksekusi

```txt
1. sql/03_query_contract_jsonb_overload_7f_r1.sql
2. sql/04_smoke_test_jsonb_overload_7f_r1.sql
```

## Catatan Teknis

- Overload JSONB tidak diberi default `DEFAULT '{}'::jsonb` agar tidak ambigu dengan function positional yang semua argumennya sudah memiliki default.
- Tidak mengubah table, view, RLS, policy, data, Apps Script, atau frontend.
- Semua function memakai `SET search_path = public, pg_temp`.

## Target PASS

```txt
query_sasaran_lite_7f('{}'::jsonb)                 -> ok true
query_pendampingan_lite_7f('{}'::jsonb)            -> ok true
query_sasaran_lite_7f('{"jenis_sasaran":"BADUTA"}'::jsonb) -> ok false + BADUTA_LEGACY_NOT_ALLOWED
check_production_query_contract_health_7f()        -> ok true
Security Advisor                                   -> tetap bersih
```
