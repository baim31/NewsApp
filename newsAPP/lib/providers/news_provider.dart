import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/api_config.dart';
import '../services/mock_news_service.dart';
import '../services/news_api_service.dart';
import '../services/news_service.dart';

/// Enum untuk mendefinisikan seluruh kemungkinan status antarmuka (UI States).
///
/// Penanganan state secara komprehensif memastikan pengguna selalu menerima feedback
/// visual yang tepat pada setiap tahap lifecycle data.
enum NewsState {
  /// State awal sebelum data diminta.
  initial,

  /// Proses asinkron sedang berlangsung (tampilkan spinner/shimmer).
  loading,

  /// Data berhasil diperoleh dan siap ditampilkan ke layar.
  loaded,

  /// Data berhasil diambil, tetapi hasil pencarian/filter menghasilkan 0 item.
  empty,

  /// Terjadi kesalahan (kesalahan format, file tidak ditemukan, API key invalid, dll).
  error,
}

/// [KONSEP EDUKATIF: ChangeNotifier & Provider di Flutter]
///
/// `ChangeNotifier` adalah kelas bawaan Flutter SDK yang menerapkan Observer Pattern.
/// Ketika terjadi perubahan pada state internal (misalnya `_state` berubah dari `loading` ke `loaded`),
/// kita memanggil `notifyListeners()`.
///
/// Widget yang 'mendengarkan' provider ini (melalui `Consumer` atau `context.watch`)
/// akan secara otomatis dirender ulang (rebuild) untuk mencerminkan data terbaru.
class NewsProvider extends ChangeNotifier {
  NewsService _newsService;
  bool _isUsingRemoteApi;

  NewsState _state = NewsState.initial;
  List<Article> _articles = [];
  List<String> _categories = ['Semua'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _errorMessage = '';

  NewsProvider({NewsService? newsService})
      : _newsService = newsService ??
            (ApiConfig.useRemoteApi ? NewsApiService() : MockNewsService()),
        _isUsingRemoteApi = (newsService != null)
            ? (newsService is NewsApiService)
            : ApiConfig.useRemoteApi;

  // Getters publik (Read-Only)
  NewsState get state => _state;
  bool get isLoading => _state == NewsState.loading;
  bool get isLoaded => _state == NewsState.loaded;
  bool get isEmpty => _state == NewsState.empty;
  bool get isError => _state == NewsState.error;

  bool get isUsingRemoteApi => _isUsingRemoteApi;
  String get currentSourceName =>
      _isUsingRemoteApi ? 'NewsAPI.org (Online)' : 'Data Tiruan Lokal (Mock)';

  List<String> get categories => List.unmodifiable(_categories);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;

  /// Mengembalikan daftar artikel yang telah disaring berdasarkan kategori dan pencarian.
  List<Article> get displayedArticles {
    return _articles.where((article) {
      // Jika mode online, API sudah mengembalikan artikel sesuai kategori terpilih
      final matchesCategory = _isUsingRemoteApi ||
          _selectedCategory == 'Semua' ||
          article.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.author.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// [KONSEP EDUKATIF: Asynchronous State Lifecycle]
  ///
  /// Alur pemuatan data:
  /// 1. Set status menjadi `loading` dan panggil `notifyListeners()` agar UI menampilkan indikator loading.
  /// 2. Jalankan pemanggilan asinkron `_newsService.getArticles()` menggunakan `await`.
  /// 3. Jika berhasil, simpan data, perbarui kategori, dan ubah status ke `loaded` atau `empty`.
  /// 4. Jika gagal, tangkap exception di blok `catch`, simpan pesan error, dan ubah status ke `error`.
  /// 5. Selalu panggil `notifyListeners()` di akhir agar UI menyelaraskan tampilannya.
  Future<void> fetchArticles({bool isRefresh = false}) async {
    if (!isRefresh) {
      _state = NewsState.loading;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      final results = await _newsService.getArticles(
        category: _selectedCategory != 'Semua' ? _selectedCategory : null,
      );
      final categoryList = await _newsService.getCategories();

      _articles = results;
      _categories = categoryList;

      if (_articles.isEmpty) {
        _state = NewsState.empty;
      } else {
        _state = NewsState.loaded;
      }
      _errorMessage = '';
    } catch (e) {
      _state = NewsState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Memilih kategori untuk memfilter daftar artikel.
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;

    // Pada mode Online, panggil API untuk memuat berita kategori spesifik dari NewsAPI
    if (_isUsingRemoteApi) {
      fetchArticles();
    } else {
      _evaluateEmptyState();
      notifyListeners();
    }
  }

  /// Mengatur kata kunci pencarian berita.
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _evaluateEmptyState();
    notifyListeners();
  }

  /// Menghapus kata kunci pencarian.
  void clearSearch() {
    _searchQuery = '';
    _evaluateEmptyState();
    notifyListeners();
  }

  /// Mengevaluasi apakah hasil filter menghasilkan daftar kosong.
  void _evaluateEmptyState() {
    if (_articles.isNotEmpty && displayedArticles.isEmpty) {
      _state = NewsState.empty;
    } else if (_articles.isNotEmpty) {
      _state = NewsState.loaded;
    }
  }

  /// Beralih sumber data antara NewsAPI (Online) dan Mock Data (Lokal).
  void toggleDataSource() {
    if (_isUsingRemoteApi) {
      _newsService = MockNewsService();
      _isUsingRemoteApi = false;
    } else {
      _newsService = NewsApiService();
      _isUsingRemoteApi = true;
    }
    _selectedCategory = 'Semua';
    _searchQuery = '';
    fetchArticles();
  }

  /// Fungsi untuk mencoba kembali memuat data jika terjadi error.
  Future<void> retry() async {
    await fetchArticles();
  }

  /// Fitur edukasi: Simulasi error untuk mendemonstrasikan ErrorView dan tombol Retry (pada mode Mock).
  void toggleMockErrorSimulation() {
    final service = _newsService;
    if (service is MockNewsService) {
      service.shouldSimulateError = !service.shouldSimulateError;
      fetchArticles();
    } else {
      // Jika di mode remote API, toggle ke mock dulu untuk simulasi error
      _newsService = MockNewsService(shouldSimulateError: true);
      _isUsingRemoteApi = false;
      fetchArticles();
    }
  }
}
