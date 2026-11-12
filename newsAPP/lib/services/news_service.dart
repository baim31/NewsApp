import '../models/article.dart';

/// [KONSEP EDUKATIF: Interface-Based Architecture & Abstract Class]
///
/// Kelas `NewsService` dibuat sebagai `abstract class` (kontrak antarmuka).
/// Di dalam arsitektur perangkat lunak bersih (Clean Architecture / SOLID - Dependency Inversion),
/// lapisan presentasi (UI & Provider) tidak boleh bergantung langsung pada implementasi teknis
/// detail (misalnya membaca file JSON lokal atau memanggil HTTP API).
///
/// Dengan mendefinisikan interface ini:
/// 1. Saat tahap pengembangan awal/offline, kita mengimplementasikan `MockNewsService`.
/// 2. Di masa depan, jika ingin beralih ke REST API nyata, kita cukup membuat `RemoteNewsService`
///    yang mengimplementasikan `NewsService` tanpa mengubah satu baris pun kode di Provider atau UI.
/// 3. Memudahkan pembuatan unit testing menggunakan mock/fake service.
///
/// [KONSEP EDUKATIF: Future di Dart]
/// `Future<T>` adalah objek yang merepresentasikan hasil dari komputasi asinkron yang belum selesai.
/// Mirip dengan `Promise` di JavaScript. Nilai bertipe `T` akan tersedia di masa mendatang,
/// baik berupa data yang sukses diproses atau sebuah exception/error jika terjadi kegagalan.
abstract class NewsService {
  /// Mengambil daftar artikel berita, dengan parameter kategori opsional.
  Future<List<Article>> getArticles({String? category});

  /// Mengambil detail satu artikel berdasarkan ID unik.
  Future<Article?> getArticleById(String id);

  /// Mencari artikel berdasarkan kata kunci judul atau isi.
  Future<List<Article>> searchArticles(String query);

  /// Mengambil daftar kategori unik yang tersedia dalam data berita.
  Future<List<String>> getCategories();
}

