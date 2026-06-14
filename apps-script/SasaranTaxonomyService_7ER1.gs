/**
 * PWA TPK Kabupaten Buleleng
 * Paket 7-E-R1 — Sasaran Taxonomy Realignment
 * BADUTA to BALITA + Baduta Priority
 *
 * File baru, aman ditambahkan pada project Apps Script pusat: TPK Backfill.
 * Tidak perlu menimpa Code.gs.
 * Panggil helper ini dari validasi append sasaran/pendampingan yang sudah ada.
 */

var TPK_TAXONOMY_VERSION_7ER1 = 'TPK_TAXONOMY_2026_7E_R1';

function getOfficialJenisSasaran_7ER1() {
  return ['CATIN', 'BUMIL', 'BUFAS', 'BALITA'];
}

function getLegacyJenisSasaran_7ER1() {
  return ['BADUTA'];
}

function normalizeText_7ER1(value) {
  return String(value == null ? '' : value).trim();
}

function normalizeJenisSasaran_7ER1(value) {
  return normalizeText_7ER1(value).toUpperCase();
}

function parseDateOnly_7ER1(value) {
  if (!value) return null;

  if (Object.prototype.toString.call(value) === '[object Date]') {
    if (isNaN(value.getTime())) return null;
    return new Date(value.getFullYear(), value.getMonth(), value.getDate());
  }

  var text = normalizeText_7ER1(value);
  var match = text.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) return null;

  var year = Number(match[1]);
  var monthIndex = Number(match[2]) - 1;
  var day = Number(match[3]);
  var date = new Date(year, monthIndex, day);

  if (
    date.getFullYear() !== year ||
    date.getMonth() !== monthIndex ||
    date.getDate() !== day
  ) {
    return null;
  }

  return date;
}

function formatDateOnly_7ER1(date) {
  if (!date || Object.prototype.toString.call(date) !== '[object Date]' || isNaN(date.getTime())) return '';
  var yyyy = String(date.getFullYear());
  var mm = String(date.getMonth() + 1);
  var dd = String(date.getDate());
  if (mm.length < 2) mm = '0' + mm;
  if (dd.length < 2) dd = '0' + dd;
  return yyyy + '-' + mm + '-' + dd;
}

