/**
 * Paket 7-F — Production Read Service
 *
 * Service ini dipanggil UI/use-case layer.
 * Service ini hanya memanggil backend contract, bukan Supabase/GAS langsung.
 */

import {
  assertQueryEnvelope7F,
  buildPendampinganLiteQueryPayload7F,
  buildSasaranLiteQueryPayload7F
} from '../contracts/productionQueryContract7F.js';

export class ProductionReadService7F {
  constructor(backend) {
    if (!backend) {
      throw new Error('ProductionReadService7F membutuhkan backend provider aktif.');
    }
    this.backend = backend;
  }

  async getSasaranLite(filters = {}) {
    const payload = buildSasaranLiteQueryPayload7F(filters);
    const result = await this.backend.querySasaranLite(payload);
    return assertQueryEnvelope7F(result, 'querySasaranLite');
  }

  async getPendampinganLite(filters = {}) {
    const payload = buildPendampinganLiteQueryPayload7F(filters);
    const result = await this.backend.queryPendampinganLite(payload);
    return assertQueryEnvelope7F(result, 'queryPendampinganLite');
  }

  async getSummary(filters = {}) {
    const result = await this.backend.getProductionBasicSummary(filters);
    return assertQueryEnvelope7F(result, 'getProductionBasicSummary');
  }

  async checkHealth() {
    const result = await this.backend.checkProductionQueryContractHealth();
    return assertQueryEnvelope7F(result, 'checkProductionQueryContractHealth');
  }
}

export default ProductionReadService7F;
