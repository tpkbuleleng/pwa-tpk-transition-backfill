# Cara deploy Apps Script Paket 5

## Opsi paling aman: bound script dari Google Sheet

1. Buka Google Sheet `BACKFILL_TPK_TJK`.
2. Klik `Extensions` -> `Apps Script`.
3. Hapus isi `Code.gs` lama.
4. Paste isi file `apps-script/Code.gs` dari paket ini.
5. Klik Save.
6. Klik `Deploy` -> `New deployment`.
7. Type: `Web app`.
8. Execute as: `Me`.
9. Who has access: `Anyone`.
10. Klik Deploy.
11. Copy Web App URL ke `src/config/backendConfig.js`.

## Jika memakai Apps Script standalone

Isi konstanta berikut di `Code.gs`:

```js
const BACKFILL_SPREADSHEET_ID = 'ID_SPREADSHEET_BACKFILL_TPK_TJK';
```

Spreadsheet ID adalah bagian URL Google Sheet di antara `/d/` dan `/edit`.

## Uji wajib

1. Klik `Setup Sheet Staging` dari frontend.
2. Pastikan semua sheet staging dibuat.
3. Kirim satu sasaran valid.
4. Kirim satu pendampingan valid.
5. Klik submit ulang payload yang sama untuk memastikan duplikasi ditolak.
