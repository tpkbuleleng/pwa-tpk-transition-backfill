# Paket 3 — Shared Validation Layer

Dokumen ini mengunci validasi bersama untuk PWA TPK Kabupaten Buleleng pada arsitektur transisi:

- BACKFILL = Apps Script + Google Sheet staging
- PRODUCTION = Supabase

Validasi di Paket 3 berada di sisi frontend/service layer dan dipakai sebelum data dikirim ke backend provider.

## Prinsip

1. UI tidak memvalidasi langsung dengan kode tersebar.
2. UI memanggil fungsi validasi dari `src/validation/`.
3. Payload yang sama dipakai oleh BACKFILL dan PRODUCTION.
4. Error dikembalikan dalam bentuk `issues[]` yang konsisten.
5. Validasi backend tetap wajib dibuat pada Paket 5 dan Paket 7.

## File utama

```txt
src/validation/constants.js
src/validation/dateUtils.js
src/validation/validationMessages.js
src/validation/validators.js
src/validation/backfillValidation.js
src/validation/sasaranValidation.js
src/validation/pendampinganValidation.js
src/validation/index.js
src/validation/samplePayloads.js
```

## Validasi Sasaran

Fungsi utama:

```js
validateSasaranPayload(payload, options)
```

Validasi yang dicakup:

1. field wajib dasar sasaran;
2. `client_mutation_id` dengan prefix `reg`;
3. jenis sasaran: `CATIN`, `BUMIL`, `BUFAS`, `BADUTA`;
4. NIK 16 digit jika diisi;
5. No. KK 16 digit jika diisi;
6. tanggal lahir format `YYYY-MM-DD`;
7. tanggal lahir tidak boleh lebih dari hari ini;
8. BADUTA maksimal 24 bulan;
9. BUMIL wajib `PEREMPUAN`;
10. BUFAS wajib `PEREMPUAN`;
11. CATIN wajib minimal memiliki `nama_pasangan`.

## Unique Key Sasaran

Prioritas utama:

```txt
nik + id_tim
```

Jika NIK tidak valid/tidak tersedia:

```txt
nama_sasaran + tanggal_lahir + nama_ibu_kandung + id_tim
```

Fallback akan menghasilkan:

```js
needs_review: true
```

## Validasi Pendampingan

Fungsi utama:

```js
validatePendampinganPayload(payload, options)
```

Validasi yang dicakup:

1. field wajib dasar pendampingan;
2. `client_mutation_id` dengan prefix `pdg`;
3. tanggal pendampingan format `YYYY-MM-DD`;
4. tanggal pendampingan tidak boleh lebih dari hari ini;
5. periode BACKFILL hanya Januari–Juni 2026;
6. tanggal pendampingan harus sesuai bulan laporan;
7. maksimal 10 laporan per kader per bulan berdasarkan konteks yang diberikan frontend.

## Unique Key Pendampingan

```txt
id_sasaran / id_sasaran_temp + tahun_laporan + periode_bulan
```

Contoh:

```txt
SAS_TMP_TJK_0001|2026-01
```

## Output Validasi

Setiap fungsi validasi mengembalikan bentuk:

```js
{
  ok: true | false,
  status: "valid" | "invalid",
  error_count: 0,
  warning_count: 0,
  issues: [],
  meta: {}
}
```

Jika error:

```js
{
  field: "nik",
  code: "INVALID_NIK",
  message: "NIK wajib 16 digit angka.",
  severity: "error",
  detail: null
}
```

## Batas Paket 3

Paket 3 belum membuat:

1. form registrasi penuh;
2. form pendampingan penuh;
3. submit ke Google Sheet;
4. submit ke Supabase;
5. validasi backend Apps Script;
6. validasi SQL/RPC Supabase;
7. sync queue IndexedDB.

Hal-hal tersebut masuk paket berikutnya.
