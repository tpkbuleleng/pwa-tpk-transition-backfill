# Kontrak Backend Provider

UI tidak boleh memanggil Apps Script atau Supabase secara langsung.
UI hanya boleh memanggil service:

```js
backend.healthCheck()
backend.login(payload)
backend.logout()
backend.getMyProfileLite(payload)
backend.getMasterRefs(payload)
backend.submitRegistrasi(payload)
backend.submitPendampingan(payload)
backend.submitBatch(payload)
backend.getSubmitStatus(payload)
```

## Request Envelope

```js
{
  action: "submitPendampingan",
  payload: {},
  meta: {
    app_name: "PWA TPK Kabupaten Buleleng",
    app_version: "...",
    app_mode: "BACKFILL",
    provider: "GASProvider",
    client_time: "2026-06-12T00:00:00.000Z"
  }
}
```

## Success Response

```js
{
  ok: true,
  status: "success",
  message: "OK",
  data: {},
  error: null,
  meta: {}
}
```

## Error Response

```js
{
  ok: false,
  status: "validation_error",
  message: "Data belum valid.",
  data: null,
  error: {
    code: "VALIDATION_ERROR",
    message: "Data belum valid.",
    detail: []
  },
  meta: {}
}
```
