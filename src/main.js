// src/main.js

import { APP_META, APP_MODE } from "./config/appConfig.js";
import { backend } from "./services/backend.js";
import { createClientMutationId } from "./utils/clientMutationId.js";
import { getContractSummary } from "./contracts/contractCheck.js";
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
import {
  BULAN_BACKFILL_OPTIONS,
  JENIS_KELAMIN_OPTIONS,
  JENIS_SASARAN_OPTIONS,
  STATUS_PENDAMPINGAN_OPTIONS,
} from "./forms/formOptions.js";
import { buildPendampinganPayload, buildSasaranPayload } from "./payload/payloadBuilder.js";
import { deleteDraft, DRAFT_KEYS, loadDraft, saveDraft } from "./storage/draftStorage.js";
import { getSupabaseStagingContractSummary } from "./supabase/stagingContract.js";
import { getSupabasePromoteDryRunContractSummary } from "./supabase/promoteDryRunContract.js";

function $(id) {
  return document.getElementById(id);
}

function renderJson(targetId, value) {
  const target = $(targetId);
  if (!target) return;
  target.textContent = JSON.stringify(value, null, 2);
}

function getFormData(formId) {
  const form = $(formId);
  if (!form) return {};

  const data = {};
  const formData = new FormData(form);

  for (const [key, value] of formData.entries()) {
    data[key] = typeof value === "string" ? value.trim() : value;
  }

  return data;
}

function setFormData(formId, data = {}) {
  const form = $(formId);
  if (!form) return;

  for (const element of form.elements) {
    if (!element.name) continue;
    if (Object.prototype.hasOwnProperty.call(data, element.name)) {
      element.value = data[element.name] ?? "";
    }
  }
}

function mergeContextData(formData = {}) {
  return {
    ...getFormData("contextForm"),
    ...formData,
  };
}

function ensureMutationId(formId, prefix) {
  const form = $(formId);
  if (!form) return "";

  const input = form.elements.client_mutation_id;
  if (!input) return "";

  if (!input.value) {
    input.value = createClientMutationId(prefix);
  }

  return input.value;
}

function populateSelect(select, options = []) {
  const currentValue = select.value;
  select.innerHTML = "";

  const emptyOption = document.createElement("option");
  emptyOption.value = "";
  emptyOption.textContent = "Pilih...";
  select.appendChild(emptyOption);

  for (const option of options) {
    const el = document.createElement("option");
    el.value = option.value;
    el.textContent = option.label;
    select.appendChild(el);
  }

  if (currentValue) select.value = currentValue;
}

function initSelectOptions() {
  const optionMap = {
    jenisSasaran: JENIS_SASARAN_OPTIONS,
    jenisKelamin: JENIS_KELAMIN_OPTIONS,
    bulanBackfill: BULAN_BACKFILL_OPTIONS,
    statusPendampingan: STATUS_PENDAMPINGAN_OPTIONS,
  };

  for (const select of document.querySelectorAll("select[data-options]")) {
    populateSelect(select, optionMap[select.dataset.options] || []);
  }
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

function getCurrentRoutePayload() {
  const context = getFormData("contextForm");

  return {
    requested_by: "frontend_paket_7b",
    kode_kecamatan: context.kode_kecamatan || context.id_kecamatan,
    id_kecamatan: context.id_kecamatan,
    nama_kecamatan: context.nama_kecamatan,
  };
}

async function checkWorkbookRoute() {
  const routePayload = getCurrentRoutePayload();

  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    action: "getWorkbookRoute",
    status: "checking",
    payload: routePayload,
  });

  const result = await backend.getWorkbookRoute(routePayload);

  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    action: "getWorkbookRoute",
    result,
  });
}

