# CSV Contract 7-E-R1 — Taxonomy Version

Contract version:

```txt
CSV_CONTRACT_TPK_BACKFILL_2026_7E_R1
```

Taxonomy version:

```txt
TPK_TAXONOMY_2026_7E_R1
```

## Sasaran — field resmi

Kolom taxonomy sasaran:

```txt
jenis_sasaran
usia_bulan
is_baduta_prioritas
kelompok_umur_balita
taxonomy_version
```

Allowed `jenis_sasaran`:

```txt
CATIN
BUMIL
BUFAS
BALITA
```

Not allowed sebagai input baru:

```txt
BADUTA
```

## Pendampingan — field resmi

Kolom taxonomy pendampingan:

```txt
jenis_sasaran
tanggal_lahir
tanggal_pendampingan
usia_bulan_saat_pendampingan
is_baduta_prioritas_saat_pendampingan
kelompok_umur_saat_pendampingan
taxonomy_version
```

Catatan penting:

```txt
is_baduta_prioritas_saat_pendampingan dihitung dari tanggal_pendampingan - tanggal_lahir.
```

## Nilai kelompok umur

```txt
BADUTA_0_23
BALITA_24_59
NON_BALITA
null
```

Aturan:

```txt
BADUTA_0_23   => jenis_sasaran BALITA dan usia 0–23 bulan
BALITA_24_59  => jenis_sasaran BALITA dan usia 24–59 bulan
NON_BALITA    => jenis_sasaran BALITA tetapi usia >59 bulan; harus ditolak validasi sasaran
null          => CATIN/BUMIL/BUFAS atau data belum lengkap
```

## Dampak pada export CSV

Paket 6 perlu menaikkan metadata export:

```txt
csv_contract_version = CSV_CONTRACT_TPK_BACKFILL_2026_7E_R1
taxonomy_version = TPK_TAXONOMY_2026_7E_R1
```

Selective CSV Export tetap dapat dibuat sebagai Paket 6-R1 terpisah.
