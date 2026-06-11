// src/utils/clientMutationId.js

export function createClientMutationId(prefix = "mut") {
  const now = new Date().toISOString().replace(/[-:.TZ]/g, "");
  const random = Math.random().toString(36).slice(2, 10);

  return `${prefix}_${now}_${random}`;
}
