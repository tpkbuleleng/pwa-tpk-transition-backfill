# Paket 7-F — Production Query Contract & Frontend Readiness

## Status Awal

Paket ini dilanjutkan setelah:

- Paket 7-E PASS
- Paket 7-E-R1 PASS LENGKAP / STABIL
- Patch 7-E-R1-R2 Summary Naming Repair PASS
- Patch 7-E-R1-R3 Security Invoker Views PASS
- Supabase Security Advisor: No items found

## Tujuan

Mengunci kontrak baca production agar frontend PWA nanti dapat membaca data production melalui kontrak backend, tanpa UI memanggil Supabase secara langsung.

Paket ini **bukan** paket Auth/RLS penuh dan **bukan** aktivasi SupabaseProvider final. Paket ini hanya menyiapkan:

1. RPC/read contract production berbasis read model 7-E-R1.
2. Envelope JSON yang stabil untuk frontend.
3. Filter query dasar untuk sasaran, pendampingan, dan summary.
4. Guard agar `BADUTA` tidak dipakai sebagai `jenis_sasaran` query.
5. Frontend service layer yang tetap memanggil `backend.*`, bukan Supabase langsung.
6. Smoke test SQL untuk memastikan read contract berjalan.

## Prinsip

UI PWA tetap mengikuti alur:

```txt
UI
  ↓
Service / Use Case Layer
  ↓
Backend Contract
  ↓
Provider aktif sesuai APP_MODE
```

UI tidak boleh memanggil:

```txt
supabase.from(...)
supabase.rpc(...)
google.script.run(...)
fetch(Apps Script URL)
```

secara langsung.

## Kontrak Query Baru

Backend contract yang disiapkan:

```txt
backend.querySasaranLite(filters)
backend.queryPendampinganLite(filters)
backend.getProductionBasicSummary(filters?)
backend.checkProductionQueryContractHealth()
```

## Sumber Data Supabase

Paket ini membaca read model hasil Paket 7-E-R1:

```txt
public.v_sasaran_lite_7er1
public.v_pendampingan_lite_7er1
public.v_summary_tim_basic_7er1
public.v_summary_kecamatan_basic_7er1
public.v_summary_pendampingan_tim_basic_7er1
public.v_summary_pendampingan_kecamatan_basic_7er1
```

## File SQL

Jalankan berurutan:

```txt
sql/01_query_contract_rpc_7f.sql
sql/02_smoke_test_query_contract_7f.sql
```

## File Frontend

File frontend bersifat aman dan belum otomatis aktif:

```txt
src/contracts/BackendProviderContract7F.js
src/contracts/productionQueryContract7F.js
src/services/ProductionReadService7F.js
src/providers/SupabaseProviderQuery7F.placeholder.js
```

## Catatan Keamanan

Paket ini tidak mengubah:

- RLS
- Policy
- Auth
- Table ownership
- Data production
- Apps Script
- `backendConfig.js`
- `apps-script/Code.gs`

Semua function SQL diberi:

```sql
SET search_path = public, pg_temp
```

untuk menghindari warning Function Search Path Mutable.

## Target PASS

Paket 7-F dianggap PASS jika:

1. `query_sasaran_lite_7f()` mengembalikan data dengan envelope `ok/data/meta`.
2. `query_pendampingan_lite_7f()` mengembalikan data dengan envelope `ok/data/meta`.
3. `get_production_basic_summary_7f()` mengembalikan summary tim/kecamatan.
4. Filter `jenis_sasaran = BADUTA` ditolak sebagai query resmi.
5. Filter `jenis_sasaran = BALITA` diterima.
6. Filter `is_baduta_prioritas = true/false` berjalan.
7. Health check contract bernilai `ok = true`.
8. Security Advisor tidak menampilkan warning critical baru.
