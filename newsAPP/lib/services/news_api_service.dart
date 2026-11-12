import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import 'api_config.dart';
import 'news_service.dart';

/// [KONSEP EDUKATIF: Implementasi Layanan Jaringan Nyata (Remote HTTP Service)]
///
/// Kelas `NewsApiService` mengimplementasikan kontrak [NewsService].
/// Inilah kekuatan dari Interface-Based Architecture / Dependency Inversion:
/// Komponen UI dan Provider tidak peduli apakah data berasal dari asset lokal ([MockNewsService])
/// atau panggilan HTTP internet nyata ([NewsApiService]), karena keduanya memiliki method yang sama.
class NewsApiService implements NewsService {
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Daftar kategori yang ditampilkan di antarmuka aplikasi.
  @override
  Future<List<String>> getCategories() async {
    return [
      'Semua',
      'Teknologi',
      'Bisnis',
      'Kesehatan',
      'Sains',
      'Olahraga',
      'Hiburan',
    ];
  }

  /// [KONSEP EDUKATIF: Pemilihan Endpoint & Query NewsAPI.org]
  ///
  /// Catatan Teknis NewsAPI:
  /// Endpoint `/v2/top-headlines?country=id` sering kali mengembalikan 0 artikel
  /// karena NewsAPI tidak selalu mengagregasi feed headline lokal Indonesia.
  /// Namun, endpoint `/v2/everything?q=indonesia` menyediakan ribuan artikel berita
  /// aktif dari media ternama (Antaranews, dll.).
  ///
  /// Oleh karena itu, kita memprioritaskan `/v2/everything` agar data tidak pernah kosong,
  /// dan menyediakan fallback ke `/v2/top-headlines` jika diperlukan.
  @override
  Future<List<Article>> getArticles({String? category}) async {
    _validateApiKey();

    final categoryQueries = {
      'Teknologi': 'teknologi indonesia',
      'Bisnis': 'bisnis indonesia OR ekonomi indonesia',
      'Kesehatan': 'kesehatan indonesia',
      'Sains': 'sains indonesia',
      'Olahraga': 'olahraga indonesia OR timnas indonesia',
      'Hiburan': 'hiburan indonesia OR film indonesia',
    };

    final query = (category != null && category != 'Semua')
        ? (categoryQueries[category] ?? '$category indonesia')
        : 'indonesia';

    final everythingUri = Uri.parse('${ApiConfig.baseUrl}/everything').replace(
      queryParameters: {
        'q': query,
        'sortBy': 'publishedAt',
        'pageSize': ApiConfig.pageSize.toString(),
        'apiKey': ApiConfig.apiKey.trim(),
      },
    );

    final articles = await _fetchFromUri(everythingUri, defaultCategory: category ?? 'Umum');

    // Jika everything kosong (misal kuota atau filter), coba top-headlines sebagai fallback
    if (articles.isEmpty) {
      final headlinesUri = Uri.parse('${ApiConfig.baseUrl}/top-headlines').replace(
        queryParameters: {
          'country': ApiConfig.defaultCountry,
          'pageSize': ApiConfig.pageSize.toString(),
          'apiKey': ApiConfig.apiKey.trim(),
        },
      );
      return await _fetchFromUri(headlinesUri, defaultCategory: category ?? 'Umum');
    }

    return articles;
  }

  /// Mengambil detail artikel berdasarkan ID (URL).
  @override
  Future<Article?> getArticleById(String id) async {
    final articles = await getArticles();
    try {
      return articles.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  /// [KONSEP EDUKATIF: Pencarian API Eksternal]
  ///
  /// Melakukan pencarian kata kunci ke NewsAPI via `/v2/everything`.
  @override
  Future<List<Article>> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      return getArticles();
    }

    _validateApiKey();

    final uri = Uri.parse('${ApiConfig.baseUrl}/everything').replace(
      queryParameters: {
        'q': query.trim(),
        'sortBy': 'relevancy',
        'pageSize': ApiConfig.pageSize.toString(),
        'apiKey': ApiConfig.apiKey.trim(),
      },
    );

    return _fetchFromUri(uri, defaultCategory: 'Pencarian');
  }

  /// Helper internal untuk mengeksekusi request HTTP dan menangani berbagai status kode.
  Future<List<Article>> _fetchFromUri(Uri uri, {required String defaultCategory}) async {
    try {
      if (kDebugMode) {
        debugPrint('[NewsAPI] Request: $uri');
      }

      final response = await _client.get(uri);

      // Status 200 OK: Permintaan berhasil
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] != 'ok') {
          throw Exception(body['message'] ?? 'Gagal memuat berita dari NewsAPI.');
        }

        final List<dynamic> articlesJson = body['articles'] as List<dynamic>? ?? [];

        if (kDebugMode) {
          debugPrint('[NewsAPI] Menerima ${articlesJson.length} artikel dari server.');
        }

        // Konversi setiap item JSON menjadi objek Article model
        // Saring artikel yang dihapus (title == '[Removed]')
        return articlesJson
            .where((item) =>
                item is Map<String, dynamic> &&
                item['title'] != null &&
                item['title'] != '[Removed]')
            .map((item) => Article.fromNewsApi(
                  item as Map<String, dynamic>,
                  category: defaultCategory,
                ))
            .toList();
      }

      // Status 401 Unauthorized: API Key salah / tidak ada
      if (response.statusCode == 401) {
        throw Exception(
          'API Key tidak valid atau belum diatur.\nSilakan periksa dan masukkan API Key Anda di file lib/services/api_config.dart.',
        );
      }

      // Status 429 Too Many Requests: Kuota habis (maksimal 100 req/hari untuk akun gratis)
      if (response.statusCode == 429) {
        throw Exception(
          'Batas kuota harian NewsAPI tercapai (100 permintaan/hari untuk akun gratis).',
        );
      }

      // Status Error HTTP lainnya
      throw Exception(
        'Gagal memuat data dari server (HTTP ${response.statusCode}).',
      );
    } on http.ClientException catch (e) {
      // Error koneksi internet lokal (misal: offline / DNS failure)
      throw Exception(
        'Tidak dapat terhubung ke internet. Periksa koneksi Anda.\nDetail: ${e.message}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Memeriksa apakah API Key sudah diatur sebelum melakukan panggilan jaringan.
  void _validateApiKey() {
    if (!ApiConfig.isApiKeyConfigured) {
      throw Exception(
        'Kunci API (API Key) belum dikonfigurasi!\n\n'
        'Langkah aktivasi:\n'
        '1. Dapatkan API key gratis di https://newsapi.org\n'
        '2. Buka file: lib/services/api_config.dart\n'
        '3. Masukkan key pada: static const String apiKey = \'...\';',
      );
    }
  }
}
