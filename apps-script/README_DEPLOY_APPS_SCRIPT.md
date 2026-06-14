# Deploy Apps Script — Paket 7-E-R1

Tambahkan file baru berikut ke Apps Script pusat **TPK Backfill**:

```txt
SasaranTaxonomyService_7ER1.gs
```

Jangan menimpa:

```txt
Code.gs
backendConfig.js
```

## Langkah aman

1. Buka Apps Script pusat `TPK Backfill`.
2. Tambahkan file baru `SasaranTaxonomyService_7ER1.gs`.
3. Tempel isi file utuh.
4. Jalankan function manual:

```txt
testTaxonomy7ER1
```

5. Pastikan hasil utama:

```txt
BADUTA => BADUTA_LEGACY_NOT_ALLOWED
BALITA lahir 2024-02-01, anchor 2026-01-31 => usia_bulan 23, is_baduta_prioritas true
BALITA lahir 2023-12-01, anchor 2026-01-31 => usia_bulan 25, is_baduta_prioritas false
```

6. Setelah smoke test berhasil, panggil helper berikut pada validasi append sasaran/pendampingan yang sudah ada:

```js
validateSasaranTaxonomy_7ER1(payload, { anchorDate: payload.tanggal_registrasi || payload.tanggal_import })
decorateSasaranPayloadTaxonomy_7ER1(payload, { anchorDate: payload.tanggal_registrasi || payload.tanggal_import })

validatePendampinganTaxonomy_7ER1(payload)
decoratePendampinganPayloadTaxonomy_7ER1(payload)
```

## Titik integrasi yang disarankan

- Sebelum append ke `staging_sasaran`.
- Sebelum append ke `staging_pendampingan_jan` sampai `staging_pendampingan_jun`.
- Sebelum hitung `sasaran_unique_key` / `pendampingan_unique_key` final bila payload builder memakai `jenis_sasaran`.

## Deploy

Setelah helper dipakai oleh router append yang aktif:

1. Deploy > Manage deployments.
2. Edit deployment aktif.
3. Pilih versi baru.
4. Deploy.
5. Uji dari PWA BACKFILL:
   - submit BALITA usia 0–23 bulan.
   - submit BALITA usia 24–59 bulan.
   - submit BADUTA dan pastikan ditolak.
