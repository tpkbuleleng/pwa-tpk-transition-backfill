// src/contracts/dataDictionary/sasaranFields.js

import { FIELD_TYPES, FIELD_SCOPES } from "../fieldTypes.js";

export const SASARAN_FIELDS = Object.freeze([
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
  { name: "id_kader", label: "ID Kader", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID kader penginput." },
  { name: "nama_kader", label: "Nama Kader", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Nama kader penginput." },
  { name: "id_wilayah", label: "ID Wilayah", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "ID wilayah tugas yang valid untuk tim." },
  { name: "desa_kelurahan", label: "Desa/Kelurahan", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "Desa/kelurahan sasaran." },
  { name: "dusun_rw", label: "Dusun/RW", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.ALL, description: "Dusun/RW sasaran." },

  // Core identity fields
  { name: "jenis_sasaran", label: "Jenis Sasaran", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.SASARAN, description: "CATIN, BUMIL, BUFAS, BADUTA, atau PUS jika nanti diperlukan." },
  { name: "nik", label: "NIK", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "NIK 16 digit. Jika kosong/tidak valid, fallback unique key wajib needs_review." },
  { name: "no_kk", label: "Nomor KK", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Nomor KK 16 digit jika tersedia." },
  { name: "nama_sasaran", label: "Nama Sasaran", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.SASARAN, description: "Nama sasaran." },
  { name: "jenis_kelamin", label: "Jenis Kelamin", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.SASARAN, description: "L/P atau LAKI-LAKI/PEREMPUAN sesuai normalisasi Paket 3." },
  { name: "tanggal_lahir", label: "Tanggal Lahir", type: FIELD_TYPES.DATE, required: true, scope: FIELD_SCOPES.SASARAN, description: "Format ISO YYYY-MM-DD." },
  { name: "usia_bulan", label: "Usia Bulan", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.SASARAN, description: "Usia dalam bulan, terutama untuk BADUTA." },
  { name: "alamat_lengkap", label: "Alamat Lengkap", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Alamat naratif jika tersedia." },
  { name: "nama_kepala_keluarga", label: "Nama Kepala Keluarga", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Nama kepala keluarga." },
  { name: "nama_ibu_kandung", label: "Nama Ibu Kandung", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Wajib untuk BADUTA; dipakai fallback unique key jika NIK tidak valid." },

  // KRS / household risk fields
  { name: "status_krs", label: "Status KRS", type: FIELD_TYPES.ENUM, required: false, scope: FIELD_SCOPES.SASARAN, description: "Status KRS jika tersedia." },
  { name: "sumber_air_minum_utama", label: "Sumber Air Minum Utama", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Sumber air minum utama rumah tangga." },
  { name: "fasilitas_bab", label: "Fasilitas BAB", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Fasilitas BAB rumah tangga." },

  // CATIN-specific fields
  { name: "nik_pasangan", label: "NIK Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "NIK pasangan CATIN jika tersedia." },
  { name: "nama_pasangan", label: "Nama Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Nama pasangan CATIN." },
  { name: "kabupaten_pasangan", label: "Kabupaten Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Asal kabupaten pasangan." },
  { name: "kecamatan_pasangan", label: "Kecamatan Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Asal kecamatan pasangan." },
  { name: "desa_pasangan", label: "Desa Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Asal desa pasangan." },
  { name: "dusun_pasangan", label: "Dusun Pasangan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Asal dusun pasangan." },
  { name: "domisili_setelah_menikah", label: "Domisili Setelah Menikah", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.CATIN, description: "Rencana domisili setelah menikah." },

  // BUMIL-specific fields
  { name: "usia_kehamilan_minggu", label: "Usia Kehamilan Minggu", type: FIELD_TYPES.INTEGER, required: false, scope: FIELD_SCOPES.BUMIL, description: "Usia kehamilan dalam minggu." },
  { name: "bb_sebelum_hamil_kg", label: "BB Sebelum Hamil Kg", type: FIELD_TYPES.DECIMAL, required: false, scope: FIELD_SCOPES.BUMIL, description: "Berat badan sebelum hamil dalam kilogram." },
  { name: "kehamilan_diinginkan", label: "Kehamilan Diinginkan", type: FIELD_TYPES.ENUM, required: false, scope: FIELD_SCOPES.BUMIL, description: "Status kehamilan diinginkan sesuai opsi form." },

  // BUFAS/BADUTA fields
  { name: "tanggal_melahirkan", label: "Tanggal Melahirkan", type: FIELD_TYPES.DATE, required: false, scope: FIELD_SCOPES.BUFAS, description: "Tanggal melahirkan untuk BUFAS jika tersedia." },
  { name: "jenis_persalinan", label: "Jenis Persalinan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.BUFAS, description: "Jenis persalinan jika tersedia." },
  { name: "bb_lahir_kg", label: "BB Lahir Kg", type: FIELD_TYPES.DECIMAL, required: false, scope: FIELD_SCOPES.BADUTA, description: "Berat badan lahir dalam kilogram." },
  { name: "pb_lahir_cm", label: "PB Lahir Cm", type: FIELD_TYPES.DECIMAL, required: false, scope: FIELD_SCOPES.BADUTA, description: "Panjang badan lahir dalam sentimeter." },

  // Form and payload fields
  { name: "form_id", label: "Form ID", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "ID form registrasi yang dipakai." },
  { name: "form_version", label: "Form Version", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Versi form registrasi." },
  { name: "sasaran_unique_key", label: "Sasaran Unique Key", type: FIELD_TYPES.TEXT, required: true, scope: FIELD_SCOPES.SASARAN, description: "Unique key sasaran lintas provider." },
  { name: "unique_key_strategy", label: "Unique Key Strategy", type: FIELD_TYPES.ENUM, required: true, scope: FIELD_SCOPES.SASARAN, description: "NIK_TIM atau FALLBACK_IDENTITY_TIM." },
  { name: "needs_review", label: "Needs Review", type: FIELD_TYPES.BOOLEAN, required: true, scope: FIELD_SCOPES.SASARAN, description: "TRUE jika data perlu ditinjau saat import staging." },
  { name: "review_reason", label: "Review Reason", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.SASARAN, description: "Alasan data perlu review." },
  { name: "form_answers_json", label: "Form Answers JSON", type: FIELD_TYPES.JSON, required: false, scope: FIELD_SCOPES.SASARAN, description: "Jawaban dinamis form dalam JSON." },
  { name: "raw_payload_json", label: "Raw Payload JSON", type: FIELD_TYPES.JSON, required: false, scope: FIELD_SCOPES.AUDIT, description: "Payload mentah sebagai jejak audit staging." },

  // Timestamps and soft-delete
  { name: "created_at_client", label: "Created At Client", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu dibuat di perangkat client." },
  { name: "submitted_at_server", label: "Submitted At Server", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu diterima backend provider." },
  { name: "created_by", label: "Created By", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.AUDIT, description: "User/kader pembuat data." },
  { name: "updated_at", label: "Updated At", type: FIELD_TYPES.TIMESTAMP, required: false, scope: FIELD_SCOPES.AUDIT, description: "Waktu update terakhir." },
  { name: "is_deleted", label: "Is Deleted", type: FIELD_TYPES.BOOLEAN, required: false, scope: FIELD_SCOPES.AUDIT, description: "Soft delete flag; default FALSE." },
  { name: "catatan", label: "Catatan", type: FIELD_TYPES.TEXT, required: false, scope: FIELD_SCOPES.ALL, description: "Catatan tambahan." },
]);
