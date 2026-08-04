import 'package:flutter/material.dart';
import 'derbi_colors.dart';

class DerbiTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DerbiColors.background,
      cardColor: DerbiColors.surfaceCard,
      fontFamily: 'Tajawal',
      colorScheme: const ColorScheme.dark(
        primary: DerbiColors.primaryBlue,
        secondary: DerbiColors.successEmerald,
        surface: DerbiColors.surfaceCard,
        error: DerbiColors.dangerRose,
      ),
      dividerColor: DerbiColors.borderSlate,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DerbiColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DerbiColors.primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: DerbiColors.textSecondary),
        hintStyle: const TextStyle(color: DerbiColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DerbiColors.surfaceCard,
        selectedColor: DerbiColors.primaryBlue,
        side: const BorderSide(color: DerbiColors.borderSlate),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
