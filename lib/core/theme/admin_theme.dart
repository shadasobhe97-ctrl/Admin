import 'package:flutter/material.dart';

class AdminTheme {
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusPill = 30;

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );

  static BorderRadius radius(double value) => BorderRadius.circular(value);
  static BorderRadiusGeometry radiusAll(double value) => BorderRadius.circular(value);
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
    return Border(
      bottom: borderSide(color: color, width: width, style: style),
    );
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2563EB),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      canvasColor: Colors.white,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE2E8F0),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        secondary: Color(0xFF10B981),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
        error: Color(0xFFF43F5E),
        onError: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Tajawal'),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Tajawal'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF0F172A)),
        bodyMedium: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF475569)),
        bodySmall: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2563EB),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      canvasColor: const Color(0xFF1E293B),
      cardColor: const Color(0xFF1E293B),
      dividerColor: const Color(0xFF334155),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        secondary: Color(0xFF10B981),
        onSecondary: Colors.white,
        surface: Color(0xFF1E293B),
        onSurface: Colors.white,
        error: Color(0xFFF43F5E),
        onError: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Tajawal'),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Tajawal'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'Tajawal', color: Color(0xFFCBD5E1)),
        bodySmall: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
