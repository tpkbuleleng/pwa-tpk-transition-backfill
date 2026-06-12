# Paket 7-A-R1 — Pendampingan Identity Binding & Import Validation Repair

Paket ini memperbaiki temuan saat validasi Supabase staging: `nama_sasaran` pada `staging_pendampingan_import` kosong.

Akar masalah: form pendampingan backfill sebelumnya belum mengikat identitas sasaran secara lengkap. Akibatnya CSV pendampingan bisa berisi `id_sasaran_temp`, tetapi kosong pada `nama_sasaran` dan berpotensi tidak memakai `sasaran_unique_key` yang sama dengan data registrasi sasaran.

## Perubahan utama

- Menambah field pendampingan: `nik`, `nama_sasaran`, `sasaran_unique_key`.
- Payload pendampingan otomatis membentuk `sasaran_unique_key` dari `nik + id_tim` jika field `sasaran_unique_key` dikosongkan.
- Unique key pendampingan sekarang menggunakan `sasaran_unique_key + periode` agar sejalan dengan import Supabase.
- Validasi frontend dan backend mengunci `sasaran_unique_key` dan `nama_sasaran` sebagai field wajib pada pendampingan.
- Apps Script tetap memakai central router dan export CSV Paket 6.

## Langkah setelah upload

1. Upload isi ZIP ke root repo GitHub.
2. Update Apps Script pusat `TPK Backfill` dengan `apps-script/Code.gs` dari paket ini.
3. Pastikan `BACKFILL_WORKBOOK_ROUTES.TJK.spreadsheetId` tetap berisi ID Google Sheet, bukan URL Apps Script.
4. Deploy ulang Web App: `Manage deployments → Edit → New version → Deploy`.
5. Buat data pendampingan baru yang mengisi NIK dan Nama Sasaran.
6. Export ulang CSV pendampingan.
7. Import ulang ke Supabase staging dan jalankan validasi.

## Catatan

Error lama di Supabase tidak otomatis hilang. Hapus dulu rows import lama untuk `import_batch_id` yang gagal, atau import ulang dengan `import_batch_id` baru.
