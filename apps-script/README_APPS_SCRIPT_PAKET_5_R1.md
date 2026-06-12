# Apps Script Paket 5-R1

## Mode final yang disarankan

Buat Apps Script standalone:

```txt
TPK Backfill Router
```

Tempel seluruh isi `Code.gs`, lalu isi mapping:

```js
TJK: { spreadsheetId: 'ISI_ID_SPREADSHEET_BACKFILL_TPK_TJK', ... }
```

Deploy sebagai Web App:

```txt
Execute as: Me
Who has access: Anyone
```

Masukkan URL Web App pusat ke:

```txt
src/config/backendConfig.js
```

## Mode uji cepat

Untuk uji cepat, `Code.gs` masih bisa ditempel pada Apps Script yang terikat workbook `BACKFILL_TPK_TJK`. Jika `spreadsheetId` kosong, script memakai active spreadsheet sebagai fallback.

Fallback ini hanya untuk uji, bukan untuk operasional 9 kecamatan.
