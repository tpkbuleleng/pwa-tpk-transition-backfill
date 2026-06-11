// src/utils/httpClient.js

export async function postJson(url, body, options = {}) {
  const timeoutMs = options.timeoutMs || 30000;

  if (!url) {
    throw new Error("URL backend belum dikonfigurasi.");
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    /**
     * Untuk Apps Script Web App, gunakan text/plain agar menghindari preflight CORS
     * yang sering bermasalah jika memakai application/json.
     *
     * Server Apps Script membaca JSON dari e.postData.contents.
     */
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "text/plain;charset=utf-8",
      },
      body: JSON.stringify(body),
      signal: controller.signal,
      redirect: "follow",
    });

    const text = await response.text();

    let json;
    try {
      json = JSON.parse(text);
    } catch {
      throw new Error(`Response backend bukan JSON valid: ${text.slice(0, 200)}`);
    }

    if (!response.ok) {
      throw new Error(json?.message || `HTTP ${response.status}`);
    }

    return json;
  } finally {
    clearTimeout(timeoutId);
  }
}
