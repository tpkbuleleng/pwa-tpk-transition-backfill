// src/providers/SupabaseProvider.js

import { BackendProvider } from "./BackendProvider.js";
import { errorResponse } from "../utils/providerResponse.js";

export class SupabaseProvider extends BackendProvider {
  getProviderName() {
    return "SupabaseProvider";
  }

  notReady(action) {
    return errorResponse({
      status: "not_implemented",
      code: "SUPABASE_PROVIDER_NOT_READY",
      message: `SupabaseProvider belum diaktifkan untuk action: ${action}`,
      meta: {
        provider: this.getProviderName(),
        action,
      },
    });
  }

  healthCheck() {
    return this.notReady("healthCheck");
  }

  login(_payload) {
    return this.notReady("login");
  }

  logout() {
    return this.notReady("logout");
  }

  getMyProfileLite(_payload = {}) {
    return this.notReady("getMyProfileLite");
  }

  getMasterRefs(_payload = {}) {
    return this.notReady("getMasterRefs");
  }

  submitRegistrasi(_payload) {
    return this.notReady("submitRegistrasi");
  }

  submitPendampingan(_payload) {
    return this.notReady("submitPendampingan");
  }

  submitBatch(_payload) {
    return this.notReady("submitBatch");
  }

  getSubmitStatus(_payload) {
    return this.notReady("getSubmitStatus");
  }
}
