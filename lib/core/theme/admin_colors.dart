import 'package:flutter/material.dart';

class AdminColors {
  // Base Colors
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black26 = Color(0x42000000);
  static const Color black12 = Color(0x1F000000);

  // Neutral Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color grey950 = Color(0xFF0A0A0A);
  static const Color grey = grey500;

  // Feedback Colors
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
  static const Color green700 = Color(0xFF388E3C);
  static const Color orange = Color(0xFFFF9800);
  static const Color amber = Color(0xFFFFC107);
  static const Color blue = Color(0xFF2196F3);
  static const Color blueGrey = Color(0xFF607D8B);

  // Light Theme Colors
  static const Color primaryLight = Color(0xFF148BD4);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFE6F7FA);
  static const Color secondaryLight = Color(0xFFFDE68A);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFEF4444);

  // Dark Theme Colors
  static const Color primaryDark = Color.fromARGB(255, 20, 179, 219);
  static const Color backgroundDark = Color(0xFF081115);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color onPrimaryDark = Color(0xFF081115);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color pending = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color error = Color(0xFFEF4444);
  static const Color textMuted = Color(0xFF6B7280);

  // Branded Accent Colors
  static const Color maleBlue = Color(0xFF3B82F6);
  static const Color femalePink = Color(0xFFEC4899);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF6366F1);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Gender Background Tints
  static const Color maleBlueBg = Color(0xFFEFF6FF);
  static const Color femalePinkBg = Color(0xFFFDF2F8);

  static const Color textDark = Color(0xFF1A1A1A);

  // Dark Surface / Background
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkGradientStart = Color(0xFF1A2332);
  static const Color darkGradientEnd = Color(0xFF0F172A);

  // Primary Gradient Pair
  static const Color primaryGradientEnd = Color(0xFF0E78C4);
  static const Color primarySoft = Color(0xFFD1F0FA);

  // ───────────────────────────────────────────────────────────────────────────
  // Derbi Design Tokens — المصدر الوحيد لألوان الواجهة
  // كل رمز له نسخة Light ونسخة Dark، ويُقرأ عبر AdminThemeContext فقط.
  // ───────────────────────────────────────────────────────────────────────────

  // Brand
  static const Color brandPrimary = Color(0xFF2563EB);
  static const Color brandPrimaryDeep = Color(0xFF1D4ED8);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onBrandMuted = Color(0xB3FFFFFF);

  // Surfaces
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color surfaceVariantDark = Color(0xFF0F172A);

  // Borders & Dividers
  static const Color borderSoftLight = Color(0xFFE2E8F0);
  static const Color borderSoftDark = Color(0xFF334155);
  static const Color borderStrongLight = Color(0xFFCBD5E1);
  static const Color borderStrongDark = Color(0xFF475569);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryLight = Color(0xFF64748B);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Success
  static const Color successFgLight = Color(0xFF059669);
  static const Color successFgDark = Color(0xFF34D399);
  static const Color successBgLight = Color(0xFFECFDF5);
  static const Color successBgDark = Color(0xFF0C2C22);
  static const Color successBorderLight = Color(0xFFA7F3D0);
  static const Color successBorderDark = Color(0xFF14532D);

  // Warning / Pending
  static const Color warningFgLight = Color(0xFF92400E);
  static const Color warningFgDark = Color(0xFFFBBF24);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBgDark = Color(0xFF2E2410);
  static const Color warningBorderLight = Color(0xFFFDE68A);
  static const Color warningBorderDark = Color(0xFF553A0E);

  // Danger / Error
  static const Color dangerFgLight = Color(0xFFB91C1C);
  static const Color dangerFgDark = Color(0xFFFB7185);
  static const Color dangerBgLight = Color(0xFFFEF2F2);
  static const Color dangerBgDark = Color(0xFF2C1418);
  static const Color dangerBorderLight = Color(0xFFFECACA);
  static const Color dangerBorderDark = Color(0xFF7F1D2B);

  // Info
  static const Color infoFgLight = Color(0xFF1E40AF);
  static const Color infoFgDark = Color(0xFF93C5FD);
  static const Color infoBgLight = Color(0xFFEFF6FF);
  static const Color infoBgDark = Color(0xFF14213D);
  static const Color infoBorderLight = Color(0xFFBFDBFE);
  static const Color infoBorderDark = Color(0xFF1E3A8A);

  // Sidebar / Top Header — لكل رمز نسخة Light ونسخة Dark
  static const Color sidebarBgLight = Color(0xFF1E3A8A); // A rich deep blue for light theme
  static const Color sidebarBgDark = Color(0xFF0F1E36);  // A deep midnight blue for dark theme
  static const Color sidebarBorderLight = Color(0xFF1D3557);
  static const Color sidebarBorderDark = Color(0xFF0D1B2A);
  static const Color sidebarItemTextLight = Color(0xFF93C5FD); // Light blue-grey for readability
  static const Color sidebarItemTextDark = Color(0xFF8A99AD);
  static const Color sidebarActiveBg = Color(0xFF2563EB); // Vivid accent blue for selection
  static const Color onSidebarActive = Color(0xFFFFFFFF);
  static const Color sidebarHoverLight = Color(0xFF1E293B);
  static const Color sidebarHoverDark = Color(0xFF1C2541);
  static const Color headerBgLight = Color(0xFFFFFFFF);
  static const Color headerBgDark = Color(0xFF0F172A);
  static const Color brandTaglineLight = Color(0xFF2563EB);
  static const Color brandTaglineDark = Color(0xFF60A5FA);

  // Overlays / Scrims
  static const Color scrimLight = Color(0x14000000);
  static const Color scrimDark = Color(0x66000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color onBrandOverlay = Color(0x3DFFFFFF);

  // Semantic (theme-independent brand accents used for charts / stat accents)
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFF43F5E);
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Map surface tokens — تُرسم فوق بلاطات OpenStreetMap (فاتحة دائماً)،
  // لذلك تتبع سطوع الخريطة لا سطوع التطبيق. راجع dashboard_overview_screen.
  static const Color mapMarkerLabelBg = Color(0xFF0F172A);
  static const Color onMapMarkerLabel = Color(0xFFFFFFFF);
  static const Color onMapMarkerLabelMuted = Color(0xB3FFFFFF);
  static const Color mapScrim = Color(0xFF0F172A);
  static const Color mapMarkerShadow = Color(0x4D000000);

  // Derbi & App Compatibility Tokens
  static const Color background = Color(0xFF0F172A);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color sidebarBackground = Color(0xFF0F172A);
  static const Color borderSlate = Color(0xFF334155);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueHover = Color(0xFF1D4ED8);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color dangerRose = Color(0xFFF43F5E);
  static const Color infoCyan = Color(0xFF06B6D4);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color sidebarActiveItem = Color(0xFF1D61E7);
  static const Color sidebarInactiveText = Color(0xFF8C9BAE);
  static const Color sidebarBorder = Color(0xFF162238);
  static const Color badgeBackground = Color(0xFF2A1525);
  static const Color badgeText = Color(0xFFFF4D4D);
  static const Color statusGreenBg = Color(0xFFECFDF5);
  static const Color statusGreenText = Color(0xFF10B981);
  static const Color statusGreenBorder = Color(0xFFA7F3D0);
  static const Color mainBackground = Color(0xFFF4F6F9);
  static const Color headerBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
}

typedef DerbiColors = AdminColors;
typedef AppColors = AdminColors;
