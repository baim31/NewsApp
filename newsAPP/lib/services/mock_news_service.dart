import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/article.dart';
import 'news_service.dart';

/// Implementasi konkret dari [NewsService] yang membaca data tiruan dari asset lokal.
///
/// Layanan ini memenuhi aturan PRD: tidak menggunakan package `http` dan murni
/// mengandalkan file `assets/mock/articles.json`.
class MockNewsService implements NewsService {
  final String assetPath;
  final Duration simulatedDelay;
  
  /// Flag opsional untuk menguji skenario kegagalan/error pada antarmuka.
  bool shouldSimulateError;

  MockNewsService({
    this.assetPath = 'assets/mock/articles.json',
    this.simulatedDelay = const Duration(milliseconds: 650),
    this.shouldSimulateError = false,
  });

  /// [KONSEP EDUKATIF: async / await di Dart]
  ///
  /// Kata kunci `async` menandai sebuah fungsi agar dapat mengeksekusi operasi asinkron
  /// dan secara otomatis membungkus return value ke dalam objek `Future`.
  ///
  /// Kata kunci `await` digunakan di dalam fungsi `async` untuk menunggu proses asinkron
  /// (seperti membaca file atau simulasi jeda waktu) selesai tanpa memblokir thread UI (Main Thread).
  /// Hal ini menjaga aplikasi tetap responsif dan bebas lag (tidak 'freeze').
  @override
  Future<List<Article>> getArticles({String? category}) async {
    // Simulasi latensi jaringan agar animasi loading di UI dapat teramati dengan jelas
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    // Simulasi kegagalan jaringan untuk menguji tampilan ErrorView & tombol Coba Lagi
    if (shouldSimulateError) {
      throw Exception(
        'Gagal memuat berita: Terjadi gangguan saat membaca data tiruan lokal.',
      );
    }

    try {
      // Membaca konten string dari asset JSON lokal yang didaftarkan di pubspec.yaml
      final jsonString = await rootBundle.loadString(assetPath);

      // Mendekode string JSON menjadi List of Dynamic Map
      final dynamic decoded = json.decode(jsonString);

      if (decoded is List) {
        final list = decoded
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();

        if (category != null && category != 'Semua') {
          return list
              .where((a) => a.category.toLowerCase() == category.toLowerCase())
              .toList();
        }
        return list;
      } else {
        throw const FormatException('Format JSON tidak sesuai: diharapkan berupa array artikel.');
      }
    } catch (e) {
      // Melempar kembali error dengan pesan informatif
      throw Exception('Terjadi kesalahan saat memproses data artikel: $e');
    }
  }

  @override
  Future<Article?> getArticleById(String id) async {
    final articles = await getArticles();
    try {
      return articles.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    final articles = await getArticles();
    if (query.trim().isEmpty) return articles;

    final lowerQuery = query.toLowerCase();
    return articles.where((article) {
      final inTitle = article.title.toLowerCase().contains(lowerQuery);
      final inSummary = article.summary.toLowerCase().contains(lowerQuery);
      final inCategory = article.category.toLowerCase().contains(lowerQuery);
      final inAuthor = article.author.toLowerCase().contains(lowerQuery);
      return inTitle || inSummary || inCategory || inAuthor;
    }).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final articles = await getArticles();
    final categoriesSet = <String>{};
    for (final article in articles) {
      if (article.category.isNotEmpty) {
        categoriesSet.add(article.category);
      }
    }
    return ['Semua', ...categoriesSet.toList()..sort()];
  }
}

