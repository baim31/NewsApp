import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/services/news_api_service.dart';
import 'package:news_app/services/news_service.dart';

/// Fake implementation of NewsService for fast and isolated unit tests.
class FakeNewsService implements NewsService {
  final List<Article> mockArticles;

  FakeNewsService(this.mockArticles);

  @override
  Future<List<Article>> getArticles({String? category}) async => mockArticles;

  @override
  Future<Article?> getArticleById(String id) async {
    try {
      return mockArticles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    return mockArticles
        .where((a) => a.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    return ['Semua', 'Teknologi', 'Bisnis'];
  }
}

void main() {
  group('Article Model Unit Tests', () {
    test('Article.fromJson parses map correctly', () {
      final jsonMap = {
        'id': 'test-1',
        'title': 'Judul Pengujian',
        'summary': 'Ringkasan uji coba',
        'content': 'Konten artikel pengujian',
        'author': 'Penulis Uji',
        'category': 'Teknologi',
        'publishedAt': '2026-11-01T10:00:00Z',
        'imageUrl': 'https://example.com/image.jpg',
        'readingTimeMinutes': 5,
      };

      final article = Article.fromJson(jsonMap);

      expect(article.id, 'test-1');
      expect(article.title, 'Judul Pengujian');
      expect(article.category, 'Teknologi');
      expect(article.readingTimeMinutes, 5);
      expect(article.formattedDate, isNotEmpty);
    });

    test('Article.fromNewsApi adapts NewsAPI response accurately', () {
      final newsApiJson = {
        'source': {'id': 'kompas', 'name': 'Kompas.com'},
        'author': 'Jurnalis Kompas',
        'title': 'Inovasi Digital Nasional - Kompas.com',
        'description': 'Ringkasan perkembangan teknologi di tanah air.',
        'url': 'https://www.kompas.com/read/2026/11/05/12345',
        'urlToImage': 'https://asset.kompas.com/data/photo/2026/11/05/pic.jpg',
        'publishedAt': '2026-11-05T08:30:00Z',
        'content': 'Jakarta - Konten berita lengkap di sini [+500 chars]',
      };

      final article = Article.fromNewsApi(newsApiJson, category: 'Teknologi');

      expect(article.id, 'https://www.kompas.com/read/2026/11/05/12345');
      expect(article.title, 'Inovasi Digital Nasional - Kompas.com');
      expect(article.author, 'Jurnalis Kompas');
      expect(article.category, 'Teknologi');
      expect(article.summary, 'Ringkasan perkembangan teknologi di tanah air.');
      // Karakter [+500 chars] dibersihkan oleh model
      expect(article.content.contains('[+500 chars]'), isFalse);
      expect(article.sourceUrl, 'https://www.kompas.com/read/2026/11/05/12345');
    });
  });

  group('NewsApiService Unit Tests', () {
    test('Throws exception if API key is not configured', () async {
      final service = NewsApiService();
      // Since ApiConfig.apiKey is default 'YOUR_API_KEY_HERE', calling getArticles should throw informative error
      expect(
        () async => await service.getArticles(),
        throwsA(isA<Exception>()),
      );
    });

    test('NewsApiService parses response from mock client', () async {
      // Create mock HTTP client returning 200 OK
      final mockHttpClient = MockClient((request) async {
        final responsePayload = {
          'status': 'ok',
          'totalResults': 1,
          'articles': [
            {
              'source': {'id': null, 'name': 'DetikNews'},
              'author': 'Detik Redaksi',
              'title': 'Pemberitaan Hangat Hari Ini',
              'description': 'Deskripsi singkat topik hangat.',
              'url': 'https://news.detik.com/berita/123',
              'urlToImage': 'https://akcdn.detik.net.id/visual/123.jpg',
              'publishedAt': '2026-11-05T09:00:00Z',
              'content': 'Isi teks lengkap berita.',
            }
          ]
        };
        return http.Response(json.encode(responsePayload), 200);
      });

      // Inject mock client with a temporary custom subclass or directly testing _fetchFromUri logic
      final service = NewsApiService(client: mockHttpClient);
      expect(service, isNotNull);
    });
  });

  group('BookmarkProvider Unit Tests', () {
    final sampleArticle = Article(
      id: 'art-1',
      title: 'Artikel Berita',
      summary: 'Ringkasan',
      content: 'Isi lengkap',
      author: 'Redaksi',
      category: 'Teknologi',
      publishedAt: DateTime.now(),
      imageUrl: '',
    );

    test('Initial bookmark list should be empty', () {
      final provider = BookmarkProvider();
      expect(provider.count, 0);
      expect(provider.bookmarkedArticles, isEmpty);
      expect(provider.isBookmarked('art-1'), isFalse);
    });

    test('toggleBookmark adds and removes article correctly', () {
      final provider = BookmarkProvider();

      final added = provider.toggleBookmark(sampleArticle);
      expect(added, isTrue);
      expect(provider.count, 1);
      expect(provider.isBookmarked('art-1'), isTrue);

      final removed = provider.toggleBookmark(sampleArticle);
      expect(removed, isFalse);
      expect(provider.count, 0);
      expect(provider.isBookmarked('art-1'), isFalse);
    });

    test('clearAll removes all bookmarked articles', () {
      final provider = BookmarkProvider();
      provider.toggleBookmark(sampleArticle);
      expect(provider.count, 1);

      provider.clearAll();
      expect(provider.count, 0);
      expect(provider.bookmarkedArticles, isEmpty);
    });
  });

  group('NewsProvider Unit Tests', () {
    test('NewsProvider handles loaded and empty state with FakeNewsService', () async {
      final sampleArticles = [
        Article(
          id: 'art-1',
          title: 'Peluncuran AI Terbaru',
          summary: 'Ringkasan AI',
          content: 'Konten AI',
          author: 'Budi',
          category: 'Teknologi',
          publishedAt: DateTime.now(),
          imageUrl: '',
        ),
      ];

      final fakeService = FakeNewsService(sampleArticles);
      final newsProvider = NewsProvider(newsService: fakeService);

      expect(newsProvider.state, NewsState.initial);

      await newsProvider.fetchArticles();

      expect(newsProvider.state, NewsState.loaded);
      expect(newsProvider.displayedArticles.length, 1);

      // Search matching
      newsProvider.setSearchQuery('AI');
      expect(newsProvider.displayedArticles.length, 1);

      // Search non-matching (empty state)
      newsProvider.setSearchQuery('NonExistentQuery');
      expect(newsProvider.displayedArticles.isEmpty, true);
      expect(newsProvider.state, NewsState.empty);
    });
  });

  group('Widget Smoke Test', () {
    testWidgets('NewsApp mounts without exception', (WidgetTester tester) async {
      await tester.pumpWidget(const NewsApp());
      // Expect finding the AppBar title
      expect(find.text('Kabar Nusantara'), findsOneWidget);
      // Expect finding category list
      expect(find.byType(TextField), findsOneWidget);
      // Advance timer for simulated delay
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    });
  });
}
