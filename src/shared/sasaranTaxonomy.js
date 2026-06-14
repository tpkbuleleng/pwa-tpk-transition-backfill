/*
 * PWA TPK Kabupaten Buleleng
 * Paket 7-E-R1 — Sasaran Taxonomy Realignment
 * BADUTA to BALITA + Baduta Priority
 *
 * File baru, aman ditambahkan.
 * Tidak memanggil Apps Script/Supabase langsung.
 * Dipakai oleh Shared Validation Layer, Payload Builder, dan UI badge.
 */
(function attachSasaranTaxonomy(root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory();
  } else {
    root.SasaranTaxonomy7ER1 = factory();
  }
})(typeof self !== 'undefined' ? self : this, function createSasaranTaxonomy() {
  'use strict';

  const TAXONOMY_VERSION = 'TPK_TAXONOMY_2026_7E_R1';

  const OFFICIAL_JENIS_SASARAN = Object.freeze([
    'CATIN',
    'BUMIL',
    'BUFAS',
    'BALITA'
  ]);

  const LEGACY_JENIS_SASARAN = Object.freeze([
    'BADUTA'
  ]);

  const KELOMPOK_UMUR_BALITA = Object.freeze({
    BADUTA_0_23: 'BADUTA_0_23',
    BALITA_24_59: 'BALITA_24_59',
    NON_BALITA: 'NON_BALITA'
  });

  function normalizeText(value) {
    return String(value == null ? '' : value).trim();
  }

  function normalizeJenisSasaran(value) {
    return normalizeText(value).toUpperCase();
  }

  function isOfficialJenisSasaran(value) {
    return OFFICIAL_JENIS_SASARAN.includes(normalizeJenisSasaran(value));
  }

  function isLegacyBadutaJenisSasaran(value) {
    return normalizeJenisSasaran(value) === 'BADUTA';
  }

  function parseDateOnly(value) {
    if (!value) return null;

    if (value instanceof Date) {
      if (Number.isNaN(value.getTime())) return null;
      return new Date(value.getFullYear(), value.getMonth(), value.getDate());
    }

    const text = normalizeText(value);
    const match = text.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!match) return null;

    const year = Number(match[1]);
    const monthIndex = Number(match[2]) - 1;
    const day = Number(match[3]);
    const date = new Date(year, monthIndex, day);

    if (
      date.getFullYear() !== year ||
      date.getMonth() !== monthIndex ||
      date.getDate() !== day
    ) {
      return null;
    }

    return date;
  }

  function formatDateOnly(date) {
    if (!(date instanceof Date) || Number.isNaN(date.getTime())) return '';
    const yyyy = String(date.getFullYear());
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const dd = String(date.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
  }

  function todayDateOnly() {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), now.getDate());
  }

  /**
   * Menghitung umur bulan selesai penuh.
   * Contoh:
   * - lahir 2026-01-31, anchor 2026-02-28 => 0 bulan
   * - lahir 2026-01-15, anchor 2026-02-15 => 1 bulan
   */
  function calculateCompletedMonths(tanggalLahir, anchorDate) {
    const birth = parseDateOnly(tanggalLahir);
    const anchor = parseDateOnly(anchorDate);

    if (!birth || !anchor) return null;
    if (birth > anchor) return null;

    let months = (anchor.getFullYear() - birth.getFullYear()) * 12;
    months += anchor.getMonth() - birth.getMonth();

    if (anchor.getDate() < birth.getDate()) {
      months -= 1;
    }

    return months < 0 ? null : months;
  }

  function resolveSasaranAnchorDate(payload, options) {
    const opt = options || {};
    return (
      opt.anchorDate ||
      payload.tanggal_registrasi ||
      payload.tanggal_import ||
      payload.created_at ||
      payload.created_date ||
      formatDateOnly(todayDateOnly())
    );
  }

  function deriveKelompokUmurBalita(jenisSasaran, usiaBulan) {
    const jenis = normalizeJenisSasaran(jenisSasaran);

    if (jenis !== 'BALITA') return null;
    if (typeof usiaBulan !== 'number' || !Number.isFinite(usiaBulan)) return null;
    if (usiaBulan < 0) return null;
    if (usiaBulan <= 23) return KELOMPOK_UMUR_BALITA.BADUTA_0_23;
    if (usiaBulan <= 59) return KELOMPOK_UMUR_BALITA.BALITA_24_59;
    return KELOMPOK_UMUR_BALITA.NON_BALITA;
  }

  function deriveSasaranTaxonomy(payload, options) {
    const data = payload || {};
    const jenis = normalizeJenisSasaran(data.jenis_sasaran);
    const anchorDate = resolveSasaranAnchorDate(data, options);
    const usiaBulan = jenis === 'BALITA'
      ? calculateCompletedMonths(data.tanggal_lahir, anchorDate)
      : null;
    const kelompokUmurBalita = deriveKelompokUmurBalita(jenis, usiaBulan);

    return {
      taxonomy_version: TAXONOMY_VERSION,
      jenis_sasaran: jenis,
      usia_bulan: usiaBulan,
      is_baduta_prioritas: jenis === 'BALITA' && usiaBulan != null && usiaBulan >= 0 && usiaBulan <= 23,
      kelompok_umur_balita: kelompokUmurBalita,
      taxonomy_anchor_date: formatDateOnly(parseDateOnly(anchorDate))
    };
  }

  function derivePendampinganTaxonomy(payload) {
    const data = payload || {};
    const jenis = normalizeJenisSasaran(data.jenis_sasaran);
    const usiaBulanSaatPendampingan = jenis === 'BALITA'
      ? calculateCompletedMonths(data.tanggal_lahir, data.tanggal_pendampingan)
      : null;
    const kelompokUmurSaatPendampingan = deriveKelompokUmurBalita(
      jenis,
      usiaBulanSaatPendampingan
    );

    return {
      taxonomy_version: TAXONOMY_VERSION,
      jenis_sasaran: jenis,
      usia_bulan_saat_pendampingan: usiaBulanSaatPendampingan,
      is_baduta_prioritas_saat_pendampingan:
        jenis === 'BALITA' &&
        usiaBulanSaatPendampingan != null &&
        usiaBulanSaatPendampingan >= 0 &&
        usiaBulanSaatPendampingan <= 23,
      kelompok_umur_saat_pendampingan: kelompokUmurSaatPendampingan,
      taxonomy_anchor_date: formatDateOnly(parseDateOnly(data.tanggal_pendampingan))
    };
  }

  function validateJenisSasaranOfficial(value) {
    const jenis = normalizeJenisSasaran(value);
    const errors = [];

    if (!jenis) {
      errors.push({ field: 'jenis_sasaran', code: 'JENIS_SASARAN_REQUIRED', message: 'Jenis sasaran wajib diisi.' });
    } else if (jenis === 'BADUTA') {
      errors.push({ field: 'jenis_sasaran', code: 'BADUTA_LEGACY_NOT_ALLOWED', message: 'BADUTA tidak lagi dipakai sebagai jenis sasaran. Gunakan BALITA; status Baduta Prioritas dihitung otomatis dari umur 0–23 bulan.' });
    } else if (!OFFICIAL_JENIS_SASARAN.includes(jenis)) {
      errors.push({ field: 'jenis_sasaran', code: 'JENIS_SASARAN_NOT_ALLOWED', message: `Jenis sasaran tidak valid: ${jenis}.` });
    }

    return { ok: errors.length === 0, jenis_sasaran: jenis, errors };
  }

  function validateSasaranTaxonomy(payload, options) {
    const data = payload || {};
    const jenisCheck = validateJenisSasaranOfficial(data.jenis_sasaran);
    const errors = jenisCheck.errors.slice();
    const derived = deriveSasaranTaxonomy(data, options);

    if (jenisCheck.jenis_sasaran === 'BALITA') {
      if (!data.tanggal_lahir) {
        errors.push({ field: 'tanggal_lahir', code: 'BALITA_TANGGAL_LAHIR_REQUIRED', message: 'Tanggal lahir wajib diisi untuk sasaran BALITA.' });
      } else if (derived.usia_bulan == null) {
        errors.push({ field: 'tanggal_lahir', code: 'BALITA_AGE_INVALID', message: 'Tanggal lahir BALITA tidak valid atau melebihi tanggal acuan.' });
      } else if (derived.usia_bulan > 59) {
        errors.push({ field: 'tanggal_lahir', code: 'BALITA_MAX_59_MONTHS', message: 'Sasaran BALITA maksimal berusia 59 bulan pada tanggal registrasi/import.' });
      }
    }

    return {
      ok: errors.length === 0,
      errors,
      derived
    };
  }

  function validatePendampinganTaxonomy(payload) {
    const data = payload || {};
    const jenisCheck = validateJenisSasaranOfficial(data.jenis_sasaran);
    const errors = jenisCheck.errors.slice();
    const derived = derivePendampinganTaxonomy(data);

    if (jenisCheck.jenis_sasaran === 'BALITA') {
      if (!data.tanggal_lahir) {
        errors.push({ field: 'tanggal_lahir', code: 'BALITA_TANGGAL_LAHIR_REQUIRED_FOR_PENDAMPINGAN', message: 'Tanggal lahir sasaran BALITA wajib tersedia untuk menghitung prioritas saat pendampingan.' });
      }

      if (!data.tanggal_pendampingan) {
        errors.push({ field: 'tanggal_pendampingan', code: 'TANGGAL_PENDAMPINGAN_REQUIRED_FOR_BALITA_PRIORITY', message: 'Tanggal pendampingan wajib tersedia untuk menghitung Baduta Prioritas historis.' });
      }

      if (data.tanggal_lahir && data.tanggal_pendampingan && derived.usia_bulan_saat_pendampingan == null) {
        errors.push({ field: 'tanggal_lahir', code: 'BALITA_AGE_AT_PENDAMPINGAN_INVALID', message: 'Tanggal lahir atau tanggal pendampingan tidak valid untuk perhitungan umur BALITA.' });
      }
    }

    return {
      ok: errors.length === 0,
      errors,
      derived
    };
  }

  function decorateSasaranPayload(payload, options) {
    const data = Object.assign({}, payload || {});
    const derived = deriveSasaranTaxonomy(data, options);

    data.jenis_sasaran = derived.jenis_sasaran;
    data.usia_bulan = derived.usia_bulan;
    data.is_baduta_prioritas = derived.is_baduta_prioritas;
    data.kelompok_umur_balita = derived.kelompok_umur_balita;
    data.taxonomy_version = derived.taxonomy_version;

    return data;
  }

  function decoratePendampinganPayload(payload) {
    const data = Object.assign({}, payload || {});
    const derived = derivePendampinganTaxonomy(data);

    data.jenis_sasaran = derived.jenis_sasaran;
    data.usia_bulan_saat_pendampingan = derived.usia_bulan_saat_pendampingan;
    data.is_baduta_prioritas_saat_pendampingan = derived.is_baduta_prioritas_saat_pendampingan;
    data.kelompok_umur_saat_pendampingan = derived.kelompok_umur_saat_pendampingan;
    data.taxonomy_version = derived.taxonomy_version;

    return data;
  }

  return Object.freeze({
    TAXONOMY_VERSION,
    OFFICIAL_JENIS_SASARAN,
    LEGACY_JENIS_SASARAN,
    KELOMPOK_UMUR_BALITA,
    normalizeJenisSasaran,
    isOfficialJenisSasaran,
    isLegacyBadutaJenisSasaran,
    parseDateOnly,
    formatDateOnly,
    calculateCompletedMonths,
    deriveKelompokUmurBalita,
    deriveSasaranTaxonomy,
    derivePendampinganTaxonomy,
    validateJenisSasaranOfficial,
    validateSasaranTaxonomy,
    validatePendampinganTaxonomy,
    decorateSasaranPayload,
    decoratePendampinganPayload
  });
});
