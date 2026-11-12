# Jurnal Pengembangan Aplikasi Berita (News App)

Dokumen ini mencatat seluruh proses implementasi langkah-demi-langkah, arsitektur yang digunakan, keputusan desain, serta penjelasan konsep pemrograman Flutter/Dart agar Anda dapat memantau dan mempelajari alur pengembangannya.

---

## 📌 Ikhtisar & Arsitektur Proyek

Sesuai dengan **Product Requirements Document (PRD)** dan pengembangan lanjutan:
- **Tujuan:** Aplikasi pembaca berita front-end Flutter yang mendukung **Dual-Mode**:
  1. **Mode Online (NewsAPI.org):** Membaca berita terkini Indonesia secara real-time via REST API.
  2. **Mode Offline/Tiruan (Mock JSON):** Menggunakan data lokal (`assets/mock/articles.json`) tanpa koneksi internet.
- **State Management:** `provider` (hanya package ini yang digunakan).
- **Arsitektur:** Interface-based architecture (Pemisahan UI, State Management, dan Service/Repository).
- **Aturan Ketat Desain:**
  1. Seluruh styling (warna, jarak/padding, tipografi) tersentralisasi di `lib/theme/app_theme.dart`.
  2. Semua teks antarmuka (UI) berbahasa Indonesia.
  3. Komentar edukatif berbahasa Indonesia disertakan pada konsep `Future`, `async/await`, `fromJson`, dan Provider.

```mermaid
graph TD
    subgraph UI ["Lapisan Tampilan (UI Screens & Widgets)"]
        HomeScreen["HomeScreen"]
        DetailScreen["DetailScreen"]
        BookmarkScreen["BookmarkScreen"]
        ArticleCard["ArticleCard"]
        StateViews["StateViews (Loading, Empty, Error)"]
        BookmarkButton["BookmarkButton"]
    end

    subgraph StateManagement ["Lapisan State Management (Providers)"]
        NewsProvider["NewsProvider (ChangeNotifier)"]
        BookmarkProvider["BookmarkProvider (ChangeNotifier)"]
    end

    subgraph Services ["Lapisan Layanan Data (Interface & Implementasi)"]
        NewsService["NewsService (Abstract Class / Interface)"]
        MockNewsService["MockNewsService (Asset JSON Reader)"]
        NewsApiService["NewsApiService (Remote HTTP Client)"]
    end

    subgraph Config ["Konfigurasi API"]
        ApiConfig["ApiConfig (Tempat Taruh API Key)"]
    end

    subgraph Data ["Sumber Data"]
        ArticlesJSON["assets/mock/articles.json"]
        NewsApiEndpoint["https://newsapi.org/v2/top-headlines"]
        ArticleModel["Article Model (fromJson & fromNewsApi)"]
    end

    HomeScreen --> NewsProvider
    HomeScreen --> BookmarkProvider
    DetailScreen --> BookmarkProvider
    BookmarkScreen --> BookmarkProvider
    
    NewsProvider --> NewsService
    NewsService <|.. MockNewsService
    NewsService <|.. NewsApiService
    NewsApiService --> ApiConfig
    NewsApiService --> NewsApiEndpoint
    MockNewsService --> ArticlesJSON
    MockNewsService --> ArticleModel
    NewsApiService --> ArticleModel
```

---

## 📋 Matriks Status Modul & File

