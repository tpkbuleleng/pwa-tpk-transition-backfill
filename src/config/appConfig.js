// src/config/appConfig.js

export const APP_MODES = Object.freeze({
  BACKFILL: "BACKFILL",
  PRODUCTION: "PRODUCTION",
});

/**
 * Mode aktif aplikasi.
 *
 * BACKFILL   = Apps Script + Google Sheet staging
 * PRODUCTION = Supabase
 *
 * Untuk Paket 2, tetap gunakan BACKFILL.
 */
export const APP_MODE = APP_MODES.BACKFILL;

export const APP_VERSION = "tpk-transition-p2-20260612-r1";

export const APP_META = Object.freeze({
  appName: "PWA TPK Kabupaten Buleleng",
  packageName: "Paket 2 — Data Dictionary & CSV Contract",
  version: APP_VERSION,
  mode: APP_MODE,
});
