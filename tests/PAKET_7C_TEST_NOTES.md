# Paket 7-C Test Notes

## Preconditions

- Paket 7-A PASS.
- Paket 7-A-R1 PASS.
- Paket 7-B PASS.
- Batch sasaran sudah masuk `dryrun_sasaran`.
- Batch pendampingan sudah masuk `dryrun_pendampingan`.

## Uji SQL

1. Jalankan SQL migration 07–09.
2. Promote batch sasaran.
3. Cek tabel `sasaran`.
4. Promote batch pendampingan.
5. Cek tabel `pendampingan`.
6. Cek `production_promote_error` kosong untuk batch valid.
7. Jalankan Security Advisor dan pastikan tidak ada warning kritikal baru.

## Expected Result

- `promote_backfill_dryrun_to_production(..., 'sasaran', false)` menghasilkan `ok: true`.
- `promote_backfill_dryrun_to_production(..., 'pendampingan', false)` menghasilkan `ok: true`.
- `sasaran` berisi parent sasaran.
- `pendampingan` memiliki `sasaran_id` yang valid.
