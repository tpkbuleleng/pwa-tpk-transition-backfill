# Test Notes Paket 5

## Uji 1 — Setup Sheet

Klik `Setup Sheet Staging`.

Harapan:

- response `ok: true`
- sheet staging dibuat
- header ditulis sesuai kontrak Paket 2

## Uji 2 — Submit Sasaran Valid

1. Klik `Isi Contoh Valid` pada form sasaran.
2. Klik `Kirim Sasaran ke Sheet`.

Harapan:

- response `ok: true`
- data masuk ke `staging_sasaran`
- ada `record_id`
- `raw_payload_json` terisi

## Uji 3 — Submit Pendampingan Valid

1. Klik `Isi Contoh Valid` pada form pendampingan.
2. Pastikan periode Januari dan tanggal Januari.
3. Klik `Kirim Pendampingan ke Sheet`.

Harapan:

- response `ok: true`
- data masuk ke `staging_pendampingan_jan`

## Uji 4 — Duplikasi client_mutation_id

Klik tombol kirim kedua kali tanpa mengubah data.

Harapan:

- response `ok: false`
- status `duplicate`
- code `DUPLICATE_CLIENT_MUTATION_ID` atau duplicate unique key

## Uji 5 — Salah bulan

Set periode Februari tetapi tanggal Januari.

Harapan:

- frontend menolak sebelum kirim
- tidak ada baris baru di sheet
