# Supabase Production Read Model & Basic Query Layer

## Prinsip

Read model dibuat agar frontend production nanti tidak membaca tabel utama mentah secara langsung. Pada Paket 7-D, read model masih dipakai untuk uji SQL dan validasi struktur data production base.

## Read Model

### `v_sasaran_lite`

Berisi identitas sasaran dan ringkasan pendampingan:

- `total_pendampingan`
- `pendampingan_jan` sampai `pendampingan_jun`
- `last_tanggal_pendampingan`
- `last_status_pendampingan`
- `sudah_pernah_didampingi`

### `v_pendampingan_lite`

Berisi riwayat pendampingan dan identitas parent sasaran:

- `pendampingan_unique_key`
- `sasaran_unique_key`
- `parent_nama_sasaran`
- `parent_status_sasaran`

### `v_summary_tim_basic`

Ringkasan per tim:

- total sasaran
- total per jenis sasaran
- total pendampingan Januari–Juni

### `v_summary_kecamatan_basic`

Agregasi dari summary tim ke level kecamatan.

## Basic Query Functions

- `query_sasaran_lite(...)`
- `query_pendampingan_lite(...)`
- `get_production_basic_summary(...)`
- `check_production_read_model_health()`

Semua function masih tertutup dari `anon` dan `authenticated`.
