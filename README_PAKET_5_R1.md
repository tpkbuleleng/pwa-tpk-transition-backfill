# Paket 5-R1 — Central Apps Script Router & Workbook Routing Lock

Status: update files only.

Paket 5-R1 merapikan Paket 5 agar frontend hanya memakai satu URL Apps Script pusat. Apps Script pusat bertugas sebagai router dan memilih workbook backfill kecamatan berdasarkan `kode_kecamatan` atau `id_kecamatan` pada payload.

## Tujuan

- Menghindari 9 URL Apps Script berbeda untuk 9 workbook kecamatan.
- Menghindari versi backend bercampur, misalnya healthCheck masih p1 tetapi submit sudah p5.
- Mengunci pola final backfill: satu endpoint pusat, banyak workbook tujuan.
- Menyiapkan dasar yang aman sebelum Paket 6 export CSV.

## File utama

- `apps-script/Code.gs` — Apps Script Router pusat.
- `src/main.js` — menambahkan cek route workbook.
- `src/payload/payloadBuilder.js` — menambahkan `kode_kecamatan` pada payload.
- `src/providers/*` — menambahkan kontrak `getWorkbookRoute()`.
- `index.html` — menambahkan field Kode Kecamatan Router dan tombol Cek Workbook Route.
- `src/config/appConfig.js` — update versi frontend.

## File yang tidak disertakan

Paket ini tidak menyertakan:

```txt
src/config/backendConfig.js
```

Jadi URL backend yang sudah aktif tidak tertimpa. Setelah Apps Script Router pusat dibuat, ubah URL secara manual di `backendConfig.js`.

## Cara uji cepat TJK

Untuk uji cepat, file `apps-script/Code.gs` boleh ditempel pada Apps Script yang terikat workbook `BACKFILL_TPK_TJK`. Fallback active spreadsheet masih diizinkan.

Namun pola final yang direkomendasikan adalah Apps Script standalone bernama misalnya `TPK Backfill Router`.

## Cara final router pusat

1. Buat Apps Script standalone bernama `TPK Backfill Router`.
2. Paste seluruh isi `apps-script/Code.gs`.
3. Isi `spreadsheetId` pada `BACKFILL_WORKBOOK_ROUTES`, minimal TJK dulu.
4. Deploy sebagai Web App.
5. Copy URL Web App pusat.
6. Ubah `src/config/backendConfig.js` agar memakai URL router pusat.
7. Commit perubahan `backendConfig.js` secara manual.

## Urutan uji

1. `Cek Backend`.
2. `Cek Workbook Route`.
3. `Setup Sheet Staging`.
4. `Isi Contoh Valid` sasaran.
5. `Kirim Sasaran ke Sheet`.
6. `Isi Contoh Valid` pendampingan.
7. `Kirim Pendampingan ke Sheet`.
8. Uji duplikasi submit dengan klik kirim kedua kali.

## PASS criteria

Paket 5-R1 dianggap PASS jika:

- `healthCheck` menampilkan `gas-backfill-router-p5-r1-20260612-r1`.
- `getWorkbookRoute` mengembalikan route `TJK` untuk konteks Tejakula.
- `setupStagingSheets` menampilkan `router_mode: CENTRAL_ROUTER`.
- Submit sasaran masuk ke `BACKFILL_TPK_TJK/staging_sasaran`.
- Submit pendampingan Januari masuk ke `BACKFILL_TPK_TJK/staging_pendampingan_jan`.
- Submit ulang dengan `client_mutation_id` yang sama ditolak sebagai duplicate.