function todayDateOnly_7ER1() {
  var now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function calculateCompletedMonths_7ER1(tanggalLahir, anchorDate) {
  var birth = parseDateOnly_7ER1(tanggalLahir);
  var anchor = parseDateOnly_7ER1(anchorDate);

  if (!birth || !anchor) return null;
  if (birth.getTime() > anchor.getTime()) return null;

  var months = (anchor.getFullYear() - birth.getFullYear()) * 12;
  months += anchor.getMonth() - birth.getMonth();

  if (anchor.getDate() < birth.getDate()) {
    months -= 1;
  }

  return months < 0 ? null : months;
}

function deriveKelompokUmurBalita_7ER1(jenisSasaran, usiaBulan) {
  var jenis = normalizeJenisSasaran_7ER1(jenisSasaran);
  if (jenis !== 'BALITA') return null;
  if (typeof usiaBulan !== 'number' || !isFinite(usiaBulan)) return null;
  if (usiaBulan < 0) return null;
  if (usiaBulan <= 23) return 'BADUTA_0_23';
  if (usiaBulan <= 59) return 'BALITA_24_59';
  return 'NON_BALITA';
}

function resolveSasaranAnchorDate_7ER1(payload, options) {
  var data = payload || {};
  var opt = options || {};
  return (
    opt.anchorDate ||
    data.tanggal_registrasi ||
    data.tanggal_import ||
    data.created_at ||
    data.created_date ||
    formatDateOnly_7ER1(todayDateOnly_7ER1())
  );
}

function deriveSasaranTaxonomy_7ER1(payload, options) {
  var data = payload || {};
  var jenis = normalizeJenisSasaran_7ER1(data.jenis_sasaran);
  var anchorDate = resolveSasaranAnchorDate_7ER1(data, options);
  var usiaBulan = jenis === 'BALITA'
    ? calculateCompletedMonths_7ER1(data.tanggal_lahir, anchorDate)
    : null;
  var kelompokUmur = deriveKelompokUmurBalita_7ER1(jenis, usiaBulan);

  return {
    taxonomy_version: TPK_TAXONOMY_VERSION_7ER1,
    jenis_sasaran: jenis,
    usia_bulan: usiaBulan,
    is_baduta_prioritas: jenis === 'BALITA' && usiaBulan !== null && usiaBulan >= 0 && usiaBulan <= 23,
    kelompok_umur_balita: kelompokUmur,
    taxonomy_anchor_date: formatDateOnly_7ER1(parseDateOnly_7ER1(anchorDate))
  };
}

function derivePendampinganTaxonomy_7ER1(payload) {
  var data = payload || {};
  var jenis = normalizeJenisSasaran_7ER1(data.jenis_sasaran);
  var usiaBulan = jenis === 'BALITA'
    ? calculateCompletedMonths_7ER1(data.tanggal_lahir, data.tanggal_pendampingan)
    : null;
  var kelompokUmur = deriveKelompokUmurBalita_7ER1(jenis, usiaBulan);

  return {
    taxonomy_version: TPK_TAXONOMY_VERSION_7ER1,
    jenis_sasaran: jenis,
    usia_bulan_saat_pendampingan: usiaBulan,
    is_baduta_prioritas_saat_pendampingan: jenis === 'BALITA' && usiaBulan !== null && usiaBulan >= 0 && usiaBulan <= 23,
    kelompok_umur_saat_pendampingan: kelompokUmur,
    taxonomy_anchor_date: formatDateOnly_7ER1(parseDateOnly_7ER1(data.tanggal_pendampingan))
  };
}

function validateJenisSasaranOfficial_7ER1(value) {
  var jenis = normalizeJenisSasaran_7ER1(value);
  var official = getOfficialJenisSasaran_7ER1();
  var errors = [];

  if (!jenis) {
    errors.push({ field: 'jenis_sasaran', code: 'JENIS_SASARAN_REQUIRED', message: 'Jenis sasaran wajib diisi.' });
  } else if (jenis === 'BADUTA') {
    errors.push({ field: 'jenis_sasaran', code: 'BADUTA_LEGACY_NOT_ALLOWED', message: 'BADUTA tidak lagi dipakai sebagai jenis sasaran. Gunakan BALITA; status Baduta Prioritas dihitung otomatis dari umur 0–23 bulan.' });
  } else if (official.indexOf(jenis) === -1) {
    errors.push({ field: 'jenis_sasaran', code: 'JENIS_SASARAN_NOT_ALLOWED', message: 'Jenis sasaran tidak valid: ' + jenis + '.' });
  }

  return { ok: errors.length === 0, jenis_sasaran: jenis, errors: errors };
}

function validateSasaranTaxonomy_7ER1(payload, options) {
  var data = payload || {};
  var jenisCheck = validateJenisSasaranOfficial_7ER1(data.jenis_sasaran);
  var errors = jenisCheck.errors.slice();
  var derived = deriveSasaranTaxonomy_7ER1(data, options);

  if (jenisCheck.jenis_sasaran === 'BALITA') {
    if (!data.tanggal_lahir) {
      errors.push({ field: 'tanggal_lahir', code: 'BALITA_TANGGAL_LAHIR_REQUIRED', message: 'Tanggal lahir wajib diisi untuk sasaran BALITA.' });
    } else if (derived.usia_bulan === null) {
      errors.push({ field: 'tanggal_lahir', code: 'BALITA_AGE_INVALID', message: 'Tanggal lahir BALITA tidak valid atau melebihi tanggal acuan.' });
    } else if (derived.usia_bulan > 59) {
      errors.push({ field: 'tanggal_lahir', code: 'BALITA_MAX_59_MONTHS', message: 'Sasaran BALITA maksimal berusia 59 bulan pada tanggal registrasi/import.' });
    }
  }

  return { ok: errors.length === 0, errors: errors, derived: derived };
}

function validatePendampinganTaxonomy_7ER1(payload) {
  var data = payload || {};
  var jenisCheck = validateJenisSasaranOfficial_7ER1(data.jenis_sasaran);
  var errors = jenisCheck.errors.slice();
  var derived = derivePendampinganTaxonomy_7ER1(data);

  if (jenisCheck.jenis_sasaran === 'BALITA') {
    if (!data.tanggal_lahir) {
      errors.push({ field: 'tanggal_lahir', code: 'BALITA_TANGGAL_LAHIR_REQUIRED_FOR_PENDAMPINGAN', message: 'Tanggal lahir sasaran BALITA wajib tersedia untuk menghitung prioritas saat pendampingan.' });
    }
    if (!data.tanggal_pendampingan) {
      errors.push({ field: 'tanggal_pendampingan', code: 'TANGGAL_PENDAMPINGAN_REQUIRED_FOR_BALITA_PRIORITY', message: 'Tanggal pendampingan wajib tersedia untuk menghitung Baduta Prioritas historis.' });
    }
    if (data.tanggal_lahir && data.tanggal_pendampingan && derived.usia_bulan_saat_pendampingan === null) {
      errors.push({ field: 'tanggal_lahir', code: 'BALITA_AGE_AT_PENDAMPINGAN_INVALID', message: 'Tanggal lahir atau tanggal pendampingan tidak valid untuk perhitungan umur BALITA.' });
    }
  }

  return { ok: errors.length === 0, errors: errors, derived: derived };
}

function decorateSasaranPayloadTaxonomy_7ER1(payload, options) {
  var data = Object.assign({}, payload || {});
  var derived = deriveSasaranTaxonomy_7ER1(data, options);

  data.jenis_sasaran = derived.jenis_sasaran;
  data.usia_bulan = derived.usia_bulan;
  data.is_baduta_prioritas = derived.is_baduta_prioritas;
  data.kelompok_umur_balita = derived.kelompok_umur_balita;
  data.taxonomy_version = derived.taxonomy_version;

  return data;
}

function decoratePendampinganPayloadTaxonomy_7ER1(payload) {
  var data = Object.assign({}, payload || {});
  var derived = derivePendampinganTaxonomy_7ER1(data);

  data.jenis_sasaran = derived.jenis_sasaran;
  data.usia_bulan_saat_pendampingan = derived.usia_bulan_saat_pendampingan;
  data.is_baduta_prioritas_saat_pendampingan = derived.is_baduta_prioritas_saat_pendampingan;
  data.kelompok_umur_saat_pendampingan = derived.kelompok_umur_saat_pendampingan;
  data.taxonomy_version = derived.taxonomy_version;

  return data;
}

/**
 * Smoke test manual di Apps Script editor.
 * Jalankan: testTaxonomy7ER1
 */
function testTaxonomy7ER1() {
  var cases = [
    validateJenisSasaranOfficial_7ER1('BADUTA'),
    validateSasaranTaxonomy_7ER1({ jenis_sasaran: 'BALITA', tanggal_lahir: '2024-02-01', tanggal_registrasi: '2026-01-31' }),
    validateSasaranTaxonomy_7ER1({ jenis_sasaran: 'BALITA', tanggal_lahir: '2023-12-01', tanggal_registrasi: '2026-01-31' }),
    validatePendampinganTaxonomy_7ER1({ jenis_sasaran: 'BALITA', tanggal_lahir: '2024-02-01', tanggal_pendampingan: '2026-01-31' })
  ];

  Logger.log(JSON.stringify(cases, null, 2));
  return cases;
}
