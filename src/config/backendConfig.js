// src/config/backendConfig.js

import { APP_MODES } from "./appConfig.js";

export const BACKEND_CONFIG = Object.freeze({
  [APP_MODES.BACKFILL]: {
    provider: "GAS",

    /**
     * Isi setelah Apps Script Web App tersedia.
     * Contoh:
     * https://script.google.com/macros/s/XXXXX/exec
     */
    gasWebAppUrl: "",

    timeoutMs: 30000,
  },

  [APP_MODES.PRODUCTION]: {
    provider: "SUPABASE",

    /**
     * Untuk Paket 1 masih placeholder.
     * Jangan pernah menaruh service role key di frontend.
     * Nanti production hanya boleh memakai Supabase anon key.
     */
    supabaseUrl: "",
    supabaseAnonKey: "",

    timeoutMs: 30000,
  },
});