async function setupStagingSheets() {
  const routePayload = getCurrentRoutePayload();

  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    action: "setupStagingSheets",
    status: "sending",
    message: "Menyiapkan header sheet staging berdasarkan route kecamatan...",
    payload: routePayload,
  });

  const result = await backend.setupStagingSheets(routePayload);

  renderJson("backendOutput", {
    provider: backend.getProviderName(),
    action: "setupStagingSheets",
    result,
  });
}

function generateMutationIds() {
  renderJson("backendOutput", {
    registrasi: createClientMutationId("reg"),
    pendampingan: createClientMutationId("pdg"),
  });
}

function checkContractLayer() {
  renderJson("backendOutput", getContractSummary());
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

  renderJson("backendOutput", {
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
  });
}

function renderValidationStatus(targetId, validationResult, extraMessage = "") {
  const target = $(targetId);
  if (!target) return;

  target.classList.remove("muted-panel", "success-panel", "error-panel");
  target.classList.add(validationResult.ok ? "success-panel" : "error-panel");

  const title = validationResult.ok ? "Validasi berhasil." : "Validasi gagal.";
  const uniqueKey = validationResult.meta?.unique_key || "-";
  const needsReview = validationResult.meta?.needs_review ? "YA" : "TIDAK";

  const issueHtml = validationResult.issues?.length
    ? `<ul class="issue-list">${validationResult.issues
        .map((issue) => `<li><strong>${issue.field}</strong> — ${issue.message} <code>${issue.code}</code></li>`)
        .join("")}</ul>`
    : "";

  target.innerHTML = `
    <strong>${title}</strong><br />
    ${extraMessage ? `${extraMessage}<br />` : ""}
    Unique key: <code>${uniqueKey}</code><br />
    Needs review: <strong>${needsReview}</strong>
    ${issueHtml}
  `;
}

function renderSubmitStatus(targetId, result, successMessage) {
  const target = $(targetId);
  if (!target) return;

  target.classList.remove("muted-panel", "success-panel", "error-panel");
  target.classList.add(result.ok ? "success-panel" : "error-panel");

  if (result.ok) {
    target.innerHTML = `
      <strong>${successMessage}</strong><br />
      Status: <code>${result.status}</code><br />
      Sheet: <code>${result.data?.sheet_name || "-"}</code><br />
      Row: <code>${result.data?.row_number || "-"}</code><br />
      Record ID: <code>${result.data?.record_id || "-"}</code>
    `;
    return;
  }

  const errorDetail = result.error?.detail;
  const issues = Array.isArray(errorDetail?.issues) ? errorDetail.issues : [];
  const issueHtml = issues.length
    ? `<ul class="issue-list">${issues
        .map((issue) => `<li><strong>${issue.field || "-"}</strong> — ${issue.message || issue.code || "Error"} <code>${issue.code || "ERROR"}</code></li>`)
        .join("")}</ul>`
    : "";

  target.innerHTML = `
    <strong>Pengiriman gagal.</strong><br />
    Status: <code>${result.status || "error"}</code><br />
    Error: <code>${result.error?.code || "UNKNOWN_ERROR"}</code><br />
    ${result.message || result.error?.message || "Terjadi kesalahan."}
    ${issueHtml}
  `;
}

function buildAndValidateSasaran() {
  ensureMutationId("sasaranForm", "reg");

  const payload = buildSasaranPayload(mergeContextData(getFormData("sasaranForm")));
  const validation = validateSasaranPayload(payload, {
    today: new Date(),
    reference_date: new Date().toISOString().slice(0, 10),
  });

  return { payload, validation };
}

function buildAndValidatePendampingan() {
  ensureMutationId("pendampinganForm", "pdg");

  const formData = getFormData("pendampinganForm");
  const payload = buildPendampinganPayload(mergeContextData(formData));
  const monthlyReportContext = {
    existing_count_for_kader_month: Number(formData.existing_count_for_kader_month || 0),
    new_count: 1,
  };
  const validation = validatePendampinganPayload(payload, {
    today: new Date(),
    monthly_report_context: monthlyReportContext,
  });

  return { payload, validation, monthlyReportContext };
}

