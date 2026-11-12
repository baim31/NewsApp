import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/news_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// [KONSEP EDUKATIF: Titik Masuk Utama (Main Entry Point) & MultiProvider]
///
/// Fungsi `main()` adalah gerbang utama eksekusi program Flutter.
///
/// `MultiProvider` ditempatkan pada puncak pohon widget (root of widget tree).
/// Hal ini memastikan bahwa seluruh layar turunan (`HomeScreen`, `DetailScreen`, `BookmarkScreen`)
/// serta widget komponen di dalamnya dapat mengakses data dan state yang dikelola oleh:
/// 1. [NewsProvider] (Manajemen data berita, filter kategori, pencarian, dan status loading/error)
/// 2. [BookmarkProvider] (Manajemen daftar artikel tersimpan di memori)
///
/// Pendekatan ini memenuhi aturan arsitektur PRD:
/// - State Management eksklusif menggunakan Provider.
/// - In-memory state yang reaktif dan terisolasi.
/// - Tema tersentralisasi di `AppTheme`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'News App - Kabar Nusantara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
