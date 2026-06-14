/*
 * PWA TPK Kabupaten Buleleng
 * Paket 7-E-R1 — UI helper taxonomy sasaran
 *
 * File baru, aman ditambahkan.
 * Bergantung pada src/shared/sasaranTaxonomy.js.
 * Tidak memanggil backend langsung.
 */
(function attachSasaranTaxonomyUi(root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('./sasaranTaxonomy.js'));
  } else {
    root.SasaranTaxonomyUi7ER1 = factory(root.SasaranTaxonomy7ER1);
  }
})(typeof self !== 'undefined' ? self : this, function createSasaranTaxonomyUi(taxonomy) {
  'use strict';

  if (!taxonomy) {
    throw new Error('SasaranTaxonomy7ER1 belum dimuat. Muat sasaranTaxonomy.js sebelum sasaranTaxonomyUi.js.');
  }

  function getJenisSasaranOptions() {
    return taxonomy.OFFICIAL_JENIS_SASARAN.map(function mapOption(value) {
      return {
        value: value,
        label: value === 'BALITA' ? 'BALITA' : value
      };
    });
  }

  function decorateJenisSasaranSelect(selectElement, selectedValue) {
    if (!selectElement) return;

    var normalizedSelected = taxonomy.normalizeJenisSasaran(selectedValue || selectElement.value || '');
    selectElement.innerHTML = '';

    var empty = document.createElement('option');
    empty.value = '';
    empty.textContent = 'Pilih Jenis Sasaran';
    selectElement.appendChild(empty);

    getJenisSasaranOptions().forEach(function appendOption(item) {
      var option = document.createElement('option');
      option.value = item.value;
      option.textContent = item.label;
      option.selected = normalizedSelected === item.value;
      selectElement.appendChild(option);
    });
  }

  function getBadutaPriorityBadgeFromSasaran(payload, options) {
    var validation = taxonomy.validateSasaranTaxonomy(payload || {}, options || {});
    var derived = validation.derived;

    if (derived.jenis_sasaran !== 'BALITA') {
      return null;
    }

    if (validation.ok && derived.is_baduta_prioritas) {
      return {
        visible: true,
        label: 'BADUTA PRIORITAS',
        className: 'badge badge-warning badge-baduta-prioritas',
        description: 'BALITA usia 0–23 bulan pada tanggal acuan.'
      };
    }

    if (validation.ok && derived.kelompok_umur_balita === 'BALITA_24_59') {
      return {
        visible: true,
        label: 'BALITA NON-BADUTA',
        className: 'badge badge-neutral badge-balita-non-baduta',
        description: 'BALITA usia 24–59 bulan pada tanggal acuan.'
      };
    }

    return {
      visible: false,
      label: '',
      className: '',
      description: validation.errors.map(function mapError(e) { return e.message; }).join(' ')
    };
  }

  function getBadutaPriorityBadgeFromPendampingan(payload) {
    var validation = taxonomy.validatePendampinganTaxonomy(payload || {});
    var derived = validation.derived;

    if (derived.jenis_sasaran !== 'BALITA') {
      return null;
    }

    if (validation.ok && derived.is_baduta_prioritas_saat_pendampingan) {
      return {
        visible: true,
        label: 'BADUTA PRIORITAS SAAT PENDAMPINGAN',
        className: 'badge badge-warning badge-baduta-prioritas',
        description: 'BALITA usia 0–23 bulan pada tanggal pendampingan.'
      };
    }

    if (validation.ok && derived.kelompok_umur_saat_pendampingan === 'BALITA_24_59') {
      return {
        visible: true,
        label: 'BALITA NON-BADUTA SAAT PENDAMPINGAN',
        className: 'badge badge-neutral badge-balita-non-baduta',
        description: 'BALITA usia 24–59 bulan pada tanggal pendampingan.'
      };
    }

    return {
      visible: false,
      label: '',
      className: '',
      description: validation.errors.map(function mapError(e) { return e.message; }).join(' ')
    };
  }

  function renderBadge(element, badge) {
    if (!element) return;

    if (!badge || !badge.visible) {
      element.hidden = true;
      element.textContent = '';
      element.className = '';
      element.title = badge && badge.description ? badge.description : '';
      return;
    }

    element.hidden = false;
    element.textContent = badge.label;
    element.className = badge.className;
    element.title = badge.description || '';
  }

  return Object.freeze({
    getJenisSasaranOptions: getJenisSasaranOptions,
    decorateJenisSasaranSelect: decorateJenisSasaranSelect,
    getBadutaPriorityBadgeFromSasaran: getBadutaPriorityBadgeFromSasaran,
    getBadutaPriorityBadgeFromPendampingan: getBadutaPriorityBadgeFromPendampingan,
    renderBadge: renderBadge
  });
});
