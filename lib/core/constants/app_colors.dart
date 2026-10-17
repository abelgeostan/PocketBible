import 'package:flutter/material.dart';

/// App color palette faithfully matching the PocketBible website design
class AppColors {
  // Light Palette
  static const Color lightBg = Color(0xFFF3F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF8FAFB);
  static const Color lightText = Color(0xFF20242A);
  static const Color lightMuted = Color(0xFF69717D);
  static const Color lightLine = Color(0xFFDFE4E9);
  static const Color lightAccent = Color(0xFF725335);
  static const Color lightAccent2 = Color(0xFF956D45);

  // Dark Palette
  static const Color darkBg = Color(0xFF0F1317);
  static const Color darkSurface = Color(0xFF181D22);
  static const Color darkSurface2 = Color(0xFF20262C);
  static const Color darkText = Color(0xFFEDF1F5);
  static const Color darkMuted = Color(0xFFA9B2BC);
  static const Color darkLine = Color(0xFF303840);
  static const Color darkAccent = Color(0xFFD4A66D);
  static const Color darkAccent2 = Color(0xFFE0B57E);

  // Highlight Colors (Light mode)
  static const Color highlightYellowLight = Color(0xFFFFF3A6);
  static const Color highlightGreenLight = Color(0xFFC8F7C5);
  static const Color highlightBlueLight = Color(0xFFC5E0F7);
  static const Color highlightPinkLight = Color(0xFFF7C5E0);

  // Highlight Colors (Dark mode)
  static const Color highlightYellowDark = Color(0xFF5B5120);
  static const Color highlightGreenDark = Color(0xFF1E4D2B);
  static const Color highlightBlueDark = Color(0xFF1B3B5F);
  static const Color highlightPinkDark = Color(0xFF5F1B3B);

  // Search match highlight
  static const Color searchHitLight = Color(0xFFFFE58A);
  static const Color searchHitDark = Color(0xFF665B20);

  static Color getHighlightColor(String colorName, bool isDark) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return isDark ? highlightGreenDark : highlightGreenLight;
      case 'blue':
        return isDark ? highlightBlueDark : highlightBlueLight;
      case 'pink':
        return isDark ? highlightPinkDark : highlightPinkLight;
      case 'yellow':
      default:
        return isDark ? highlightYellowDark : highlightYellowLight;
    }
  }
}
