/**
 * Paket 7-F — Backend Provider Contract Extension
 *
 * File ini hanya kontrak method. UI tidak boleh memanggil Supabase/GAS langsung.
 *
 * Backend provider aktif wajib menyediakan:
 * - querySasaranLite(filters)
 * - queryPendampinganLite(filters)
 * - getProductionBasicSummary(filters?)
 * - checkProductionQueryContractHealth()
 */

export class BackendProviderContract7F {
  async querySasaranLite(_filters = {}) {
    throw new Error('querySasaranLite(filters) belum diimplementasikan oleh provider aktif.');
  }

  async queryPendampinganLite(_filters = {}) {
    throw new Error('queryPendampinganLite(filters) belum diimplementasikan oleh provider aktif.');
  }

  async getProductionBasicSummary(_filters = {}) {
    throw new Error('getProductionBasicSummary(filters) belum diimplementasikan oleh provider aktif.');
  }

  async checkProductionQueryContractHealth() {
    throw new Error('checkProductionQueryContractHealth() belum diimplementasikan oleh provider aktif.');
  }
}

export default BackendProviderContract7F;
