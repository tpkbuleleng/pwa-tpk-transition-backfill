// src/forms/formOptions.js

export const JENIS_SASARAN_OPTIONS = Object.freeze([
  { value: "BADUTA", label: "BADUTA" },
  { value: "BUMIL", label: "BUMIL" },
  { value: "BUFAS", label: "BUFAS" },
  { value: "CATIN", label: "CATIN" },
]);

export const JENIS_KELAMIN_OPTIONS = Object.freeze([
  { value: "LAKI_LAKI", label: "Laki-laki" },
  { value: "PEREMPUAN", label: "Perempuan" },
]);

export const BULAN_BACKFILL_OPTIONS = Object.freeze([
  { value: "1", label: "Januari" },
  { value: "2", label: "Februari" },
  { value: "3", label: "Maret" },
  { value: "4", label: "April" },
  { value: "5", label: "Mei" },
  { value: "6", label: "Juni" },
]);

export const STATUS_PENDAMPINGAN_OPTIONS = Object.freeze([
  { value: "KUNJUNGAN_RUMAH", label: "Kunjungan Rumah" },
  { value: "BKB_POSYANDU", label: "BKB / Posyandu" },
  { value: "LAINNYA", label: "Lainnya" },
]);
