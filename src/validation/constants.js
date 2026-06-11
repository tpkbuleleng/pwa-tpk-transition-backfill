// src/validation/constants.js

export const JENIS_SASARAN = Object.freeze({
  CATIN: "CATIN",
  BUMIL: "BUMIL",
  BUFAS: "BUFAS",
  BADUTA: "BADUTA",
});

export const JENIS_KELAMIN = Object.freeze({
  LAKI_LAKI: "LAKI_LAKI",
  PEREMPUAN: "PEREMPUAN",
});

export const BACKFILL_CONFIG = Object.freeze({
  tahunLaporan: 2026,
  bulanAwal: 1,
  bulanAkhir: 6,
  maxLaporanPerKaderPerBulan: 10,
});

export const VALIDATION_STATUS = Object.freeze({
  VALID: "valid",
  INVALID: "invalid",
});

export const FIELD_GROUPS = Object.freeze({
  SASARAN_BASE_REQUIRED: [
    "client_mutation_id",
    "source_mode",
    "app_version",
    "id_kecamatan",
    "nama_kecamatan",
    "id_tim",
    "id_kader",
    "id_wilayah",
    "desa_kelurahan",
    "dusun_rw",
    "jenis_sasaran",
    "nama_sasaran",
    "jenis_kelamin",
    "tanggal_lahir",
  ],

  PENDAMPINGAN_BASE_REQUIRED: [
    "client_mutation_id",
    "source_mode",
    "app_version",
    "id_kecamatan",
    "nama_kecamatan",
    "id_tim",
    "id_kader",
    "id_wilayah",
    "jenis_sasaran",
    "periode_bulan",
    "tahun_laporan",
    "tanggal_pendampingan",
  ],
});
