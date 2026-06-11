// src/contracts/dataDictionary/pendampinganFields.js

import { FIELD_TYPES, FIELD_SCOPES } from "../fieldTypes.js";

export const PENDAMPINGAN_FIELDS = Object.freeze([
  // System, import, and audit fields
  { name: "record_id", label: "Record ID staging", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.AUDIT, description: "ID staging sementara dari backend/provider." },
  { name: "client_mutation_id", label: "Client Mutation ID", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.AUDIT, description: "ID unik dari client untuk idempotensi submit." },
  { name: "source_mode", label: "Source Mode", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.AUDIT, description: "BACKFILL atau PRODUCTION." },
  { name: "app_version", label: "App Version", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.AUDIT, description: "Versi frontend saat data dikirim." },
  { name: "import_batch_id", label: "Import Batch ID", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.IMPORT, description: "Diisi saat CSV masuk ke Supabase staging." },

  // Scope and actor fields
  { name: "id_kecamatan", label: "ID Kecamatan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID/kode kecamatan internal." },
  { name: "kode_kecamatan", label: "Kode Kecamatan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Kode singkat kecamatan, contoh TJK." },
  { name: "nama_kecamatan", label: "Nama Kecamatan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "Nama kecamatan." },
  { name: "id_tim", label: "ID Tim", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID tim TPK." },
  { name: "nomor_tim", label: "Nomor Tim", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Nomor tim jika tersedia." },
  { name: "nama_tim", label: "Nama Tim", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Nama tim jika tersedia." },
  { name: "id_kader", label: "ID Kader", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID kader pelapor." },
  { name: "nama_kader", label: "Nama Kader", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Nama kader pelapor." },
  { name: "id_wilayah", label: "ID Wilayah", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID wilayah tugas." },
  { name: "desa_kelurahan", label: "Desa/Kelurahan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "Desa/kelurahan sasaran." },
  { name: "dusun_rw", label: "Dusun/RW", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "Dusun/RW sasaran." },

  // Sasaran reference fields
  { name: "id_sasaran", label: "ID Sasaran Production", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "ID sasaran resmi jika sudah tersedia." },
  { name: "id_sasaran_temp", label: "ID Sasaran Temp", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "ID sasaran sementara saat backfill." },
  { name: "sasaran_unique_key", label: "Sasaran Unique Key", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Unique key sasaran untuk matching saat import." },
  { name: "jenis_sasaran", label: "Jenis Sasaran", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "CATIN, BUMIL, BUFAS, BADUTA, atau PUS jika nanti diperlukan." },
  { name: "nik", label: "NIK", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "NIK sasaran jika tersedia." },
  { name: "nama_sasaran", label: "Nama Sasaran", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Nama sasaran untuk audit/matching manual." },

  // Period and visit fields
  { name: "periode_bulan", label: "Periode Bulan", type: FIELD_TYPES.INTEGER, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Bulan laporan 1 sampai 6 untuk BACKFILL." },
  { name: "tahun_laporan", label: "Tahun Laporan", type: FIELD_TYPES.INTEGER, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Tahun laporan, contoh 2026." },
  { name: "periode_yyyymm", label: "Periode YYYYMM", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Periode normalisasi, contoh 202601." },
  { name: "tanggal_pendampingan", label: "Tanggal Pendampingan", type: FIELD_TYPES.DATE, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Tanggal pendampingan; harus berada pada bulan laporan." },
  { name: "metode_pendampingan", label: "Metode Pendampingan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Contoh: Kunjungan Rumah, BKB/Posyandu, atau kanal lain sesuai form." },
  { name: "status_pendampingan", label: "Status Pendampingan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Status akhir pendampingan." },
  { name: "hasil_pendampingan", label: "Hasil Pendampingan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Ringkasan hasil pendampingan jika tersedia." },
  { name: "catatan_pendampingan", label: "Catatan Pendampingan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Catatan naratif pendampingan." },
  { name: "rujukan_diperlukan", label: "Rujukan Diperlukan", type: FIELD_TYPES.BOOLEAN, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "TRUE jika perlu rujukan." },
  { name: "jenis_rujukan", label: "Jenis Rujukan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Jenis rujukan jika diperlukan." },

  // Form and payload fields
  { name: "form_id", label: "Form ID", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "ID form pendampingan yang dipakai." },
  { name: "form_version", label: "Form Version", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Versi form pendampingan." },
  { name: "pendampingan_unique_key", label: "Pendampingan Unique Key", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Unique key pendampingan per sasaran per bulan." },
  { name: "form_answers_json", label: "Form Answers JSON", type: FIELD_TYPES.JSON, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Jawaban dinamis form pendampingan dalam JSON." },
  { name: "raw_payload_json", label: "Raw Payload JSON", type: FIELD_TYPES.JSON, required: false, scope: FIELD_SCOPES.AUDIT, description: "Payload mentah sebagai jejak audit staging." },
  { name: "needs_review", label: "Needs Review", type: FIELD_TYPES.BOOLEAN, required: true, scope: FIELD_SCOPES.PENDAMPINGAN, description: "TRUE jika pendampingan perlu ditinjau saat import staging." },
  { name: "review_reason", label: "Review Reason", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.PENDAMPINGAN, description: "Alasan pendampingan perlu review." },

  // Timestamps and soft-delete
  { name: "created_at_client", label: "Created At Client", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu dibuat di perangkat client." },
  { name: "submitted_at_server", label: "Submitted At Server", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu diterima backend provider." },
  { name: "created_by", label: "Created By", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.AUDIT, description: "User/kader pembuat data." },
  { name: "updated_at", label: "Updated At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu update terakhir." },
  { name: "is_deleted", label: "Is Deleted", type: FIELD_TYPES.BOOLEAN, required: false, scope: FIELD_SCOPES.AUDIT, description: "Soft delete flag; default FALSE." },
  { name: "catatan", label: "Catatan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Catatan tambahan." },
]);
