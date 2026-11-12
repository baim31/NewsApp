import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/article_card.dart';
import '../widgets/state_views.dart';

/// Layar Koleksi Artikel Tersimpan (Bookmark).
///
/// Menggunakan `Consumer<BookmarkProvider>` agar UI diperbarui secara real-time
/// saat artikel disimpan atau dihapus dari daftar favorit.
class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  void _showClearConfirmationDialog(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
        ),
        title: const Text(
          'Hapus Semua Bookmark?',
          style: AppTextStyles.titleLarge,
        ),
        content: const Text(
          'Seluruh daftar artikel yang Anda simpan akan dihapus dari memori.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              provider.clearAll();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.textPrimary,
                  content: Text('Semua bookmark berhasil dihapus.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Tersimpan'),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              if (bookmarkProvider.bookmarkedArticles.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Hapus Semua Bookmark',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearConfirmationDialog(context, bookmarkProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          final bookmarks = bookmarkProvider.bookmarkedArticles;

          if (bookmarks.isEmpty) {
            return EmptyView(
              icon: Icons.bookmarks_outlined,
              title: 'Belum Ada Bookmark',
              message:
                  'Tandai artikel favorit Anda dengan ikon bookmark di beranda untuk membacanya nanti di sini.',
              actionLabel: 'Jelajahi Berita',
              onAction: () => Navigator.pop(context),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Menampilkan ${bookmarks.length} artikel tersimpan di memori',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: AppSpacing.screenPadding,
                  itemCount: bookmarks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final article = bookmarks[index];
                    return ArticleCard(article: article);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

