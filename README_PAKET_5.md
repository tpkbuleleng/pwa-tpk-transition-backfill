# Paket 5 — Apps Script Provider & Sheet Staging

Paket ini mengaktifkan jalur submit nyata untuk mode BACKFILL:

GitHub Pages frontend -> BackendProvider -> GASProvider -> Apps Script Web App -> Google Sheet staging.

## File penting

- `apps-script/Code.gs` — backend Apps Script Paket 5
- `src/providers/GASProvider.js` — tambahan action `setupStagingSheets`
- `src/main.js` — tombol setup dan submit ke sheet
- `index.html` — UI Paket 5

## Tidak termasuk

ZIP ini tidak menyertakan `src/config/backendConfig.js` agar URL Apps Script yang sudah aktif tidak tertimpa.

## Langkah deploy

1. Upload isi ZIP ke root repository GitHub.
2. Commit dengan pesan `Paket 5 - Apps Script Provider and Sheet Staging`.
3. Copy `apps-script/Code.gs` ke Apps Script yang terhubung dengan Google Sheet `BACKFILL_TPK_TJK`.
4. Deploy ulang Web App Apps Script.
5. Pastikan URL Web App di `src/config/backendConfig.js` masih benar.
6. Buka GitHub Pages.
7. Klik `Setup Sheet Staging`.
8. Uji submit sasaran dan pendampingan.

## Catatan keamanan

Paket 5 belum memakai login penuh. Data konteks kader/tim masih manual untuk uji alur submit. Pengamanan operasional penuh baru dikunci setelah master user dan scope data masuk paket berikutnya.
