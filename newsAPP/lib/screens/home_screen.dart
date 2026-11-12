import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';
import 'bookmark_screen.dart';

/// Layar Utama Aplikasi Berita (HomeScreen).
///
/// Mengintegrasikan:
/// - Pencarian judul/isi berita secara real-time.
/// - Filter kategori berita horizontal.
/// - Penanganan 4 state antarmuka (Loading, Empty, Error, Loaded).
/// - Navigasi ke Layar Bookmark dengan lencana (badge) jumlah artikel tersimpan.
/// - Tombol penggantian sumber data (NewsAPI Online / Mock Lokal).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // [KONSEP EDUKATIF: Pemicuan Asinkron Awal pada Siklus Hidup Widget]
    // Memanggil pemuatan data awal setelah frame pertama selesai dirender.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kabar Nusantara'),
            Consumer<NewsProvider>(
              builder: (context, provider, _) => Text(
                'Sumber: ${provider.currentSourceName}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: provider.isUsingRemoteApi
                      ? AppColors.primaryLight
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Penggantian Sumber Data (Online API <-> Mock Lokal)
          Consumer<NewsProvider>(
            builder: (context, provider, _) => IconButton(
              tooltip: provider.isUsingRemoteApi
                  ? 'Beralih ke Data Tiruan Lokal (Mock)'
                  : 'Beralih ke NewsAPI.org (Online)',
              icon: Icon(
                provider.isUsingRemoteApi
                    ? Icons.cloud_done_rounded
                    : Icons.folder_open_rounded,
                color: provider.isUsingRemoteApi
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
              ),
              onPressed: () {
                provider.toggleDataSource();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                    content: Text(
                      'Beralih ke: ${provider.currentSourceName}',
                    ),
                    duration: const Duration(milliseconds: 1400),
                  ),
                );
              },
            ),
          ),
          // Tombol Edukasi: Menguji UI Skenario Error & Retry
          IconButton(
            tooltip: 'Uji Simulasi Error / Retry',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () {
              context.read<NewsProvider>().toggleMockErrorSimulation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                  content: Text('Simulasi kegagalan data diaktifkan/dinonaktifkan.'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
          ),
          // Tombol Navigasi ke Layar Bookmark dengan Badge
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final count = bookmarkProvider.count;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Buka Artikel Tersimpan',
                    icon: const Icon(Icons.bookmarks_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookmarkScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // Bagian Header: Input Pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<NewsProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari topik berita, penulis, atau kata kunci...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<NewsProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Bagian Filter Kategori Horizontal
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              final categories = newsProvider.categories;
              final selectedCategory = newsProvider.selectedCategory;

              return SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusFull,
                      ),
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          newsProvider.selectCategory(category);
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),

          // Bagian Utama: Status Tampilan (Loading / Error / Empty / Loaded)
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                // 1. Loading State
                if (newsProvider.isLoading) {
                  return const LoadingView(
                    message: 'Memuat artikel berita terbaru...',
                  );
                }

                // 2. Error State
                if (newsProvider.isError) {
                  return ErrorView(
                    message: newsProvider.errorMessage,
                    onRetry: () => newsProvider.retry(),
                  );
                }

                // 3. Empty State
                if (newsProvider.isEmpty || newsProvider.displayedArticles.isEmpty) {
                  return EmptyView(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak Ada Berita Ditemukan',
                    message: newsProvider.searchQuery.isNotEmpty
                        ? 'Tidak ditemukan artikel yang memuat "${newsProvider.searchQuery}".'
                        : 'Belum ada artikel pada kategori "${newsProvider.selectedCategory}".',
                    actionLabel: 'Tampilkan Semua Berita',
                    onAction: () {
                      _searchController.clear();
                      newsProvider.clearSearch();
                      newsProvider.selectCategory('Semua');
                    },
                  );
                }

                // 4. Loaded State: Menampilkan Daftar Artikel dengan Pull-to-Refresh
                final articles = newsProvider.displayedArticles;
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await newsProvider.fetchArticles(isRefresh: true);
                  },
                  child: ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: articles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(article: article);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
