/**
 * Paket 7-F — Frontend Contract Smoke Test
 *
 * Dapat dijalankan di Node jika project memakai ES Modules.
 * Fokus test: validasi helper kontrak, bukan koneksi Supabase.
 */

import {
  buildSasaranLiteQueryPayload7F,
  buildPendampinganLiteQueryPayload7F
} from '../src/contracts/productionQueryContract7F.js';

function assert(condition, message) {
  if (!condition) {
    throw new Error(message || 'Assertion failed');
  }
}

const balita = buildSasaranLiteQueryPayload7F({
  jenis_sasaran: 'balita',
  is_baduta_prioritas: true,
  limit: 500,
  offset: -10
});

assert(balita.jenis_sasaran === 'BALITA', 'BALITA harus dinormalisasi uppercase.');
assert(balita.is_baduta_prioritas === true, 'is_baduta_prioritas harus true.');
assert(balita.limit === 200, 'limit harus diclamp maksimal 200.');
assert(balita.offset === 0, 'offset negatif harus menjadi 0.');

const pendampingan = buildPendampinganLiteQueryPayload7F({
  jenis_sasaran: 'BALITA',
  is_baduta_prioritas_saat_pendampingan: false,
  tahun_laporan: '2026'
});

assert(pendampingan.jenis_sasaran === 'BALITA', 'Pendampingan BALITA valid.');
assert(pendampingan.tahun_laporan === 2026, 'tahun_laporan harus number.');

let badutaRejected = false;
try {
  buildSasaranLiteQueryPayload7F({ jenis_sasaran: 'BADUTA' });
} catch (err) {
  badutaRejected = err.code === 'BADUTA_LEGACY_NOT_ALLOWED';
}

assert(badutaRejected, 'BADUTA harus ditolak sebagai jenis_sasaran filter.');

console.log('PASS frontend_contract_smoke_7f.js');
