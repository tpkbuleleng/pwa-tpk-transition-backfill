# Paket 6 — Export CSV & Import Readiness

Paket ini melanjutkan Paket 5-R1 dengan fitur export CSV dari Google Sheet staging menuju kontrak Supabase staging.

## Fitur utama

- `getExportReadiness`
- `exportCsv`
- validasi header sebelum export
- abaikan baris kosong
- generate `export_batch_id`
- generate `import_batch_id`
- inject `import_batch_id` ke CSV export tanpa mengubah data staging asli
- catat hasil export ke `export_log`
- buat file CSV di Google Drive jika `create_drive_file = TRUE`
- tampilkan preview CSV untuk verifikasi awal

## File penting

- `apps-script/Code.gs` harus ditempel ke Apps Script pusat `TPK Backfill`.
- `src/config/backendConfig.js` tidak disertakan agar URL endpoint tidak tertimpa.
- Frontend tetap memakai satu URL Apps Script pusat.

## Urutan uji

1. Upload isi ZIP ke root repository GitHub.
2. Commit dengan pesan: `Paket 6 - Export CSV and Import Readiness`.
3. Paste `apps-script/Code.gs` ke Apps Script pusat `TPK Backfill`.
4. Deploy ulang Web App dengan New version.
5. Buka GitHub Pages.
6. Klik `Cek Backend`.
7. Klik `Cek Workbook Route`.
8. Pada modul Export, pilih `Sasaran`, lalu klik `Cek Export Readiness`.
9. Klik `Export CSV`.
10. Ulangi untuk `Pendampingan` bulan Januari.
11. Cek sheet `export_log`.
12. Cek file CSV yang dibuat di Google Drive.

## Catatan otorisasi

Karena Paket 6 memakai `DriveApp.createFile()` untuk membuat file CSV, Apps Script mungkin meminta otorisasi ulang saat deploy atau eksekusi pertama.
