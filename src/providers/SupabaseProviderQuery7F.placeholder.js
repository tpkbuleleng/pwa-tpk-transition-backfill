/**
 * Paket 7-F — Supabase Query Provider Placeholder
 *
 * File ini contoh mapping provider ke RPC Supabase.
 * Jangan wiring ke UI utama sebelum paket SupabaseProvider/Auth/RLS resmi.
 *
 * UI tetap memakai:
 *   backend.querySasaranLite(...)
 *
 * Bukan:
 *   supabase.rpc(...)
 */

export function attachSupabaseQueryMethods7F(provider, supabaseClient) {
  if (!provider) {
    throw new Error('Provider wajib diisi.');
  }

  if (!supabaseClient) {
    throw new Error('supabaseClient belum tersedia. Jangan aktifkan file ini sebelum paket SupabaseProvider resmi.');
  }

  provider.querySasaranLite = async function querySasaranLite(filters = {}) {
    const { data, error } = await supabaseClient.rpc('query_sasaran_lite_7f', {
      p_id_kecamatan: filters.id_kecamatan || null,
      p_id_tim: filters.id_tim || null,
      p_jenis_sasaran: filters.jenis_sasaran || null,
      p_is_baduta_prioritas:
        typeof filters.is_baduta_prioritas === 'boolean' ? filters.is_baduta_prioritas : null,
      p_search: filters.search || null,
      p_limit: filters.limit || 50,
      p_offset: filters.offset || 0
    });

    if (error) throw error;
    return data;
  };

  provider.queryPendampinganLite = async function queryPendampinganLite(filters = {}) {
    const { data, error } = await supabaseClient.rpc('query_pendampingan_lite_7f', {
      p_id_kecamatan: filters.id_kecamatan || null,
      p_id_tim: filters.id_tim || null,
      p_periode_bulan: filters.periode_bulan || null,
      p_tahun_laporan: filters.tahun_laporan || null,
      p_jenis_sasaran: filters.jenis_sasaran || null,
      p_is_baduta_prioritas_saat_pendampingan:
        typeof filters.is_baduta_prioritas_saat_pendampingan === 'boolean'
          ? filters.is_baduta_prioritas_saat_pendampingan
          : null,
      p_search: filters.search || null,
      p_limit: filters.limit || 50,
      p_offset: filters.offset || 0
    });

    if (error) throw error;
    return data;
  };

  provider.getProductionBasicSummary = async function getProductionBasicSummary() {
    const { data, error } = await supabaseClient.rpc('get_production_basic_summary_7f');
    if (error) throw error;
    return data;
  };

  provider.checkProductionQueryContractHealth = async function checkProductionQueryContractHealth() {
    const { data, error } = await supabaseClient.rpc('check_production_query_contract_health_7f');
    if (error) throw error;
    return data;
  };

  return provider;
}

export default attachSupabaseQueryMethods7F;
