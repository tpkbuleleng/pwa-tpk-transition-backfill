// src/storage/draftStorage.js

const DRAFT_PREFIX = "tpk_backfill_draft";

export const DRAFT_KEYS = Object.freeze({
  SASARAN: `${DRAFT_PREFIX}_sasaran_v1`,
  PENDAMPINGAN: `${DRAFT_PREFIX}_pendampingan_v1`,
});

export function saveDraft(key, data) {
  if (!key) throw new Error("Draft key wajib diisi.");

  const envelope = {
    saved_at: new Date().toISOString(),
    data,
  };

  localStorage.setItem(key, JSON.stringify(envelope));

  return envelope;
}

export function loadDraft(key) {
  if (!key) throw new Error("Draft key wajib diisi.");

  const raw = localStorage.getItem(key);
  if (!raw) return null;

  try {
    return JSON.parse(raw);
  } catch {
    localStorage.removeItem(key);
    return null;
  }
}

export function deleteDraft(key) {
  if (!key) throw new Error("Draft key wajib diisi.");
  localStorage.removeItem(key);
  return true;
}

export function hasDraft(key) {
  return Boolean(localStorage.getItem(key));
}
