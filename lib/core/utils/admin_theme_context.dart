import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';

extension AdminThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get primaryColor => theme.primaryColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardTheme.color ?? colorScheme.surface;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;

  Color get textMuted => AdminColors.textMuted;
  Color get successColor => AdminColors.success;
  Color get pendingColor => AdminColors.pending;
  Color get warningColor => AdminColors.warning;
  Color get infoColor => AdminColors.info;
}