| Modul / File | Status | Keterangan & Tujuan |
|---|---|---|
| `pubspec.yaml` | ✅ Selesai | Konfigurasi package `provider`, `http`, dan path `assets/mock/` |
| `assets/mock/articles.json` | ✅ Selesai | 7 artikel berita realistis dalam Bahasa Indonesia lintas kategori |
| `lib/services/api_config.dart` | ✅ Selesai | **Tempat menaruh API Key** dan konfigurasi parameter NewsAPI.org |
| `lib/models/article.dart` | ✅ Selesai | Model artikel + serialisasi `fromJson` (mock) & `fromNewsApi` (adapter online) |
| `lib/theme/app_theme.dart` | ✅ Selesai | Desain sistem terpusat: `AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles` |
| `lib/services/news_service.dart` | ✅ Selesai | Kontrak antarmuka (*abstract class*) `NewsService` (SOLID - DIP) |
| `lib/services/mock_news_service.dart` | ✅ Selesai | Implementasi membaca JSON lokal via `rootBundle`, latensi tiruan, & simulasi error |
| `lib/services/news_api_service.dart` | ✅ Selesai | Implementasi panggilan HTTP ke `newsapi.org`, parsing status kode 200, 401, 429 |
| `lib/providers/news_provider.dart` | ✅ Selesai | State berita: switch sumber data (API/Mock), status UI, filter kategori, pencarian |
| `lib/providers/bookmark_provider.dart` | ✅ Selesai | Pengelola state artikel tersimpan (in-memory) dengan notifikasi reaktif |
| `lib/widgets/state_views.dart` | ✅ Selesai | Widget status terstandar: `LoadingView`, `EmptyView`, dan `ErrorView` (+ tombol retry) |
| `lib/widgets/bookmark_button.dart` | ✅ Selesai | Tombol toggle bookmark reaktif menggunakan `Consumer` dan feedback SnackBar |
| `lib/widgets/article_card.dart` | ✅ Selesai | Kartu pratinjau berita dengan gambar, badge kategori, estimasi waktu baca, & aksi bookmark |
| `lib/screens/home_screen.dart` | ✅ Selesai | Layar utama: pencarian, chip kategori, badge bookmark, tombol alih sumber data |
| `lib/screens/detail_screen.dart` | ✅ Selesai | Layar baca artikel lengkap, avatar penulis, tanggal terbit, dan tautan sumber asli |
| `lib/screens/bookmark_screen.dart` | ✅ Selesai | Layar koleksi artikel tersimpan dengan opsi konfirmasi hapus semua |
| `lib/main.dart` | ✅ Selesai | Titik masuk aplikasi, registrasi `MultiProvider`, konfigurasi tema dan layar awal |
| `test/widget_test.dart` | ✅ Selesai | Pengujian otomatis: unit test model, HTTP service, provider, & widget (9/9 lolos) |

---

## 🛠️ Jurnal Detail Implementasi & Penjelasan Konsep

### [Fase 1] Inisialisasi Proyek & Konfigurasi Lingkungan
- Menjalankan `flutter create . --project-name news_app` dan menambahkan package `provider`.
- Mengonfigurasi `pubspec.yaml` untuk mengizinkan folder `assets/mock/`.

### [Fase 2] Penyiapan Data Tiruan Lokal (`assets/mock/articles.json`)
- Menyusun 7 artikel berita berkualitas tinggi dalam Bahasa Indonesia lintas kategori (*Teknologi, Bisnis, Kesehatan, Sains, Olahraga, Hiburan*).

### [Fase 3] Pemodelan Data & Serialisasi (`lib/models/article.dart`)
- Mendefinisikan class `Article` dengan pola `factory Article.fromJson(Map<String, dynamic> json)`.
- Menggunakan factory constructor untuk konversi tipe data yang aman (*type-safe*).

### [Fase 4] Sentralisasi Desain & Tema (`lib/theme/app_theme.dart`)
- Mengelompokkan seluruh elemen visual ke dalam kelas konstan: `AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles`, dan `AppTheme.lightTheme`.
- Prinsip *Zero Hardcoded Styles*: tidak ada warna atau ukuran teks yang ditulis langsung di dalam widget.

### [Fase 5] Lapisan Abstraksi & Kontrak Layanan (`lib/services/news_service.dart`)
- Mendefinisikan `abstract class NewsService`.
- Menerapkan *Dependency Inversion Principle (DIP)*: Lapisan UI dan Provider tidak bergantung langsung pada sumber data (lokal/API), melainkan pada kontrak antarmuka ini.

### [Fase 6] Manajemen State Reaktif (`lib/providers/`)
- `news_provider.dart`: Mengelola `NewsState` (`loading`, `loaded`, `empty`, `error`), filter kategori, pencarian, dan pemicu pembangunan ulang UI via `notifyListeners()`.
- `bookmark_provider.dart`: Mengelola favorit di memori (*in-memory*) secara terpisah (*Separation of Concerns*).

