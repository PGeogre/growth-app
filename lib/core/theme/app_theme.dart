import 'package:flutter/material.dart';

/// 柔和配色 —— 鼠尾草绿 + 暖米白 + 深灰蓝
class AppColors {
  AppColors._();

  // 主题色（鼠尾草绿）
  static const Color primary = Color(0xFF7FA98F);
  static const Color primaryDark = Color(0xFF5F8870);
  static const Color primaryLight = Color(0xFFE4EFE8);

  // 背景（暖米白）
  static const Color background = Color(0xFFFAF8F4);
  static const Color card = Color(0xFFFFFFFF);

  // 文字（深灰蓝）
  static const Color textPrimary = Color(0xFF33414B);
  static const Color textSecondary = Color(0xFF7A8791);
  static const Color textHint = Color(0xFFAEB8BE);

  // 各模块强调色（低饱和）
  static const Color english = Color(0xFF7FA98F); // 绿
  static const Color diet = Color(0xFFE8B48C); // 杏橙
  static const Color sleep = Color(0xFF9C97C7); // 紫
  static const Color workout = Color(0xFF8FB9C9); // 蓝
  static const Color growth = Color(0xFFD99A9E); // 粉
  static const Color mood = Color(0xFFC9B08C); // 棕

  // 通用
  static const Color divider = Color(0xFFEDEAE4);
  static const Color success = Color(0xFF7FA98F);
  static const Color warning = Color(0xFFE8B48C);
  static const Color error = Color(0xFFD98E8E);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF1B1F1D) : AppColors.background,
    );

    final cardColor = isDark ? const Color(0xFF262B28) : AppColors.card;
    final textPrimary = isDark ? const Color(0xFFE4EAE6) : AppColors.textPrimary;
    final textHint = isDark ? const Color(0xFF5C6861) : AppColors.textHint;
    final divider = isDark ? const Color(0xFF343B37) : AppColors.divider;
    final navBg = isDark ? const Color(0xFF222723) : AppColors.card;

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1B1F1D) : AppColors.background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: isDark ? const Color(0xFF9CC4AB) : AppColors.primaryDark,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: TextStyle(color: textHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dividerColor: divider,
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}
