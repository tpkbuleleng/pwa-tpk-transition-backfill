# Paket 1 — Mode Architecture & Backend Provider Contract

Project: PWA TPK Kabupaten Buleleng  
Arsitektur: Single Codebase, Dual Backend Provider  
Mode awal: BACKFILL = Apps Script + Google Sheet staging  
Mode target: PRODUCTION = Supabase

## Isi Paket

```txt
/
├── index.html
├── src/
│   ├── main.js
│   ├── config/
│   │   ├── appConfig.js
│   │   └── backendConfig.js
│   ├── providers/
│   │   ├── BackendProvider.js
│   │   ├── GASProvider.js
│   │   └── SupabaseProvider.js
│   ├── services/
│   │   └── backend.js
│   ├── utils/
│   │   ├── httpClient.js
│   │   ├── providerResponse.js
│   │   └── clientMutationId.js
│   └── styles/
│       └── app.css
└── apps-script/
    └── Code.gs
```

## Yang Sudah Ada

1. APP_MODE.
2. Backend provider contract.
3. GASProvider.
4. SupabaseProvider placeholder.
5. Response envelope standar.
6. Client mutation ID generator.
7. Halaman uji health check.
8. Apps Script healthCheck minimal.

## Yang Belum Ada

1. Form registrasi.
2. Form pendampingan.
3. Validasi detail.
4. Append ke Google Sheet staging.
5. Supabase Auth.
6. Tabel Supabase.
7. Service worker.
8. IndexedDB sync queue.

## Cara Uji Lokal

Jangan membuka `index.html` langsung dengan double click jika browser memblokir ES module.
Gunakan salah satu:

1. VS Code Live Server.
2. Python local server:

```bash
python -m http.server 8080
```

Lalu buka:

```txt
http://localhost:8080
```

## Cara Deploy Frontend ke GitHub Pages

1. Upload semua file kecuali folder `apps-script` jika tidak ingin ditampilkan publik.
2. Aktifkan GitHub Pages dari branch utama.
3. Buka URL GitHub Pages.
4. Pastikan badge menampilkan `BACKFILL`.

## Cara Deploy Apps Script Minimal

1. Buka Google Apps Script.
2. Buat project baru.
3. Tempel isi file `apps-script/Code.gs`.
4. Klik Deploy > New deployment.
5. Pilih type: Web app.
6. Execute as: Me.
7. Who has access: Anyone.
8. Copy Web App URL.
9. Masukkan URL tersebut ke file:

```txt
src/config/backendConfig.js
```

pada bagian:

```js
gasWebAppUrl: "PASTE_URL_DI_SINI",
```

10. Upload ulang file ke GitHub Pages.
11. Tekan tombol `Cek Backend`.

## Cara Mengganti Mode ke Production Nanti

Buka:

```txt
src/config/appConfig.js
```

ubah:

```js
export const APP_MODE = APP_MODES.BACKFILL;
```

menjadi:

```js
export const APP_MODE = APP_MODES.PRODUCTION;
```

Namun untuk Paket 1, SupabaseProvider masih placeholder.

## Kriteria Paket 1 Berhasil

1. Halaman aplikasi tampil.
2. Badge mode tampil `BACKFILL`.
3. Provider tampil `GASProvider`.
4. Tombol `Generate Client Mutation ID` menghasilkan ID.
5. Sebelum URL Apps Script diisi, health check menampilkan error wajar.
6. Setelah URL Apps Script diisi dan dideploy, health check mengembalikan response success.
7. UI tidak memanggil Apps Script langsung, tetapi melalui `backend` service.