### [Fase 7 - 10] Widget Reusable, Antarmuka Layar, & Pengujian Awal
- Membangun `LoadingView`, `EmptyView`, `ErrorView`, `ArticleCard`, `BookmarkButton`, `HomeScreen`, `DetailScreen`, dan `BookmarkScreen`.
- Verifikasi awal dengan `flutter analyze` dan `flutter test` (seluruh tes lolos).

---

### [Fase 11] Integrasi Eksternal NewsAPI.org (Layanan Jaringan Nyata)
- **Aktivitas:**
  1. Menambahkan library jaringan resmi: `flutter pub add http`.
  2. Membuat file sentral konfigurasi [`lib/services/api_config.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/services/api_config.dart):
     * Di sinilah pengguna menaruh API Key miliknya pada variabel `apiKey`.
     * Menambahkan opsi `useRemoteApi` untuk memilih mode awal saat aplikasi dijalankan.
  3. Mengimplementasikan **Adapter Pattern** pada model [`lib/models/article.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/models/article.dart):
     * Menambahkan `factory Article.fromNewsApi(...)` untuk memetakan nama field NewsAPI (`urlToImage` -> `imageUrl`, `description` -> `summary`, `source.name` -> fallback `author`).
     * Membersihkan potongan teks otomatis bawaan NewsAPI seperti `[+1200 chars]`.
  4. Membuat implementasi HTTP konkret [`lib/services/news_api_service.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/services/news_api_service.dart):
     * Mengimplementasikan kontrak antarmuka `NewsService`.
     * **Pelajaran Teknis Endpoint NewsAPI:** Endpoint `/v2/top-headlines?country=id` mengembalikan 0 artikel karena feed agregasi headline khusus Indonesia di server NewsAPI sedang kosong. Solusinya, kita menggunakan endpoint `/v2/everything?q=indonesia` yang memiliki lebih dari **4.900 artikel berita aktif** dalam Bahasa Indonesia (Antaranews, dll.), serta fallback otomatis ke headlines jika diperlukan.
     * Memetakan kata kunci kategori pencarian (`teknologi indonesia`, `bisnis indonesia`, dll.).
     * Menangani kode status HTTP:
       - `200 OK`: Sukses parsing JSON.
       - `401 Unauthorized`: API key belum diisi atau salah format.
       - `429 Too Many Requests`: Kuota harian habis (100 req/hari akun gratis).
       - Exception jaringan (saat perangkat offline).
  5. Memperbarui [`lib/providers/news_provider.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/providers/news_provider.dart):
     * Menambahkan method `toggleDataSource()` sehingga pengguna dapat berpindah antara **NewsAPI (Online)** dan **Mock Data (Lokal)** secara langsung hanya dengan menekan satu tombol.
  6. Menambahkan tombol ikon sumber data di AppBar [`lib/screens/home_screen.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/screens/home_screen.dart):
     * Ikon awan (`cloud_done`) saat mode online, ikon berkas (`folder_open`) saat mode lokal.
  7. Memperluas pengujian di [`test/widget_test.dart`](file:///c:/Users/novit/Documents/newsAPP/test/widget_test.dart):
     * 9/9 pengujian lolos tanpa error!

---

## 🔑 Cara Menaruh & Mengaktifkan API Key NewsAPI

1. Dapatkan API Key secara gratis di: **[https://newsapi.org/register](https://newsapi.org/register)**
2. Buka file: **[`lib/services/api_config.dart`](file:///c:/Users/novit/Documents/newsAPP/lib/services/api_config.dart)**
3. Ganti `'YOUR_API_KEY_HERE'` dengan API Key Anda:
   ```dart
   class ApiConfig {
     /// 👉 TARUH API KEY ANDA DI SINI 👈
     static const String apiKey = '4f8a9b2c1d3e4f5a6b7c8d9e0f1a2b3c';
     ...
   }
   ```
4. Simpan file, lalu jalankan aplikasi dengan `flutter run`.

---

## 🚀 Panduan Menjalankan & Menguji Aplikasi

1. **Menjalankan Aplikasi:**
   ```bash
   flutter run
   ```

2. **Menjalankan Linter:**
   ```bash
   flutter analyze
   ```

3. **Menjalankan Pengujian Otomatis:**
   ```bash
   flutter test
   ```
