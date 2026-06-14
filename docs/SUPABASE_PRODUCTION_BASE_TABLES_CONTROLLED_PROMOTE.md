# Paket 7-C — Production Base Tables & Controlled Promote

## Tujuan

Paket ini membuat tabel production base awal untuk PWA TPK Kabupaten Buleleng:

- `sasaran`
- `pendampingan`
- `production_promote_batch`
- `production_promote_error`

Paket ini belum mengaktifkan SupabaseProvider frontend, Supabase Auth, atau RLS operasional kader.

## Prinsip

Data tidak dipromosikan langsung dari CSV staging ke production. Jalur wajib:

```txt
staging_sasaran_import / staging_pendampingan_import
  ↓ validate_backfill_import_batch()
dryrun_sasaran / dryrun_pendampingan
  ↓ promote_backfill_dryrun_to_production()
sasaran / pendampingan
```

## Fungsi utama

```sql
select public.promote_backfill_dryrun_to_production('IMPB_...', 'sasaran', false);
select public.promote_backfill_dryrun_to_production('IMPB_...', 'pendampingan', false);
```

Parameter ketiga `p_reset_same_batch` default `false`. Gunakan `true` hanya untuk uji staging jika ingin menghapus hasil production base dari batch yang sama sebelum promote ulang.

## Proteksi

- `sasaran_unique_key` unik pada `sasaran`.
- `pendampingan_unique_key` unik pada `pendampingan`.
- `client_mutation_id` unik pada masing-masing tabel.
- Pendampingan wajib punya parent `sasaran_id`.
- RLS aktif tanpa policy publik.

## Batasan

Paket ini belum menyediakan:

- Supabase Auth.
- role KADER/PKB/admin.
- policy RLS operasional.
- read model production.
- dashboard production.
- sync queue Supabase.
