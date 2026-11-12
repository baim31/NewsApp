import 'package:flutter/material.dart';

/// Sentralisasi Desain & Tema Aplikasi Berita (News App).
///
/// Sesuai PRD, file ini menampung seluruh konfigurasi warna, ukuran teks (tipografi),
/// serta jarak/padding agar tidak ada styling atau hardcoded color langsung di dalam widget.
///
/// Keuntungan pendekatan ini:
/// 1. Single Source of Truth: Perubahan gaya desain hanya dilakukan di satu tempat.
/// 2. Konsistensi UI: Seluruh komponen memiliki nuansa visual yang harmonis.
/// 3. Memudahkan implementasi mode gelap (dark mode) di masa depan.

class AppColors {
  // Warna Utama & Aksen
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Blue
  static const Color primaryVariant = Color(0xFF172554);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFF59E0B); // Amber hangat

  // Latar Belakang & Permukaan
  static const Color background = Color(0xFFF8FAFC); // Slate sangat muda
  static const Color surface = Color(0xFFFFFFFF); // Putih bersih
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate tipis

  // Tipografi & Teks
  static const Color textPrimary = Color(0xFF0F172A); // Charcoal pekat
  static const Color textSecondary = Color(0xFF475569); // Slate sedang
  static const Color textMuted = Color(0xFF94A3B8); // Slate abu-abu lembut
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Pembatas
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  // Status Indikator
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color success = Color(0xFF16A34A);
  static const Color successBackground = Color(0xFFF0FDF4);
  static const Color bookmarkActive = Color(0xFFD97706); // Emas untuk bookmark aktif
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // EdgeInsets reusable helpers
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

class AppRadius {
  static const double sm = 6.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 999.0;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}

class AppTextStyles {
  // Judul Utama (Headline)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // Judul Artikel / Subheading
  static const TextStyle titleLarge = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  // Teks Paragraf / Konten
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // Label & Metadata
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const TextStyle categoryBadge = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border, width: 1),
          borderRadius: AppRadius.radiusMd,
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSm,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
      ),
    );
  }
}
