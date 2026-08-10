import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';

/// نقطة الوصول الوحيدة لألوان الواجهة داخل الـ Widgets.
/// كل رمز يُحلّ حسب سطوع الثيم الحالي (Light / Dark) تلقائياً،
/// فلا حاجة لأي `Colors.x` أو `Color(0xFF...)` داخل الشاشات.
extension AdminThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  T _pick<T>(T light, T dark) => isDarkMode ? dark : light;

  // ── Brand ─────────────────────────────────────────────────────────────────
  Color get primaryColor => AdminColors.brandPrimary;
  Color get primaryDeep => AdminColors.brandPrimaryDeep;
  Color get onPrimary => AdminColors.onBrand;
  Color get onPrimaryMuted => AdminColors.onBrandMuted;

  // ── Surfaces ──────────────────────────────────────────────────────────────
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardTheme.color ?? colorScheme.surface;
  Color get surfaceColor => colorScheme.surface;
  Color get surfaceVariant =>
      _pick(AdminColors.surfaceVariantLight, AdminColors.surfaceVariantDark);

  // ── Borders ───────────────────────────────────────────────────────────────
  Color get borderSoft =>
      _pick(AdminColors.borderSoftLight, AdminColors.borderSoftDark);
  Color get borderStrong =>
      _pick(AdminColors.borderStrongLight, AdminColors.borderStrongDark);
  Color get dividerLine => theme.dividerColor;

  // ── Text ──────────────────────────────────────────────────────────────────
  Color get textPrimary =>
      _pick(AdminColors.textPrimaryLight, AdminColors.textPrimaryDark);
  Color get textSecondary =>
      _pick(AdminColors.textSecondaryLight, AdminColors.textSecondaryDark);
  Color get textTertiary =>
      _pick(AdminColors.textTertiaryLight, AdminColors.textTertiaryDark);
  Color get textMuted =>
      _pick(AdminColors.textMutedLight, AdminColors.textMutedDark);

  // ── Success ───────────────────────────────────────────────────────────────
  Color get successColor =>
      _pick(AdminColors.successFgLight, AdminColors.successFgDark);
  Color get successBg =>
      _pick(AdminColors.successBgLight, AdminColors.successBgDark);
  Color get successBorder =>
      _pick(AdminColors.successBorderLight, AdminColors.successBorderDark);

  // ── Warning / Pending ─────────────────────────────────────────────────────
  Color get warningColor =>
      _pick(AdminColors.warningFgLight, AdminColors.warningFgDark);
  Color get warningBg =>
      _pick(AdminColors.warningBgLight, AdminColors.warningBgDark);
  Color get warningBorder =>
      _pick(AdminColors.warningBorderLight, AdminColors.warningBorderDark);
  Color get pendingColor => warningColor;

  // ── Danger / Error ────────────────────────────────────────────────────────
  Color get errorColor => colorScheme.error;
  Color get dangerColor =>
      _pick(AdminColors.dangerFgLight, AdminColors.dangerFgDark);
  Color get dangerBg =>
      _pick(AdminColors.dangerBgLight, AdminColors.dangerBgDark);
  Color get dangerBorder =>
      _pick(AdminColors.dangerBorderLight, AdminColors.dangerBorderDark);

  // ── Info ──────────────────────────────────────────────────────────────────
  Color get infoColor => _pick(AdminColors.infoFgLight, AdminColors.infoFgDark);
  Color get infoBg => _pick(AdminColors.infoBgLight, AdminColors.infoBgDark);
  Color get infoBorder =>
      _pick(AdminColors.infoBorderLight, AdminColors.infoBorderDark);

  // ── Sidebar / Header ──────────────────────────────────────────────────────
  Color get sidebarBg =>
      _pick(AdminColors.sidebarBgLight, AdminColors.sidebarBgDark);
  Color get sidebarBorder =>
      _pick(AdminColors.sidebarBorderLight, AdminColors.sidebarBorderDark);
  Color get sidebarItemText =>
      _pick(AdminColors.sidebarItemTextLight, AdminColors.sidebarItemTextDark);
  Color get sidebarActiveBg => AdminColors.sidebarActiveBg;
  Color get onSidebarActive => AdminColors.onSidebarActive;
  Color get sidebarHover =>
      _pick(AdminColors.sidebarHoverLight, AdminColors.sidebarHoverDark);
  Color get headerBg =>
      _pick(AdminColors.headerBgLight, AdminColors.headerBgDark);
  Color get brandTagline =>
      _pick(AdminColors.brandTaglineLight, AdminColors.brandTaglineDark);

  // ── Overlays / Elevation ──────────────────────────────────────────────────
  /// ظل البطاقات: أعمق في الوضع الليلي حتى يبقى الفصل بين الأسطح مرئياً.
  Color get cardShadow =>
      _pick(AdminColors.shadowLight, AdminColors.shadowDark);
  Color get scrim => _pick(AdminColors.scrimLight, AdminColors.scrimDark);
  Color get transparent => AdminColors.transparent;
}
