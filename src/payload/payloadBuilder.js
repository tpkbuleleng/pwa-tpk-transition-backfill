// src/payload/payloadBuilder.js

import { APP_META, APP_MODE } from "../config/appConfig.js";
import { createClientMutationId } from "../utils/clientMutationId.js";
import {
  buildPendampinganUniqueKey,
  buildSasaranUniqueKey,
} from "../validation/index.js";

function cleanString(value) {
  return String(value ?? "").trim();
}

function toUpperValue(value) {
  return cleanString(value).toUpperCase();
}

function asNumberOrBlank(value) {
  const text = cleanString(value);
  if (!text) return "";
  const number = Number(text);
  return Number.isFinite(number) ? number : text;
}

function buildPendampinganSasaranUniqueKey(formData = {}) {
  const provided = cleanString(formData.sasaran_unique_key);
  if (provided) return provided;

  const nik = cleanString(formData.nik);
  const idTim = toUpperValue(formData.id_tim);

  if (/^\d{16}$/.test(nik) && idTim) {
    return `${nik}|${idTim}`;
  }

  return toUpperValue(formData.id_sasaran || formData.id_sasaran_temp);
}

export function buildSharedContextPayload(formData = {}) {
  return {
    source_mode: APP_MODE,
    app_version: APP_META.version,
    id_kecamatan: toUpperValue(formData.id_kecamatan),
    kode_kecamatan: toUpperValue(formData.kode_kecamatan || formData.id_kecamatan),
    nama_kecamatan: toUpperValue(formData.nama_kecamatan),
    id_tim: toUpperValue(formData.id_tim),
    id_kader: toUpperValue(formData.id_kader),
    id_wilayah: toUpperValue(formData.id_wilayah),
    desa_kelurahan: toUpperValue(formData.desa_kelurahan),
    dusun_rw: toUpperValue(formData.dusun_rw),
  };
}

export function buildSasaranPayload(formData = {}) {
  const payload = {
    client_mutation_id: cleanString(formData.client_mutation_id) || createClientMutationId("reg"),
    ...buildSharedContextPayload(formData),
    jenis_sasaran: toUpperValue(formData.jenis_sasaran),
    nama_sasaran: toUpperValue(formData.nama_sasaran),
    jenis_kelamin: toUpperValue(formData.jenis_kelamin),
    tanggal_lahir: cleanString(formData.tanggal_lahir),
    nik: cleanString(formData.nik),
    no_kk: cleanString(formData.no_kk),
    nama_ibu_kandung: toUpperValue(formData.nama_ibu_kandung),
    nama_pasangan: toUpperValue(formData.nama_pasangan),
    alamat_lengkap: cleanString(formData.alamat_lengkap),
    no_hp: cleanString(formData.no_hp),
    catatan_backfill: cleanString(formData.catatan_backfill),
  };

  const uniqueKey = buildSasaranUniqueKey(payload);

  return {
    ...payload,
    sasaran_unique_key: uniqueKey.unique_key,
    unique_key_strategy: uniqueKey.strategy,
    needs_review: uniqueKey.needs_review,
  };
}

export function buildPendampinganPayload(formData = {}) {
  const payload = {
    client_mutation_id: cleanString(formData.client_mutation_id) || createClientMutationId("pdg"),
    ...buildSharedContextPayload(formData),
    id_sasaran: toUpperValue(formData.id_sasaran),
    id_sasaran_temp: toUpperValue(formData.id_sasaran_temp),
    sasaran_unique_key: buildPendampinganSasaranUniqueKey(formData),
    jenis_sasaran: toUpperValue(formData.jenis_sasaran),
    nik: cleanString(formData.nik),
    nama_sasaran: toUpperValue(formData.nama_sasaran),
    periode_bulan: asNumberOrBlank(formData.periode_bulan),
    tahun_laporan: asNumberOrBlank(formData.tahun_laporan || "2026"),
    tanggal_pendampingan: cleanString(formData.tanggal_pendampingan),
    status_pendampingan: toUpperValue(formData.status_pendampingan),
    hasil_pendampingan: cleanString(formData.hasil_pendampingan),
    catatan_pendampingan: cleanString(formData.catatan_pendampingan),
  };

  const uniqueKey = buildPendampinganUniqueKey(payload);

  return {
    ...payload,
    pendampingan_unique_key: uniqueKey.unique_key,
    unique_key_strategy: uniqueKey.strategy,
    needs_review: uniqueKey.needs_review,
  };
}
