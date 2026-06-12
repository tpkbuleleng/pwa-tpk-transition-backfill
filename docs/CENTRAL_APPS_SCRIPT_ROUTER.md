# Central Apps Script Router & Workbook Routing Lock

## Prinsip

Frontend PWA tidak lagi diarahkan langsung ke Apps Script yang melekat pada satu workbook kecamatan. Frontend hanya memakai satu endpoint pusat.

```txt
GitHub Pages PWA
  ↓
TPK Backfill Router Web App
  ↓ route by kode_kecamatan / id_kecamatan
BACKFILL_TPK_TJK, BACKFILL_TPK_BLL, dst.
```

## Kenapa perlu router pusat?

Jika setiap workbook memiliki endpoint sendiri, risiko operasional meningkat:

- banyak URL yang harus dipelihara;
- kode Apps Script bisa berbeda versi;
- frontend rawan menunjuk endpoint yang salah;
- update backend harus dilakukan berulang di banyak project;
- audit versi backend menjadi sulit.

Router pusat membuat frontend tetap single endpoint.

## Routing key

Router membaca salah satu field berikut:

```txt
kode_kecamatan
id_kecamatan
route_code
```

Prioritas utama: `kode_kecamatan`. Jika tidak ada, router memakai `id_kecamatan`.

## Mapping workbook

Mapping berada di `apps-script/Code.gs`:

```js
const BACKFILL_WORKBOOK_ROUTES = Object.freeze({
  TJK: {
    spreadsheetId: '',
    spreadsheetName: 'BACKFILL_TPK_TJK',
    namaKecamatan: 'TEJAKULA',
    isActive: true,
  },
});
```

Untuk production backfill 9 kecamatan, isi semua `spreadsheetId`.

## Proteksi mismatch

Router menolak payload jika `nama_kecamatan` tidak sesuai dengan route.

Contoh:

```txt
kode_kecamatan = TJK
nama_kecamatan = BULELENG
```

Response:

```txt
status: routing_error
code: KECAMATAN_ROUTE_MISMATCH
```

## Action baru

Paket 5-R1 menambahkan action:

```txt
getWorkbookRoute
```

Action ini hanya mengecek apakah route workbook tersedia tanpa append data.

## Catatan fallback

`ALLOW_BOUND_SPREADSHEET_FALLBACK_FOR_TEST = true` hanya untuk uji cepat bila script masih ditempel di workbook TJK.

Untuk pola final, gunakan Apps Script standalone dan isi `spreadsheetId`.
