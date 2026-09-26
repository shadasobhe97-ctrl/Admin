import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_colors.dart';

class AdminTheme {
  static String get fontFamily => GoogleFonts.cairo().fontFamily ?? 'Cairo';

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusPill = 30;

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );

  static BorderRadius radius(double value) => BorderRadius.circular(value);
  static BorderRadiusGeometry radiusAll(double value) =>
      BorderRadius.circular(value);
  static Radius cornerRadius(double value) => Radius.circular(value);

  static BorderRadius onlyRadius({
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
    Radius bottomRight = Radius.zero,
  }) {
    return BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  static BorderSide borderSide({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return BorderSide(color: color, width: width, style: style);
  }

  static BoxBorder border({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return Border.all(color: color, width: width, style: style);
  }

  static BoxBorder bottomBorder({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return Border(bottom: borderSide(color: color, width: width, style: style));
  }

  static RoundedRectangleBorder roundedRectangleBorder({
    double radius = radiusLarge,
    BorderRadiusGeometry? borderRadius,
    BorderSide side = BorderSide.none,
  }) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      side: side,
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context).inputDecorationTheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: theme.filled,
      fillColor: theme.fillColor,
      contentPadding: theme.contentPadding,
      border: theme.border,
      enabledBorder: theme.enabledBorder,
      focusedBorder: theme.focusedBorder,
      errorBorder: theme.errorBorder,
      hintStyle: theme.hintStyle,
      labelStyle: theme.labelStyle,
    );
  }

  static BoxDecoration boxDecoration({
    Color? color,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
    );
  }

  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Size? minimumSize,
    OutlinedBorder? shape,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      minimumSize: minimumSize,
      shape: shape,
    );
  }

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  /// يبني الثيم من رموز [AdminColors] فقط بفرشاة خط Cairo الشاملة للويب والمنصات.
  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    T pick<T>(T light, T dark) => isDark ? dark : light;

    final Color background = pick(AdminColors.bgLight, AdminColors.bgDark);
    final Color card = pick(AdminColors.cardLight, AdminColors.cardDark);
    final Color surfaceVariant =
        pick(AdminColors.surfaceVariantLight, AdminColors.surfaceVariantDark);
    final Color borderSoft =
        pick(AdminColors.borderSoftLight, AdminColors.borderSoftDark);
    final Color borderStrong =
        pick(AdminColors.borderStrongLight, AdminColors.borderStrongDark);
    final Color textPrimary =
        pick(AdminColors.textPrimaryLight, AdminColors.textPrimaryDark);
    final Color textSecondary =
        pick(AdminColors.textSecondaryLight, AdminColors.textSecondaryDark);
    final Color textTertiary =
        pick(AdminColors.textTertiaryLight, AdminColors.textTertiaryDark);
    final Color textMuted =
        pick(AdminColors.textMutedLight, AdminColors.textMutedDark);

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final cairoTextTheme = GoogleFonts.cairoTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.cairo().fontFamily,
      brightness: brightness,
      primaryColor: AdminColors.brandPrimary,
      scaffoldBackgroundColor: background,
      canvasColor: card,
      cardColor: card,
      dividerColor: borderSoft,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AdminColors.brandPrimary,
        onPrimary: AdminColors.onBrand,
        secondary: AdminColors.secondary,
        onSecondary: AdminColors.onBrand,
        surface: card,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        outline: borderStrong,
        outlineVariant: borderSoft,
        error: AdminColors.statusDanger,
        onError: AdminColors.onBrand,
      ),
      dividerTheme: DividerThemeData(color: borderSoft, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: pick(
          AdminColors.textPrimaryLight,
          AdminColors.cardDark,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: AdminColors.onBrand,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderSoft, width: 1.25),
        ),
      ),
      iconTheme: IconThemeData(color: textTertiary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AdminColors.brandPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.cairo(color: textTertiary),
        hintStyle: GoogleFonts.cairo(color: textMuted),
        prefixIconColor: AdminColors.brandPrimary,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderStrong, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderStrong, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AdminColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AdminColors.statusDanger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AdminColors.statusDanger, width: 2),
        ),
      ),
      textTheme: cairoTextTheme.copyWith(
        headlineLarge: GoogleFonts.cairo(
            color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.cairo(
            color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.cairo(
            color: textPrimary, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.cairo(
            color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.cairo(color: textPrimary),
        bodyMedium: GoogleFonts.cairo(color: textSecondary),
        bodySmall: GoogleFonts.cairo(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.brandPrimary,
          foregroundColor: AdminColors.onBrand,
          disabledBackgroundColor: borderStrong,
          disabledForegroundColor: textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.brandPrimary,
          side: BorderSide(color: borderStrong),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AdminColors.brandPrimary,
          textStyle: GoogleFonts.cairo(),
        ),
      ),
    );
  }
}
