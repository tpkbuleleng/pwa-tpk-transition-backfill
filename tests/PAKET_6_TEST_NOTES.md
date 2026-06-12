# Test Notes Paket 6

## Uji wajib

- Cek Backend menampilkan `gas-backfill-router-p6-20260612-r1`.
- Cek Workbook Route untuk TJK berhasil.
- Cek Export Readiness sasaran berhasil dan `header_ok = true`.
- Export CSV sasaran berhasil, menghasilkan `export_batch_id`, `import_batch_id`, dan file CSV.
- Cek sheet `export_log` berisi baris baru untuk export sasaran.
- Cek Export Readiness pendampingan Januari berhasil.
- Export CSV pendampingan Januari berhasil.
- Cek sheet `export_log` berisi baris baru untuk export pendampingan.

## Hasil yang diharapkan

- Tidak ada error `CSV_HEADER_MISMATCH`.
- Tidak ada error routing.
- CSV preview menampilkan header dan beberapa baris awal.
- File CSV bisa dibuka dari link Google Drive.
