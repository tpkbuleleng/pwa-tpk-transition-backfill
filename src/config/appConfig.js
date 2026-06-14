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
 */
export const APP_MODE = APP_MODES.BACKFILL;

export const APP_VERSION = "tpk-transition-p7d-20260615-r1";

export const APP_META = Object.freeze({
  appName: "PWA TPK Kabupaten Buleleng",
  version: APP_VERSION,
  mode: APP_MODE,
});
