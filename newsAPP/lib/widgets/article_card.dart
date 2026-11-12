import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';
import 'bookmark_button.dart';

/// Kartu pratinjau berita yang dapat diklik untuk membuka halaman detail.
///
/// Mematuhi aturan desain terpusat:
/// - Menggunakan CardTheme & AppTheme.
/// - Tidak ada warna hardcoded langsung di dalam widget.
/// - Menampilkan fallback jika gambar jaringan gagal dimuat.
class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Gambar Utama Artikel
              ClipRRect(
                borderRadius: AppRadius.radiusSm,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: article.imageUrl.trim().isNotEmpty
                      ? Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 36,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.newspaper_rounded,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Baris Kategori & Estimasi Waktu Baca
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      article.category,
                      style: AppTextStyles.categoryBadge,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${article.readingTimeMinutes} mnt baca',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Judul Artikel
              Text(
                article.title,
                style: AppTextStyles.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Ringkasan Pendek
              Text(
                article.summary,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),

              // Baris Penulis, Tanggal & Tombol Bookmark
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${article.author} • ${article.formattedDate}',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  BookmarkButton(
                    article: article,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

