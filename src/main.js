// src/main.js

import { APP_META, APP_MODE } from "./config/appConfig.js";
import { backend } from "./services/backend.js";
import { createClientMutationId } from "./utils/clientMutationId.js";
import {
  validatePendampinganPayload,
  validateSasaranPayload,
} from "./validation/index.js";
import {
  INVALID_SAMPLE_PENDAMPINGAN,
  INVALID_SAMPLE_SASARAN,
  VALID_SAMPLE_PENDAMPINGAN,
  VALID_SAMPLE_SASARAN_BADUTA,
} from "./validation/samplePayloads.js";

function $(id) {
  return document.getElementById(id);
}

function renderJson(targetId, value) {
  const target = $(targetId);
  if (!target) return;

  target.textContent = JSON.stringify(value, null, 2);
}

function renderModeBadge() {
  const badge = $("modeBadge");
  const modeText = $("modeText");
  const versionText = $("versionText");
  const providerLabel = $("providerLabel");

  if (badge) {
    badge.textContent = APP_MODE;
    badge.classList.remove("mode-backfill", "mode-production");

    if (APP_MODE === "BACKFILL") badge.classList.add("mode-backfill");
    if (APP_MODE === "PRODUCTION") badge.classList.add("mode-production");
  }

  if (modeText) modeText.textContent = APP_MODE;
  if (versionText) versionText.textContent = APP_META.version;
  if (providerLabel) providerLabel.textContent = `Provider: ${backend.getProviderName()}`;
}

async function checkBackend() {
  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    status: "checking",
  });

  const result = await backend.healthCheck();

  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    result,
  });
}

function generateMutationIds() {
  renderJson("backendOutput", {
    registrasi: createClientMutationId("reg"),
    pendampingan: createClientMutationId("pdg"),
  });
}

function checkValidationLayer() {
  const validSasaran = validateSasaranPayload(VALID_SAMPLE_SASARAN_BADUTA, {
    reference_date: "2026-06-12",
    today: new Date("2026-06-12T00:00:00"),
  });

  const invalidSasaran = validateSasaranPayload(INVALID_SAMPLE_SASARAN, {
    reference_date: "2026-06-12",
    today: new Date("2026-06-12T00:00:00"),
  });

  const validPendampingan = validatePendampinganPayload(VALID_SAMPLE_PENDAMPINGAN, {
    today: new Date("2026-06-12T00:00:00"),
    monthly_report_context: {
      existing_count_for_kader_month: 9,
      new_count: 1,
    },
  });

  const invalidPendampingan = validatePendampinganPayload(INVALID_SAMPLE_PENDAMPINGAN, {
    today: new Date("2026-06-12T00:00:00"),
    monthly_report_context: {
      existing_count_for_kader_month: 10,
      new_count: 1,
    },
  });

  renderJson("validationOutput", {
    ok: true,
    package: "Paket 3 — Shared Validation Layer",
    validation_version: APP_META.version,
    checks: {
      valid_sasaran_baduta_should_pass: validSasaran.ok,
      invalid_sasaran_should_fail: !invalidSasaran.ok,
      valid_pendampingan_should_pass: validPendampingan.ok,
      invalid_pendampingan_should_fail: !invalidPendampingan.ok,
    },
    summary: {
      valid_sasaran_error_count: validSasaran.error_count,
      invalid_sasaran_error_count: invalidSasaran.error_count,
      valid_pendampingan_error_count: validPendampingan.error_count,
      invalid_pendampingan_error_count: invalidPendampingan.error_count,
    },
    samples: {
      valid_sasaran: validSasaran,
      invalid_sasaran: invalidSasaran,
      valid_pendampingan: validPendampingan,
      invalid_pendampingan: invalidPendampingan,
    },
  });
}

function bindEvents() {
  $("checkBackendBtn")?.addEventListener("click", checkBackend);
  $("generateMutationBtn")?.addEventListener("click", generateMutationIds);
  $("checkValidationBtn")?.addEventListener("click", checkValidationLayer);
}

document.addEventListener("DOMContentLoaded", () => {
  document.title = `${APP_META.appName} — ${APP_META.mode}`;
  renderModeBadge();
  bindEvents();
});
