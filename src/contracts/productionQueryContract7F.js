/**
 * Paket 7-F — Production Query Contract Helpers
 *
 * Tidak ada direct Supabase call di file ini.
 */

export const PRODUCTION_QUERY_CONTRACT_VERSION_7F = 'TPK_QUERY_CONTRACT_2026_7F';
export const TAXONOMY_VERSION_7E_R1 = 'TPK_TAXONOMY_2026_7E_R1';

export const OFFICIAL_JENIS_SASARAN_7F = Object.freeze([
  'CATIN',
  'BUMIL',
  'BUFAS',
  'BALITA'
]);

export function normalizeJenisSasaranFilter7F(value) {
  const raw = String(value || '').trim().toUpperCase();

  if (!raw) return null;

  if (raw === 'BADUTA') {
    const error = new Error(
      'BADUTA tidak lagi dipakai sebagai jenis_sasaran. Gunakan BALITA + is_baduta_prioritas.'
    );
    error.code = 'BADUTA_LEGACY_NOT_ALLOWED';
    error.field = 'jenis_sasaran';
    throw error;
  }

  if (!OFFICIAL_JENIS_SASARAN_7F.includes(raw)) {
    const error = new Error('jenis_sasaran resmi hanya CATIN, BUMIL, BUFAS, BALITA.');
    error.code = 'INVALID_JENIS_SASARAN';
    error.field = 'jenis_sasaran';
    throw error;
  }

  return raw;
}

export function clampLimit7F(value, fallback = 50) {
  const n = Number.parseInt(value, 10);
  if (!Number.isFinite(n)) return fallback;
  return Math.max(1, Math.min(n, 200));
}

export function normalizeOffset7F(value) {
  const n = Number.parseInt(value, 10);
  if (!Number.isFinite(n)) return 0;
  return Math.max(0, n);
}

export function buildSasaranLiteQueryPayload7F(filters = {}) {
  return {
    id_kecamatan: filters.id_kecamatan || null,
    id_tim: filters.id_tim || null,
    jenis_sasaran: normalizeJenisSasaranFilter7F(filters.jenis_sasaran),
    is_baduta_prioritas:
      typeof filters.is_baduta_prioritas === 'boolean'
        ? filters.is_baduta_prioritas
        : null,
    search: filters.search ? String(filters.search).trim() : null,
    limit: clampLimit7F(filters.limit, 50),
    offset: normalizeOffset7F(filters.offset)
  };
}

export function buildPendampinganLiteQueryPayload7F(filters = {}) {
  return {
    id_kecamatan: filters.id_kecamatan || null,
    id_tim: filters.id_tim || null,
    periode_bulan: filters.periode_bulan ? String(filters.periode_bulan).trim() : null,
    tahun_laporan:
      filters.tahun_laporan === null || filters.tahun_laporan === undefined || filters.tahun_laporan === ''
        ? null
        : Number.parseInt(filters.tahun_laporan, 10),
    jenis_sasaran: normalizeJenisSasaranFilter7F(filters.jenis_sasaran),
    is_baduta_prioritas_saat_pendampingan:
      typeof filters.is_baduta_prioritas_saat_pendampingan === 'boolean'
        ? filters.is_baduta_prioritas_saat_pendampingan
        : null,
    search: filters.search ? String(filters.search).trim() : null,
    limit: clampLimit7F(filters.limit, 50),
    offset: normalizeOffset7F(filters.offset)
  };
}

export function assertQueryEnvelope7F(result, methodName = 'backend query') {
  if (!result || typeof result !== 'object') {
    throw new Error(`${methodName} tidak mengembalikan object response.`);
  }

  if (result.ok === false) {
    const firstError = Array.isArray(result.errors) ? result.errors[0] : null;
    const message = firstError?.message || `${methodName} gagal.`;
    const error = new Error(message);
    error.code = firstError?.code || 'QUERY_CONTRACT_ERROR';
    error.field = firstError?.field || null;
    error.payload = result;
    throw error;
  }

  if (result.ok !== true) {
    throw new Error(`${methodName} tidak mengikuti envelope 7F: ok harus true/false.`);
  }

  return result;
}