function previewSasaran() {
  const { payload, validation } = buildAndValidateSasaran();

  renderValidationStatus("sasaranStatus", validation, "Payload belum dikirim ke backend.");
  renderJson("sasaranOutput", {
    entity: "sasaran",
    validation,
    payload,
  });

  return { payload, validation };
}

function previewPendampingan() {
  const { payload, validation, monthlyReportContext } = buildAndValidatePendampingan();

  renderValidationStatus("pendampinganStatus", validation, "Payload belum dikirim ke backend.");
  renderJson("pendampinganOutput", {
    entity: "pendampingan",
    validation,
    payload,
    monthly_report_context: monthlyReportContext,
  });

  return { payload, validation, monthlyReportContext };
}

async function submitSasaranToSheet() {
  const { payload, validation } = buildAndValidateSasaran();

  if (!validation.ok) {
    renderValidationStatus("sasaranStatus", validation, "Data belum dikirim karena validasi frontend gagal.");
    renderJson("sasaranOutput", {
      ok: false,
      blocked_by: "frontend_validation",
      entity: "sasaran",
      validation,
      payload,
    });
    return;
  }

  renderValidationStatus("sasaranStatus", validation, "Mengirim payload ke Apps Script + Google Sheet staging...");
  renderJson("sasaranOutput", {
    entity: "sasaran",
    status: "sending",
    payload,
  });

  const result = await backend.submitRegistrasi(payload);

  renderSubmitStatus("sasaranStatus", result, "Sasaran berhasil dikirim ke Google Sheet staging.");
  renderJson("sasaranOutput", {
    entity: "sasaran",
    provider: backend.getProviderName(),
    result,
    payload,
  });
}

async function submitPendampinganToSheet() {
  const { payload, validation, monthlyReportContext } = buildAndValidatePendampingan();

  if (!validation.ok) {
    renderValidationStatus("pendampinganStatus", validation, "Data belum dikirim karena validasi frontend gagal.");
    renderJson("pendampinganOutput", {
      ok: false,
      blocked_by: "frontend_validation",
      entity: "pendampingan",
      validation,
      payload,
      monthly_report_context: monthlyReportContext,
    });
    return;
  }

  renderValidationStatus("pendampinganStatus", validation, "Mengirim payload ke Apps Script + Google Sheet staging...");
  renderJson("pendampinganOutput", {
    entity: "pendampingan",
    status: "sending",
    payload,
    monthly_report_context: monthlyReportContext,
  });

  const result = await backend.submitPendampingan(payload);

  renderSubmitStatus("pendampinganStatus", result, "Pendampingan berhasil dikirim ke Google Sheet staging.");
  renderJson("pendampinganOutput", {
    entity: "pendampingan",
    provider: backend.getProviderName(),
    result,
    payload,
    monthly_report_context: monthlyReportContext,
  });
}

function fillSasaranSample() {
  setFormData("sasaranForm", {
    client_mutation_id: createClientMutationId("reg"),
    jenis_sasaran: "BADUTA",
    nama_sasaran: "ANAK CONTOH",
    jenis_kelamin: "LAKI_LAKI",
    tanggal_lahir: "2025-01-15",
    nik: "5108010101010001",
    no_kk: "5108010101019999",
    nama_ibu_kandung: "IBU CONTOH",
    nama_pasangan: "",
    no_hp: "",
    alamat_lengkap: "Alamat contoh backfill Tejakula",
    catatan_backfill: "Contoh payload valid Paket 7-B",
  });
  previewSasaran();
}

