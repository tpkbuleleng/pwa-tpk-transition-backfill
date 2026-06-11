// src/main.js

import { APP_META, APP_MODE } from "./config/appConfig.js";
import { backend } from "./services/backend.js";
import { createClientMutationId } from "./utils/clientMutationId.js";
import { getContractSummary } from "./contracts/contractCheck.js";

function stringify(value) {
  return JSON.stringify(value, null, 2);
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

function renderModeBadge() {
  const badge = document.getElementById("modeBadge");

  if (!badge) return;

  badge.textContent = APP_MODE;
  badge.classList.remove("mode-backfill", "mode-production");

  if (APP_MODE === "BACKFILL") {
    badge.classList.add("mode-backfill");
  }

  if (APP_MODE === "PRODUCTION") {
    badge.classList.add("mode-production");
  }
}

async function testBackendConnection() {
  setText("backendStatus", "Mengecek koneksi backend...");

  const result = await backend.healthCheck();

  setText(
    "backendStatus",
    stringify({
      provider: backend.getProviderName(),
      result,
    })
  );

  console.log("Backend health check:", result);
}

function generateMutationId() {
  const sample = {
    registrasi: createClientMutationId("reg"),
    pendampingan: createClientMutationId("pdg"),
  };

  setText("backendStatus", stringify(sample));
}

function checkContract() {
  const summary = getContractSummary();
  setText("contractStatus", stringify(summary));
  console.log("Paket 2 contract summary:", summary);
}

function boot() {
  document.title = `${APP_META.appName} — ${APP_META.mode}`;

  renderModeBadge();

  setText("providerName", `Provider: ${backend.getProviderName()}`);
  setText("activeModeText", APP_META.mode);
  setText("appVersionText", APP_META.version);

  document
    .getElementById("btnHealthCheck")
    ?.addEventListener("click", testBackendConnection);

  document
    .getElementById("btnMutationId")
    ?.addEventListener("click", generateMutationId);

  document
    .getElementById("btnContractCheck")
    ?.addEventListener("click", checkContract);

  testBackendConnection();
  checkContract();
}

document.addEventListener("DOMContentLoaded", boot);
