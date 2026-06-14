# PASS Criteria Paket 7-F

Paket 7-F PASS jika seluruh poin berikut terpenuhi:

```txt
1. query_sasaran_lite_7f() berhasil dipanggil.
2. query_pendampingan_lite_7f() berhasil dipanggil.
3. get_production_basic_summary_7f() berhasil dipanggil.
4. check_production_query_contract_health_7f() berhasil dipanggil.
5. query jenis_sasaran = BADUTA ditolak dengan ok=false.
6. query jenis_sasaran = BALITA diterima.
7. filter is_baduta_prioritas tersedia untuk sasaran.
8. filter is_baduta_prioritas_saat_pendampingan tersedia untuk pendampingan.
9. output summary memakai total_baduta_prioritas, bukan total_baduta.
10. Security Advisor tidak menampilkan warning critical baru.
```

Status yang diharapkan:

```txt
Paket 7-F — Production Query Contract & Frontend Readiness
Status: PASS LENGKAP / STABIL
```
