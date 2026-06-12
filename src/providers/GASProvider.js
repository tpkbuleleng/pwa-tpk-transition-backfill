// src/providers/GASProvider.js

import { BackendProvider } from "./BackendProvider.js";
import { APP_META } from "../config/appConfig.js";
import { postJson } from "../utils/httpClient.js";
import {
  normalizeProviderError,
  successResponse,
} from "../utils/providerResponse.js";

export class GASProvider extends BackendProvider {
  getProviderName() {
    return "GASProvider";
  }

  async callAction(action, payload = {}, options = {}) {
    try {
      const requestBody = {
        action,
        payload,
        meta: {
          app_name: APP_META.appName,
          app_version: APP_META.version,
          app_mode: APP_META.mode,
          provider: this.getProviderName(),
          client_time: new Date().toISOString(),
          ...options.meta,
        },
      };

      const raw = await postJson(this.config.gasWebAppUrl, requestBody, {
        timeoutMs: this.config.timeoutMs,
      });

      if (typeof raw?.ok === "boolean" && raw.status) {
        return raw;
      }

      return successResponse({
        data: raw,
        message: "Response Apps Script diterima.",
        meta: {
          provider: this.getProviderName(),
          action,
        },
      });
    } catch (error) {
      return normalizeProviderError(error, {
        provider: this.getProviderName(),
        action,
      });
    }
  }

  healthCheck() {
    return this.callAction("healthCheck");
  }

  login(payload) {
    return this.callAction("login", payload);
  }

  logout() {
    return successResponse({
      message: "Logout lokal berhasil.",
      meta: {
        provider: this.getProviderName(),
      },
    });
  }

  getMyProfileLite(payload = {}) {
    return this.callAction("getMyProfileLite", payload);
  }

  getMasterRefs(payload = {}) {
    return this.callAction("getMasterRefs", payload);
  }

  setupStagingSheets(payload = {}) {
    return this.callAction("setupStagingSheets", payload);
  }

  getWorkbookRoute(payload = {}) {
    return this.callAction("getWorkbookRoute", payload);
  }

  submitRegistrasi(payload) {
    return this.callAction("submitRegistrasi", payload);
  }

  submitPendampingan(payload) {
    return this.callAction("submitPendampingan", payload);
  }

  submitBatch(payload) {
    return this.callAction("submitBatch", payload);
  }

  getSubmitStatus(payload) {
    return this.callAction("getSubmitStatus", payload);
  }
}
