# API Contract 7-F — Production Query Contract

## Version

```txt
TPK_QUERY_CONTRACT_2026_7F
```

Taxonomy dependency:

```txt
TPK_TAXONOMY_2026_7E_R1
```

## Standard Envelope

Semua query read contract mengembalikan pola:

```json
{
  "ok": true,
  "contract_version": "TPK_QUERY_CONTRACT_2026_7F",
  "taxonomy_version": "TPK_TAXONOMY_2026_7E_R1",
  "data": [],
  "meta": {
    "total_count": 0,
    "limit": 50,
    "offset": 0,
    "filters": {}
  }
}
```

Jika filter invalid:

```json
{
  "ok": false,
  "contract_version": "TPK_QUERY_CONTRACT_2026_7F",
  "taxonomy_version": "TPK_TAXONOMY_2026_7E_R1",
  "errors": [
    {
      "field": "jenis_sasaran",
      "code": "BADUTA_LEGACY_NOT_ALLOWED",
      "message": "BADUTA tidak lagi dipakai sebagai jenis_sasaran. Gunakan BALITA + is_baduta_prioritas."
    }
  ],
  "data": [],
  "meta": {
    "total_count": 0,
    "limit": 0,
    "offset": 0
  }
}
```

## 1. querySasaranLite

Frontend service:

```js
backend.querySasaranLite(filters)
```

RPC Supabase:

```sql
public.query_sasaran_lite_7f(
  p_id_kecamatan text,
  p_id_tim text,
  p_jenis_sasaran text,
  p_is_baduta_prioritas boolean,
  p_search text,
  p_limit integer,
  p_offset integer
)
```

Allowed `jenis_sasaran`:

```txt
CATIN
BUMIL
BUFAS
BALITA
```

Not allowed:

```txt
BADUTA
```

Untuk mencari Baduta Prioritas:

```json
{
  "jenis_sasaran": "BALITA",
  "is_baduta_prioritas": true
}
```

## 2. queryPendampinganLite

Frontend service:

```js
backend.queryPendampinganLite(filters)
```

RPC Supabase:

```sql
public.query_pendampingan_lite_7f(
  p_id_kecamatan text,
  p_id_tim text,
  p_periode_bulan text,
  p_tahun_laporan integer,
  p_jenis_sasaran text,
  p_is_baduta_prioritas_saat_pendampingan boolean,
  p_search text,
  p_limit integer,
  p_offset integer
)
```

Untuk pendampingan historis, `is_baduta_prioritas_saat_pendampingan` dihitung dari:

```txt
tanggal_pendampingan - tanggal_lahir
```

bukan dari tanggal hari ini.

## 3. getProductionBasicSummary

Frontend service:

```js
backend.getProductionBasicSummary()
```

RPC Supabase:

```sql
public.get_production_basic_summary_7f()
```

Output utama:

```json
{
  "summary_tim": [],
  "summary_kecamatan": [],
  "summary_pendampingan_tim": [],
  "summary_pendampingan_kecamatan": []
}
```

Nama resmi:

```txt
total_balita
total_baduta_prioritas
pendampingan_balita
pendampingan_baduta_prioritas
```

Nama yang tidak boleh dipakai lagi:

```txt
total_baduta
```

## 4. checkProductionQueryContractHealth

Frontend service:

```js
backend.checkProductionQueryContractHealth()
```

RPC Supabase:

```sql
public.check_production_query_contract_health_7f()
```
