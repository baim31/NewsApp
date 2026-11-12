import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// [KONSEP EDUKATIF: Penanganan State Antarmuka Secara Komprehensif]
///
/// Pengalaman pengguna (UX) yang baik menuntut aplikasi untuk selalu memberikan
/// status visual yang jelas dalam 4 kondisi utama:
/// 1. Sedang Memuat (Loading State) -> [LoadingView]
/// 2. Data Kosong (Empty State) -> [EmptyView]
/// 3. Terjadi Kesalahan (Error State) -> [ErrorView]
/// 4. Data Siap Ditampilkan (Success/Loaded State)
///
/// Seluruh tampilan di bawah ini mematuhi aturan PRD:
/// - Menggunakan styling terpusat dari `app_theme.dart`.
/// - Semua teks berbahasa Indonesia.

/// Tampilan visual saat data sedang dimuat dari sumber data.
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Memuat berita...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan visual saat koleksi data kosong (misalnya pencarian nihil atau bookmark belum ada).
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.title = 'Tidak Ada Berita',
    this.message = 'Belum ada artikel yang sesuai dengan kriteria yang dipilih.',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingXl,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tampilan visual saat terjadi kesalahan/error dalam pengambilan data.
/// Dilengkapi tombol 'Coba Lagi' untuk memicu mekanisme retry.
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    this.title = 'Terjadi Gangguan',
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: const BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

