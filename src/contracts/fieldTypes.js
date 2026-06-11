// src/contracts/fieldTypes.js

export const FIELD_TYPES = Object.freeze({
  TEXT: "text",
  INTEGER: "integer",
  DECIMAL: "decimal",
  BOOLEAN: "boolean",
  DATE: "date",
  TIMESTAMP: "timestamp",
  ENUM: "enum",
  JSON: "json",
});

export const FIELD_SCOPES = Object.freeze({
  ALL: "all",
  SASARAN: "sasaran",
  PENDAMPINGAN: "pendampingan",
  IMPORT: "import",
  AUDIT: "audit",
  CATIN: "catin",
  BUMIL: "bumil",
  BUFAS: "bufas",
  BADUTA: "baduta",
});