function fillPendampinganSample() {
  setFormData("pendampinganForm", {
    client_mutation_id: createClientMutationId("pdg"),
    id_sasaran_temp: "SAS_TMP_TJK_0004",
    id_sasaran: "",
    nik: "5108010101010004",
    nama_sasaran: "ANAK CONTOH 4",
    sasaran_unique_key: "",
    jenis_sasaran: "BADUTA",
    periode_bulan: "1",
    tahun_laporan: "2026",
    tanggal_pendampingan: "2026-01-18",
    status_pendampingan: "KUNJUNGAN_RUMAH",
    existing_count_for_kader_month: "0",
    hasil_pendampingan: "Pendampingan contoh berhasil dilakukan.",
    catatan_pendampingan: "Contoh payload valid Paket 7-B",
  });
  previewPendampingan();
}

function saveSasaranDraft() {
  const draft = saveDraft(DRAFT_KEYS.SASARAN, {
    context: getFormData("contextForm"),
    sasaran: getFormData("sasaranForm"),
  });

  renderJson("sasaranOutput", {
    ok: true,
    message: "Draft sasaran tersimpan lokal.",
    draft,
  });
}

function loadSasaranDraft() {
  const draft = loadDraft(DRAFT_KEYS.SASARAN);

  if (!draft) {
    renderJson("sasaranOutput", {
      ok: false,
      message: "Draft sasaran belum ada.",
    });
    return;
  }

  setFormData("contextForm", draft.data?.context || {});
  setFormData("sasaranForm", draft.data?.sasaran || {});
  previewSasaran();
}

function deleteSasaranDraft() {
  deleteDraft(DRAFT_KEYS.SASARAN);
  renderJson("sasaranOutput", {
    ok: true,
    message: "Draft sasaran dihapus.",
  });
}

function savePendampinganDraft() {
  const draft = saveDraft(DRAFT_KEYS.PENDAMPINGAN, {
    context: getFormData("contextForm"),
    pendampingan: getFormData("pendampinganForm"),
  });

  renderJson("pendampinganOutput", {
    ok: true,
    message: "Draft pendampingan tersimpan lokal.",
    draft,
  });
}

function loadPendampinganDraft() {
  const draft = loadDraft(DRAFT_KEYS.PENDAMPINGAN);

  if (!draft) {
    renderJson("pendampinganOutput", {
      ok: false,
      message: "Draft pendampingan belum ada.",
    });
    return;
  }

  setFormData("contextForm", draft.data?.context || {});
  setFormData("pendampinganForm", draft.data?.pendampingan || {});
  previewPendampingan();
}

function deletePendampinganDraft() {
  deleteDraft(DRAFT_KEYS.PENDAMPINGAN);
  renderJson("pendampinganOutput", {
    ok: true,
    message: "Draft pendampingan dihapus.",
  });
}


function getExportPayload() {
  const context = getFormData("contextForm");
  const exportData = getFormData("exportForm");

  return {
    requested_by: "frontend_paket_7b",
    kode_kecamatan: context.kode_kecamatan || context.id_kecamatan,
    id_kecamatan: context.id_kecamatan,
    nama_kecamatan: context.nama_kecamatan,
    record_type: exportData.record_type || "sasaran",
    periode_bulan: exportData.periode_bulan || "1",
    tahun_laporan: exportData.tahun_laporan || "2026",
    create_drive_file: exportData.create_drive_file !== "FALSE",
  };
}

function renderExportStatus(result, actionLabel) {
  const target = $("exportStatus");
  if (!target) return;

  target.classList.remove("muted-panel", "success-panel", "error-panel");
  target.classList.add(result.ok ? "success-panel" : "error-panel");

  if (result.ok) {
    const data = result.data || {};
    const fileLink = data.file_url
      ? `<br />File CSV: <a href="${data.file_url}" target="_blank" rel="noopener">Buka file di Google Drive</a>`
      : "";

    target.innerHTML = `
      <strong>${actionLabel} berhasil.</strong><br />
      Status: <code>${result.status}</code><br />
      Route: <code>${data.route?.route_code || data.route_code || "-"}</code><br />
      Sheet: <code>${data.sheet_name || data.target?.sheet_name || "-"}</code><br />
      Total rows: <code>${data.total_rows ?? data.target?.total_rows ?? "-"}</code><br />
      Export batch: <code>${data.export_batch_id || "-"}</code><br />
      Import batch: <code>${data.import_batch_id || "-"}</code>
      ${fileLink}
    `;
    return;
  }

  target.innerHTML = `
    <strong>${actionLabel} gagal.</strong><br />
    Status: <code>${result.status || "error"}</code><br />
    Error: <code>${result.error?.code || "UNKNOWN_ERROR"}</code><br />
    ${result.message || result.error?.message || "Terjadi kesalahan."}
  `;
}

