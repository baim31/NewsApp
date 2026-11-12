import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import '../widgets/bookmark_button.dart';

/// Layar Detail Artikel Berita.
///
/// Menampilkan isi berita secara komprehensif, informasi penulis, tanggal rilis,
/// serta tombol aksi bookmark di bagian AppBar.
class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: BookmarkButton(
              article: article,
              size: 26,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori & Estimasi Waktu Baca
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
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
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${article.readingTimeMinutes} Menit Baca',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Judul Artikel Lengkap
            Text(
              article.title,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            // Metadata: Penulis & Tanggal Terbit
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.author,
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          'Diterbitkan pada ${article.formattedDate}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Gambar Utama Berita
            ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: article.imageUrl.trim().isNotEmpty
                    ? Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
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
                                size: 48,
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
                            size: 56,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Kutipan / Ringkasan (Lead Paragraph)
            Container(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                article.summary,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Divider(),
            const SizedBox(height: AppSpacing.lg),

            // Isi Artikel (Mendukung Multi-paragraf)
            ...article.content.split('\n\n').map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  paragraph,
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Footer Catatan Sumber
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    article.sourceUrl != null
                        ? Icons.language_rounded
                        : Icons.verified_user_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      article.sourceUrl != null
                          ? 'Sumber: ${article.sourceUrl}'
                          : 'Sumber: Data Tiruan Lokal (Mock)',
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

