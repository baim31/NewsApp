import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';

/// [KONSEP EDUKATIF: Widget Reaktif Menggunakan Provider]
///
/// Widget ini mendengarkan perubahan status bookmark dari `BookmarkProvider`.
/// Dengan membungkus tombol menggunakan `Consumer<BookmarkProvider>`, hanya tombol ini
/// yang akan dibangun ulang (rebuild) saat status bookmark suatu artikel berubah,
/// tanpa memicu render ulang yang tidak perlu pada widget induk di sekitarnya.
class BookmarkButton extends StatelessWidget {
  final Article article;
  final double size;
  final bool showFeedbackSnackBar;

  const BookmarkButton({
    super.key,
    required this.article,
    this.size = 24.0,
    this.showFeedbackSnackBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final isBookmarked = bookmarkProvider.isBookmarked(article.id);

        return IconButton(
          iconSize: size,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: isBookmarked ? 'Hapus dari bookmark' : 'Simpan ke bookmark',
          icon: Icon(
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: isBookmarked ? AppColors.bookmarkActive : AppColors.textSecondary,
          ),
          onPressed: () {
            final wasAdded = bookmarkProvider.toggleBookmark(article);

            if (showFeedbackSnackBar) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: wasAdded ? AppColors.primary : AppColors.textPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusSm,
                  ),
                  content: Text(
                    wasAdded
                        ? 'Artikel berhasil disimpan ke bookmark.'
                        : 'Artikel dihapus dari bookmark.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  duration: const Duration(milliseconds: 1400),
                ),
              );
            }
          },
        );
      },
    );
  }
}

