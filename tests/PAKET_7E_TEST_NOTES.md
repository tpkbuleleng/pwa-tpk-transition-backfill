# Test Notes — Paket 7-E

Paket dianggap PASS jika:

1. Migration 13–15 sukses.
2. `refresh_master_reference_from_production()` sukses.
3. `check_master_reference_health()` berstatus `healthy` atau minimal `needs_review` dengan penyebab jelas.
4. `master_kecamatan`, `master_tim`, `master_kader`, `master_wilayah`, dan `scope_profile` berisi data dari production base.
5. `query_sasaran_lite()` dan `query_pendampingan_lite()` tetap berjalan setelah enrichment.
6. `get_production_basic_summary()` tetap mengembalikan total sasaran dan pendampingan.
7. Security Advisor tidak memunculkan error/warning kritikal baru.
