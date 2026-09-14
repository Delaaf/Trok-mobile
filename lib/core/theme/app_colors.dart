import 'package:flutter/material.dart';

/// Palette de marque Trok — chaleureuse, premium, identité africaine.
/// Fond ivoire (pas blanc pur) + orange terracotta comme accent principal.
abstract final class AppColors {
  // Primaire
  static const Color primary = Color(0xFFE8720C); // orange terracotta
  static const Color primaryDark = Color(0xFFB5541A); // terre cuite
  static const Color primaryLight = Color(0xFFFBE3CC);

  // Fond
  static const Color background = Color(0xFFF5EDE4); // ivoire chaud
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0EAE3);

  // Texte
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textMuted = Color(0xFFAFA89F);

  // Accents identité africaine
  static const Color accentGreen = Color(0xFF2F6B4F); // vert kente — succès/vérifié
  static const Color accentGold = Color(0xFFD4A017); // or doux — premium/boost

  // États
  static const Color success = Color(0xFF2F9E5C);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF3B7DD8);

  // Divers
  static const Color border = Color(0xFFE6DFD5);
  static const Color overlay = Color(0x66000000);

  // Dark mode (prévu dès le départ dans le design system)
  static const Color backgroundDark = Color(0xFF141210);
  static const Color surfaceDark = Color(0xFF1F1C19);
  static const Color textPrimaryDark = Color(0xFFF5EDE4);
  static const Color textSecondaryDark = Color(0xFFB0A99F);
}
