// =====================================================================
// PANDUAN KONFIGURASI API (NewsAPI.org)
// =====================================================================
// File ini adalah tempat sentral untuk mengatur koneksi API eksternal.
//
// CARA MENDAPATKAN API KEY:
// 1. Buka https://newsapi.org/register
// 2. Daftarkan akun gratis (memerlukan email).
// 3. Salin 32 karakter API Key yang diberikan di dashboard Anda.
//
// TEMPAT MENARUH API KEY:
// Tempelkan API Key Anda pada variabel [apiKey] di bawah ini.
// Ganti string 'YOUR_API_KEY_HERE' dengan kunci API Anda.
// Contoh: static const String apiKey = '4f8a9b2c1d3e4f5a6b7c8d9e0f1a2b3c';
// =====================================================================

class ApiConfig {
  /// 👉 TARUH API KEY ANDA DI SINI 👈
  static const String apiKey = 'f8f5c1f221a44bf5a7e8e9791c0a0d01';

  /// Mode Sumber Data Awal:
  /// - `true`  : Mengambil berita langsung dari internet (NewsAPI.org)
  /// - `false` : Menggunakan data tiruan lokal (assets/mock/articles.json)
  static const bool useRemoteApi = true;

  /// Base URL endpoint NewsAPI
  static const String baseUrl = 'https://newsapi.org/v2';

  /// Kode negara default: 'id' untuk Indonesia.
  /// Anda juga dapat menggantinya dengan 'us', 'gb', 'jp', dll.
  static const String defaultCountry = 'id';

  /// Ukuran halaman data (jumlah artikel per panggilan API)
  static const int pageSize = 20;

  /// Helper untuk mengecek apakah API key sudah diisi atau masih menggunakan placeholder.
  static bool get isApiKeyConfigured =>
      apiKey.trim().isNotEmpty && apiKey.trim() != 'YOUR_API_KEY_HERE';
}
