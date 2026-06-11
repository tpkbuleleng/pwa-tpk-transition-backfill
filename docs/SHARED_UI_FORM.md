# Paket 4 — Shared UI Form

## Tujuan

Paket 4 menambahkan UI form awal yang dipakai bersama oleh mode BACKFILL dan PRODUCTION. Pada tahap ini form belum mengirim data ke Google Sheet atau Supabase.

## Prinsip

UI tidak membentuk payload secara bebas. UI mengambil data form, lalu menyerahkannya ke `payloadBuilder`.

Alur:

```txt
Form UI
  ↓
Payload Builder
  ↓
Shared Validation Layer
  ↓
Preview Payload / Draft Lokal
```

## Komponen baru

```txt
src/forms/formOptions.js
src/payload/payloadBuilder.js
src/storage/draftStorage.js
```

## Form yang tersedia

1. Data Konteks Kader / Tim.
2. Form Registrasi Sasaran Awal.
3. Form Pendampingan Backfill.

## Draft lokal

Draft disimpan di browser memakai `localStorage`:

```txt
tpk_backfill_draft_sasaran_v1
tpk_backfill_draft_pendampingan_v1
```

Draft ini bersifat sementara untuk uji Paket 4. IndexedDB dan sync queue penuh baru masuk tahap production/offline-first berikutnya.

## Validasi

Form memakai validasi dari Paket 3:

```txt
validateSasaranPayload()
validatePendampinganPayload()
```

## Belum termasuk

Paket 4 belum mencakup:

1. append ke Google Sheet;
2. submit ke Supabase;
3. login penuh;
4. master wilayah dinamis;
5. service worker;
6. IndexedDB sync queue.
