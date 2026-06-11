# PWA TPK Kabupaten Buleleng

## Paket 2 — Data Dictionary & CSV Contract

Status: siap uji frontend GitHub Pages.

Paket ini menambahkan kontrak data untuk:

- data dictionary sasaran;
- data dictionary pendampingan;
- header Google Sheet staging;
- header CSV Supabase staging;
- unique key sasaran;
- unique key pendampingan;
- import_batch;
- import_error;
- export_log.

## Cara Upload ke GitHub

Upload isi ZIP ini ke root repository yang sudah berisi Paket 1.

File yang akan ditambahkan/diubah:

```txt
index.html
src/main.js
src/config/appConfig.js
src/styles/app.css
src/contracts/
docs/DATA_DICTIONARY_CSV_CONTRACT.md
templates/csv/
apps-script/BackfillHeaderContract.gs
README_PAKET_2.md
VERSION.txt
```

Paket ini sengaja tidak menyertakan `src/config/backendConfig.js`, sehingga URL Apps Script yang sudah Bapak/Ibu isi pada Paket 1 tidak tertimpa.

## Uji di GitHub Pages

Setelah commit, buka GitHub Pages dan cek:

1. badge tetap `BACKFILL`;
2. provider tetap `GASProvider`;
3. healthCheck tetap sukses;
4. tombol `Cek Data Dictionary & CSV Contract` menampilkan:
   - jumlah field sasaran;
   - jumlah field pendampingan;
   - header Google Sheet staging;
   - header Supabase staging;
   - contoh unique key.

## Commit Message yang Disarankan

```txt
Paket 2 PASS - Data Dictionary and CSV Contract
```

## Catatan

Service worker masih belum diaktifkan agar cache tidak mengganggu uji GitHub Pages.
