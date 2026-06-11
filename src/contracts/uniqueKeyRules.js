// src/contracts/uniqueKeyRules.js

import { UNIQUE_KEY_STRATEGIES } from "./enums.js";

export function normalizeDigits(value = "") {
  return String(value || "").replace(/\D/g, "");
}

export function normalizeText(value = "") {
  return String(value || "")
    .trim()
    .toUpperCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^A-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

export function normalizeDate(value = "") {
  const raw = String(value || "").trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return raw;

  const date = new Date(raw);
  if (Number.isNaN(date.getTime())) return "UNKNOWN_DATE";

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function isValidNik(value = "") {
  return /^\d{16}$/.test(normalizeDigits(value));
}

export function buildSasaranUniqueKey(record = {}) {
  const idTim = normalizeText(record.id_tim || record.idTim);
  const nik = normalizeDigits(record.nik);

  if (nik && isValidNik(nik)) {
    return {
      sasaran_unique_key: `SAS|NIK|${nik}|TIM|${idTim}`,
      unique_key_strategy: UNIQUE_KEY_STRATEGIES.NIK_TIM,
      needs_review: false,
      review_reason: "",
    };
  }

  const nama = normalizeText(record.nama_sasaran || record.namaSasaran || record.nama);
  const tanggalLahir = normalizeDate(record.tanggal_lahir || record.tanggalLahir);
  const namaIbu = normalizeText(record.nama_ibu_kandung || record.namaIbuKandung || record.nama_ibu || "NO_IBU");

  return {
    sasaran_unique_key: `SAS|FB|${nama}|DOB|${tanggalLahir}|IBU|${namaIbu}|TIM|${idTim}`,
    unique_key_strategy: UNIQUE_KEY_STRATEGIES.FALLBACK_IDENTITY_TIM,
    needs_review: true,
    review_reason: "NIK kosong atau tidak valid; memakai fallback nama + tanggal_lahir + nama_ibu + id_tim.",
  };
}

export function normalizePeriodeYyyymm(record = {}) {
  if (record.periode_yyyymm) {
    const compact = String(record.periode_yyyymm).replace(/\D/g, "");
    if (/^\d{6}$/.test(compact)) return compact;
  }

  const year = Number(record.tahun_laporan || record.tahunLaporan);
  const month = Number(record.periode_bulan || record.periodeBulan);

  if (!Number.isInteger(year) || !Number.isInteger(month)) return "UNKNOWN_PERIOD";

  return `${year}${String(month).padStart(2, "0")}`;
}

export function buildPendampinganUniqueKey(record = {}) {
  const target = normalizeText(
    record.id_sasaran ||
      record.id_sasaran_temp ||
      record.sasaran_unique_key ||
      record.idSasaran ||
      record.idSasaranTemp
  );

  const periode = normalizePeriodeYyyymm(record);

  return {
    pendampingan_unique_key: `PDG|SAS|${target}|PERIODE|${periode}`,
    needs_review: target ? false : true,
    review_reason: target ? "" : "Tidak ada id_sasaran, id_sasaran_temp, atau sasaran_unique_key.",
  };
}
