# Paket 2 — Data Dictionary & CSV Contract

Versi kontrak: `csv-contract-p2-20260612-r1`

Dokumen ini mengunci struktur data minimum untuk mode transisi:

- BACKFILL = Apps Script + Google Sheet staging
- PRODUCTION = Supabase + GitHub Pages

Prinsip utama: UI, form, validasi, payload, header CSV, dan unique key harus sama lintas provider. Yang berbeda hanya backend provider.

---

## 1. Kontrak Google Sheet BACKFILL

Setiap workbook kecamatan minimal memiliki sheet:

```txt
staging_sasaran
staging_pendampingan_jan
staging_pendampingan_feb
staging_pendampingan_mar
staging_pendampingan_apr
staging_pendampingan_mei
staging_pendampingan_jun
import_error
export_log
```

Header `staging_pendampingan_jan` sampai `staging_pendampingan_jun` harus sama. Bulan dibedakan oleh sheet dan field `periode_bulan`.

---

## 2. Kontrak Supabase Staging

CSV dari Google Sheet tidak langsung masuk tabel production. CSV masuk ke tabel staging:

```txt
staging_sasaran_import
staging_pendampingan_import
import_batch
import_error
```

Promote ke production baru dilakukan setelah validasi SQL/RPC.

---

## 3. Strategi Kolom

Kontrak memakai strategi hybrid:

1. kolom normalisasi utama untuk pencarian, deduplikasi, audit, dan import;
2. `form_answers_json` untuk jawaban dinamis form;
3. `raw_payload_json` untuk payload mentah dari client/provider.

Strategi ini menjaga CSV tetap stabil walaupun pertanyaan form berkembang.

---

## 4. Unique Key Sasaran

Prioritas utama:

```txt
SAS|NIK|{nik_16_digit}|TIM|{id_tim}
```

Jika NIK kosong/tidak valid, gunakan fallback:

```txt
SAS|FB|{nama_sasaran}|DOB|{tanggal_lahir}|IBU|{nama_ibu_kandung}|TIM|{id_tim}
```

Jika fallback dipakai:

```txt
unique_key_strategy = FALLBACK_IDENTITY_TIM
needs_review = TRUE
```

---

## 5. Unique Key Pendampingan

Jika satu sasaran hanya boleh satu pendampingan per bulan:

```txt
PDG|SAS|{id_sasaran/id_sasaran_temp/sasaran_unique_key}|PERIODE|{YYYYMM}
```

Contoh:

```txt
PDG|SAS|SAS_NIK_5108010101010001_TIM_TIM_TJK_001|PERIODE|202601
```

---

## 6. Field Penting yang Wajib Dipertahankan

### Sasaran

Minimal wajib:

```txt
client_mutation_id
source_mode
app_version
id_kecamatan
nama_kecamatan
id_tim
id_kader
id_wilayah
desa_kelurahan
dusun_rw
jenis_sasaran
nama_sasaran
jenis_kelamin
tanggal_lahir
sasaran_unique_key
unique_key_strategy
needs_review
```

### Pendampingan

Minimal wajib:

```txt
client_mutation_id
source_mode
app_version
id_kecamatan
nama_kecamatan
id_tim
id_kader
id_wilayah
desa_kelurahan
dusun_rw
sasaran_unique_key
jenis_sasaran
nama_sasaran
periode_bulan
tahun_laporan
periode_yyyymm
tanggal_pendampingan
pendampingan_unique_key
needs_review
```

---

## 7. File Kontrak di Repository

File kontrak utama:

```txt
src/contracts/fieldTypes.js
src/contracts/enums.js
src/contracts/csvHeaders.js
src/contracts/uniqueKeyRules.js
src/contracts/contractCheck.js
src/contracts/dataDictionary/sasaranFields.js
src/contracts/dataDictionary/pendampinganFields.js
src/contracts/dataDictionary/importFields.js
```

Template header CSV:

```txt
templates/csv/staging_sasaran_header.csv
templates/csv/staging_pendampingan_header.csv
templates/csv/import_batch_header.csv
templates/csv/import_error_header.csv
templates/csv/export_log_header.csv
```

Apps Script helper untuk membuat header sheet:

```txt
apps-script/BackfillHeaderContract.gs
```

---

## 8. Batas Paket 2

Paket 2 belum melakukan:

- submit registrasi;
- submit pendampingan;
- validasi NIK/KK detail;
- append ke Google Sheet;
- export CSV otomatis;
- import ke Supabase.

Itu masuk Paket 3, Paket 5, Paket 6, dan Paket 7.
