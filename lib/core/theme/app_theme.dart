import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.scrub,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.scrub,
        onPrimary: AppColors.paper,
        secondary: AppColors.plaster,
        onSecondary: AppColors.scrub,
        surface: AppColors.paper,
        onSurface: AppColors.scrub,
        error: AppColors.alert,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.outfit().fontFamily,
        bodyColor: AppColors.scrub,
        displayColor: AppColors.scrub,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.scrub,
          foregroundColor: AppColors.paper,
          minimumSize: const Size.fromHeight(50),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.scrub.withValues(alpha: 0.28),
        thickness: 1,
      ),
    );
  }
}