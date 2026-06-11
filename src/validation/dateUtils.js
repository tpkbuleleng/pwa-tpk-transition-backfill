// src/validation/dateUtils.js

export function parseIsoDate(value) {
  if (!value || typeof value !== "string") return null;

  const normalized = value.trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(normalized)) return null;

  const date = new Date(`${normalized}T00:00:00`);

  if (Number.isNaN(date.getTime())) return null;

  const [year, month, day] = normalized.split("-").map(Number);

  if (
    date.getFullYear() !== year ||
    date.getMonth() + 1 !== month ||
    date.getDate() !== day
  ) {
    return null;
  }

  return date;
}

export function toIsoDateOnly(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

export function isFutureDate(dateValue, referenceDate = new Date()) {
  const date = parseIsoDate(dateValue);
  if (!date) return false;

  const ref = parseIsoDate(toIsoDateOnly(referenceDate));
  return date.getTime() > ref.getTime();
}

export function getMonthNumber(dateValue) {
  const date = parseIsoDate(dateValue);
  if (!date) return null;

  return date.getMonth() + 1;
}

export function getYearNumber(dateValue) {
  const date = parseIsoDate(dateValue);
  if (!date) return null;

  return date.getFullYear();
}

export function diffInCompletedMonths(startDateValue, endDateValue = toIsoDateOnly(new Date())) {
  const start = parseIsoDate(startDateValue);
  const end = parseIsoDate(endDateValue);

  if (!start || !end) return null;

  let months = (end.getFullYear() - start.getFullYear()) * 12;
  months += end.getMonth() - start.getMonth();

  if (end.getDate() < start.getDate()) {
    months -= 1;
  }

  return months;
}
