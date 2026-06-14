# Implementation Checklist Paket 7-F

## A. Supabase SQL

1. Buka Supabase SQL Editor.
2. Jalankan:

```txt
sql/01_query_contract_rpc_7f.sql
```

3. Jalankan:

```txt
sql/02_smoke_test_query_contract_7f.sql
```

4. Pastikan hasil smoke test:
   - contract version muncul.
   - query sasaran mengembalikan JSON.
   - query pendampingan mengembalikan JSON.
   - query BADUTA mengembalikan `ok=false`.
   - health check mengembalikan `ok=true`.

## B. Frontend

Tambahkan file baru saja:

```txt
src/contracts/BackendProviderContract7F.js
src/contracts/productionQueryContract7F.js
src/services/ProductionReadService7F.js
src/providers/SupabaseProviderQuery7F.placeholder.js
```

Jangan langsung wiring ke UI utama sebelum test manual service selesai.

## C. Yang Tidak Diubah

Jangan ubah:

```txt
backendConfig.js
apps-script/Code.gs
Auth/RLS/policy
Service worker
SupabaseProvider aktif
```

## D. Commit

Rekomendasi commit:

```bash
git add sql/ docs/ src/contracts/ src/services/ src/providers/
git commit -m "feat: add production query contract for 7F frontend readiness"
```

## E. PASS Gate

Paket 7-F dapat dinyatakan PASS jika SQL smoke test lulus dan frontend service layer sudah siap tanpa direct UI-to-Supabase call.
