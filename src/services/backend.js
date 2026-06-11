// src/services/backend.js

import { APP_MODE, APP_MODES } from "../config/appConfig.js";
import { BACKEND_CONFIG } from "../config/backendConfig.js";
import { GASProvider } from "../providers/GASProvider.js";
import { SupabaseProvider } from "../providers/SupabaseProvider.js";

function createBackendProvider() {
  const config = BACKEND_CONFIG[APP_MODE];

  if (!config) {
    throw new Error(`Konfigurasi backend untuk APP_MODE=${APP_MODE} tidak ditemukan.`);
  }

  switch (APP_MODE) {
    case APP_MODES.BACKFILL:
      return new GASProvider(config);

    case APP_MODES.PRODUCTION:
      return new SupabaseProvider(config);

    default:
      throw new Error(`APP_MODE tidak valid: ${APP_MODE}`);
  }
}

export const backend = createBackendProvider();
