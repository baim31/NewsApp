import 'package:flutter/foundation.dart';
import '../models/article.dart';

/// [KONSEP EDUKATIF: In-Memory State Management]
///
/// Sesuai batasan teknis PRD, aplikasi ini menyimpan data bookmark secara murni di memori RAM
/// (in-memory state) selama siklus hidup aplikasi berjalan, tanpa dependensi ke SQLite/Hive/SharedPreferences.
///
/// [KONSEP EDUKATIF: Pemisahan Tanggung Jawab (Separation of Concerns)]
/// Logika penandaan artikel favorit dipisahkan ke dalam `BookmarkProvider` tersendiri,
/// bukan dicampur aduk ke dalam `NewsProvider`. Hal ini memastikan:
/// 1. Kode modular dan mudah diuji (testable).
/// 2. Widget bookmark hanya perlu mendengarkan `BookmarkProvider`, sehingga `HomeScreen`
///    tidak perlu merender ulang seluruh daftar berita saat hanya satu artikel yang dibookmark.
class BookmarkProvider extends ChangeNotifier {
  /// Koleksi artikel yang ditandai sebagai favorit (in-memory).
  /// Menggunakan Map dengan key `id` untuk akses O(1) yang cepat saat memeriksa status bookmark.
  final Map<String, Article> _bookmarkedMap = {};

  /// Mengembalikan daftar artikel yang disimpan dalam bentuk List yang tidak dapat diubah dari luar.
  List<Article> get bookmarkedArticles => _bookmarkedMap.values.toList();

  /// Jumlah total artikel yang disimpan.
  int get count => _bookmarkedMap.length;

  /// Memeriksa apakah suatu artikel dengan ID tertentu sudah ada di bookmark.
  bool isBookmarked(String articleId) {
    return _bookmarkedMap.containsKey(articleId);
  }

  /// Menambah atau menghapus artikel dari bookmark (toggle).
  ///
  /// Mengembalikan `true` jika artikel baru saja ditambahkan ke bookmark,
  /// dan `false` jika artikel baru saja dihapus dari bookmark.
  bool toggleBookmark(Article article) {
    final exists = _bookmarkedMap.containsKey(article.id);
    if (exists) {
      _bookmarkedMap.remove(article.id);
    } else {
      _bookmarkedMap[article.id] = article;
    }

    // Memberitahu seluruh widget yang mengamati BookmarkProvider
    notifyListeners();
    return !exists;
  }

  /// Menghapus artikel dari bookmark berdasarkan ID.
  void removeBookmark(String articleId) {
    if (_bookmarkedMap.containsKey(articleId)) {
      _bookmarkedMap.remove(articleId);
      notifyListeners();
    }
  }

  /// Menghapus seluruh bookmark yang tersimpan.
  void clearAll() {
    if (_bookmarkedMap.isNotEmpty) {
      _bookmarkedMap.clear();
      notifyListeners();
    }
  }
}

