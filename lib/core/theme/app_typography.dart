import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Une display font avec du caractère pour les titres (Plus Jakarta Sans —
/// alternative disponible sur Google Fonts la plus proche de Clash Display),
/// + Inter pour le corps de texte (lisibilité maximale).
abstract final class AppTypography {
  static TextTheme textTheme(Color primaryTextColor, Color secondaryTextColor) {
    final display = GoogleFonts.plusJakartaSansTextTheme();
    final body = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 32, fontWeight: FontWeight.w800, color: primaryTextColor, height: 1.2,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 26, fontWeight: FontWeight.w800, color: primaryTextColor, height: 1.25,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontSize: 22, fontWeight: FontWeight.w700, color: primaryTextColor, height: 1.3,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 18, fontWeight: FontWeight.w700, color: primaryTextColor,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontSize: 17, fontWeight: FontWeight.w700, color: primaryTextColor,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 15, fontWeight: FontWeight.w600, color: primaryTextColor,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        fontSize: 15, fontWeight: FontWeight.w400, color: primaryTextColor, height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w400, color: secondaryTextColor, height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondaryTextColor,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w600, color: primaryTextColor,
      ),
    );
  }

  static TextTheme get light => textTheme(AppColors.textPrimary, AppColors.textSecondary);
  static TextTheme get dark => textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
}