async function checkExportReadiness() {
  const payload = getExportPayload();

  renderJson("exportOutput", {
    action: "getExportReadiness",
    status: "checking",
    payload,
  });

  const result = await backend.getExportReadiness(payload);
  renderExportStatus(result, "Cek export readiness");

  renderJson("exportOutput", {
    provider: backend.getProviderName(),
    action: "getExportReadiness",
    result,
    payload,
  });
}

async function exportCsv() {
  const payload = getExportPayload();

  renderJson("exportOutput", {
    action: "exportCsv",
    status: "exporting",
    message: "Mengekspor CSV dari Google Sheet staging...",
    payload,
  });

  const result = await backend.exportCsv(payload);
  renderExportStatus(result, "Export CSV");

  renderJson("exportOutput", {
    provider: backend.getProviderName(),
    action: "exportCsv",
    result,
    payload,
  });
}

function checkSupabaseStagingContract() {
  renderJson("supabaseStagingOutput", getSupabaseStagingContractSummary());
}

function checkSupabasePromoteDryRunContract() {
  renderJson("supabasePromoteDryRunOutput", getSupabasePromoteDryRunContractSummary());
}

function bindEvents() {
  $("checkBackendBtn")?.addEventListener("click", checkBackend);
  $("checkRouteBtn")?.addEventListener("click", checkWorkbookRoute);
  $("setupSheetsBtn")?.addEventListener("click", setupStagingSheets);
  $("generateMutationBtn")?.addEventListener("click", generateMutationIds);
  $("checkContractBtn")?.addEventListener("click", checkContractLayer);
  $("checkValidationBtn")?.addEventListener("click", checkValidationLayer);
  $("checkExportReadinessBtn")?.addEventListener("click", checkExportReadiness);
  $("exportCsvBtn")?.addEventListener("click", exportCsv);
  $("checkSupabaseStagingContractBtn")?.addEventListener("click", checkSupabaseStagingContract);
  $("checkSupabasePromoteDryRunContractBtn")?.addEventListener("click", checkSupabasePromoteDryRunContract);

  $("fillSasaranSampleBtn")?.addEventListener("click", fillSasaranSample);
  $("previewSasaranBtn")?.addEventListener("click", previewSasaran);
  $("submitSasaranBtn")?.addEventListener("click", submitSasaranToSheet);
  $("saveSasaranDraftBtn")?.addEventListener("click", saveSasaranDraft);
  $("loadSasaranDraftBtn")?.addEventListener("click", loadSasaranDraft);
  $("deleteSasaranDraftBtn")?.addEventListener("click", deleteSasaranDraft);

  $("fillPendampinganSampleBtn")?.addEventListener("click", fillPendampinganSample);
  $("previewPendampinganBtn")?.addEventListener("click", previewPendampingan);
  $("submitPendampinganBtn")?.addEventListener("click", submitPendampinganToSheet);
  $("savePendampinganDraftBtn")?.addEventListener("click", savePendampinganDraft);
  $("loadPendampinganDraftBtn")?.addEventListener("click", loadPendampinganDraft);
  $("deletePendampinganDraftBtn")?.addEventListener("click", deletePendampinganDraft);
}

function init() {
  document.title = `${APP_META.appName} — ${APP_META.mode}`;
  initSelectOptions();
  renderModeBadge();
  bindEvents();
}

document.addEventListener("DOMContentLoaded", init);
