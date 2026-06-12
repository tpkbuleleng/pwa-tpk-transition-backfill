# Apps Script Paket 6

Tempel seluruh isi `Code.gs` ke Apps Script pusat `TPK Backfill`.

Pastikan `BACKFILL_WORKBOOK_ROUTES.TJK.spreadsheetId` tetap berisi ID Google Sheet, bukan URL Apps Script.

Setelah ditempel:

1. Save.
2. Deploy → Manage deployments.
3. Edit deployment aktif.
4. Pilih New version.
5. Deploy.

Paket 6 memakai `DriveApp.createFile()` sehingga otorisasi Google Drive mungkin diminta pada eksekusi pertama.
