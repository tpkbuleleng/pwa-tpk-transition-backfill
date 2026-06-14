/* eslint-disable no-console */
const assert = require('assert');
const taxonomy = require('../src/shared/sasaranTaxonomy.js');

function run() {
  assert.deepStrictEqual(taxonomy.OFFICIAL_JENIS_SASARAN, ['CATIN', 'BUMIL', 'BUFAS', 'BALITA']);
  assert.strictEqual(taxonomy.isOfficialJenisSasaran('BADUTA'), false);
  assert.strictEqual(taxonomy.isOfficialJenisSasaran('BALITA'), true);

  const badutaInput = taxonomy.validateJenisSasaranOfficial('BADUTA');
  assert.strictEqual(badutaInput.ok, false);
  assert.strictEqual(badutaInput.errors[0].code, 'BADUTA_LEGACY_NOT_ALLOWED');

  const balita23 = taxonomy.validateSasaranTaxonomy({
    jenis_sasaran: 'BALITA',
    tanggal_lahir: '2024-02-01',
    tanggal_registrasi: '2026-01-31'
  });
  assert.strictEqual(balita23.ok, true);
  assert.strictEqual(balita23.derived.usia_bulan, 23);
  assert.strictEqual(balita23.derived.is_baduta_prioritas, true);
  assert.strictEqual(balita23.derived.kelompok_umur_balita, 'BADUTA_0_23');

  const balita25 = taxonomy.validateSasaranTaxonomy({
    jenis_sasaran: 'BALITA',
    tanggal_lahir: '2023-12-01',
    tanggal_registrasi: '2026-01-31'
  });
  assert.strictEqual(balita25.ok, true);
  assert.strictEqual(balita25.derived.usia_bulan, 25);
  assert.strictEqual(balita25.derived.is_baduta_prioritas, false);
  assert.strictEqual(balita25.derived.kelompok_umur_balita, 'BALITA_24_59');

  const balita60 = taxonomy.validateSasaranTaxonomy({
    jenis_sasaran: 'BALITA',
    tanggal_lahir: '2021-01-31',
    tanggal_registrasi: '2026-01-31'
  });
  assert.strictEqual(balita60.ok, false);
  assert.strictEqual(balita60.errors.some((e) => e.code === 'BALITA_MAX_59_MONTHS'), true);

  const pendampinganHistoris = taxonomy.validatePendampinganTaxonomy({
    jenis_sasaran: 'BALITA',
    tanggal_lahir: '2024-02-01',
    tanggal_pendampingan: '2026-01-31'
  });
  assert.strictEqual(pendampinganHistoris.ok, true);
  assert.strictEqual(pendampinganHistoris.derived.usia_bulan_saat_pendampingan, 23);
  assert.strictEqual(pendampinganHistoris.derived.is_baduta_prioritas_saat_pendampingan, true);

  console.log('PASS taxonomy_smoke_test.js');
}

run();
