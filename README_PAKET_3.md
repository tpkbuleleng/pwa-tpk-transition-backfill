# README Paket 3 — Shared Validation Layer

Paket ini adalah update untuk repository yang sudah memiliki Paket 1 dan Paket 2.

## Cara pakai

Upload seluruh isi ZIP ke root repository GitHub.

File yang ditambahkan/diubah:

```txt
index.html
src/main.js
src/config/appConfig.js
src/styles/app.css
src/validation/
docs/SHARED_VALIDATION_LAYER.md
README_PAKET_3.md
VERSION.txt
```

Paket ini tidak menyertakan `src/config/backendConfig.js`, sehingga URL Apps Script yang sudah aktif tidak tertimpa.

## Uji GitHub Pages

Setelah upload dan commit, buka GitHub Pages lalu klik:

1. `Cek Backend`
2. `Generate Client Mutation ID`
3. `Cek Shared Validation Layer`

Paket dianggap berhasil jika:

1. mode tetap `BACKFILL`;
2. provider tetap `GASProvider`;
3. healthCheck tetap sukses;
4. validation check menampilkan:

```txt
valid_sasaran_baduta_should_pass: true
invalid_sasaran_should_fail: true
valid_pendampingan_should_pass: true
invalid_pendampingan_should_fail: true
```

## Commit message yang disarankan

```txt
Paket 3 - Shared Validation Layer
```

Jika hasil uji sudah PASS, commit tambahan:

```txt
Paket 3 PASS - Shared Validation Layer
```
