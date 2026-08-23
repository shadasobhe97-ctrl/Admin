import 'package:flutter/material.dart';

class AdminColors {
  // ============================================================
  // Base Colors
  // ============================================================

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

  // ============================================================
  // Neutral Scale
  // ============================================================

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

  // ============================================================
  // Darbi Brand Colors
  // ============================================================

  // Main brand blue
  static const Color primary = Color(0xFF1499D5);

  // Lighter / brighter sky blue
  static const Color primaryLight = Color(0xFF20B4D8);

  // Darker brand blue
  static const Color primaryDark = Color(0xFF0879B5);

  // Very light blue background
  static const Color primarySoft = Color(0xFFE0F7FA);

  // Blue container
  static const Color primaryContainer = Color(0xFFD5F3FA);
  static const Color primaryContainerLight = Color(0xFFD5F3FA);

  // Text/icon placed on primary
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  // ============================================================
  // Secondary Brand Color
  // ============================================================

  static const Color secondary = Color(0xFFFBBF24);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFF59E0B);
  static const Color secondarySoft = Color(0xFFFEF3C7);

  static const Color onSecondary = Color(0xFF1F2937);

  // ============================================================
  // Brand Gradient
  // ============================================================

  static const Color primaryGradientStart = Color(0xFF20B4D8);
  static const Color primaryGradientEnd = Color(0xFF0879B5);

  // ============================================================
  // Feedback / Utility Colors
  // ============================================================

  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
  static const Color green700 = Color(0xFF388E3C);
  static const Color orange = Color(0xFFFF9800);
  static const Color amber = Color(0xFFFFC107);
  static const Color blue = Color(0xFF1499D5);
  static const Color blueGrey = Color(0xFF607D8B);

  // ============================================================
  // Light Theme
  // ============================================================

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryLightTheme = Color(0xFF1499D5);
  static const Color errorLight = Color(0xFFEF4444);

  // ============================================================
  // Dark Theme
  // ============================================================

  static const Color backgroundDark = Color(0xFF081115);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF111827);

  static const Color darkGradientStart = Color(0xFF123A4A);
  static const Color darkGradientEnd = Color(0xFF0B2530);

  static const Color primaryDarkTheme = Color(0xFF20B4D8);
  static const Color primaryContainerDark = Color(0xFF164E63);
  static const Color onPrimaryDark = Color(0xFF081115);

  // ============================================================
  // Status Colors
  // ============================================================

  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color pending = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color error = Color(0xFFEF4444);

  // ============================================================
  // Text
  // ============================================================

  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // ============================================================
  // Gender Colors
  // ============================================================

  static const Color maleBlue = Color(0xFF3B82F6);
  static const Color femalePink = Color(0xFFEC4899);
  static const Color maleBlueBg = Color(0xFFEFF6FF);
  static const Color femalePinkBg = Color(0xFFFDF2F8);

  // ============================================================
  // Accent Colors
  // ============================================================

  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF20B4D8);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);

  // ============================================================
  // Derbi Design Tokens
  // ============================================================

  // Brand
  static const Color brandPrimary = Color(0xFF1499D5);
  static const Color brandPrimaryDeep = Color(0xFF0879B5);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color onBrandMuted = Color(0xB3FFFFFF);

  // Surfaces
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF081115);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color surfaceVariantDark = Color(0xFF111827);

  // Borders & Dividers
  static const Color borderSoftLight = Color(0xFFE2E8F0);
  static const Color borderSoftDark = Color(0xFF334155);
  static const Color borderStrongLight = Color(0xFFCBD5E1);
  static const Color borderStrongDark = Color(0xFF475569);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF273549);

  // Text Tokens
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryLight = Color(0xFF64748B);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Success
  static const Color successFgLight = Color(0xFF16A34A);
  static const Color successFgDark = Color(0xFF22C55E);
  static const Color successBgLight = Color(0xFFDCFCE7);
  static const Color successBgDark = Color(0xFF164E63);
  static const Color successBorderLight = Color(0xFFDCFCE7);
  static const Color successBorderDark = Color(0xFF16A34A);

  // Warning / Pending
  static const Color warningFgLight = Color(0xFFF59E0B);
  static const Color warningFgDark = Color(0xFFFBBF24);
  static const Color warningBgLight = Color(0xFFFEF3C7);
  static const Color warningBgDark = Color(0xFF1E293B);
  static const Color warningBorderLight = Color(0xFFFEF3C7);
  static const Color warningBorderDark = Color(0xFFF59E0B);

  // Danger / Error
  static const Color dangerFgLight = Color(0xFFEF4444);
  static const Color dangerFgDark = Color(0xFFEF4444);
  static const Color dangerBgLight = Color(0xFFFEE2E2);
  static const Color dangerBgDark = Color(0xFF1E293B);
  static const Color dangerBorderLight = Color(0xFFFEE2E2);
  static const Color dangerBorderDark = Color(0xFFEF4444);

  // Info
  static const Color infoFgLight = Color(0xFF3B82F6);
  static const Color infoFgDark = Color(0xFF20B4D8);
  static const Color infoBgLight = Color(0xFFDBEAFE);
  static const Color infoBgDark = Color(0xFF164E63);
  static const Color infoBorderLight = Color(0xFFDBEAFE);
  static const Color infoBorderDark = Color(0xFF3B82F6);

  // Sidebar
  static const Color sidebarBgLight = Color(0xFFFFFFFF);
  static const Color sidebarBgDark = Color(0xFF111827);
  static const Color sidebarBorderLight = Color(0xFFE2E8F0);
  static const Color sidebarBorderDark = Color(0xFF334155);
  static const Color sidebarItemTextLight = Color(0xFF64748B);
  static const Color sidebarItemTextDark = Color(0xFF64748B);
  static const Color sidebarActiveBgLight = Color(0xFFE0F7FA);
  static const Color sidebarActiveBgDark = Color(0xFF164E63);
  static const Color onSidebarActiveLight = Color(0xFF0879B5);
  static const Color onSidebarActiveDark = Color(0xFF20B4D8);
  static const Color sidebarHoverLight = Color(0xFFF5F5F5);
  static const Color sidebarHoverDark = Color(0xFF1E293B);

  // Header
  static const Color headerBgLight = Color(0xFFFFFFFF);
  static const Color headerBgDark = Color(0xFF111827);
  static const Color brandTaglineLight = Color(0xFF1499D5);
  static const Color brandTaglineDark = Color(0xFF20B4D8);

  // Overlays / Scrims & Shadows
  static const Color scrimLight = Color(0x14000000);
  static const Color scrimDark = Color(0x33000000);
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color onBrandOverlay = Color(0x3DFFFFFF);

  // Semantic Status Tokens
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);

  static const Color accentIndigo = Color(0xFF20B4D8);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF20B4D8);

  // Map Surface Tokens
  static const Color mapMarkerLabelBg = Color(0xFF111827);
  static const Color onMapMarkerLabel = Color(0xFFFFFFFF);
  static const Color onMapMarkerLabelMuted = Color(0xB3FFFFFF);
  static const Color mapScrim = Color(0xFF111827);
  static const Color mapMarkerShadow = Color(0x33000000);

  // Darbi & App Compatibility Tokens
  static const Color background = Color(0xFF081115);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color sidebarBackground = Color(0xFF111827);
  static const Color borderSlate = Color(0xFF334155);
  static const Color primaryBlue = Color(0xFF1499D5);
  static const Color primaryBlueHover = Color(0xFF0879B5);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color dangerRose = Color(0xFFEF4444);
  static const Color infoCyan = Color(0xFF20B4D8);
  static const Color sidebarActiveItem = Color(0xFF1499D5);
  static const Color sidebarInactiveText = Color(0xFF64748B);
  static const Color sidebarBorder = Color(0xFF334155);
  static const Color badgeBackground = Color(0xFFFEE2E2);
  static const Color badgeText = Color(0xFFEF4444);

  // Status Backgrounds
  static const Color statusGreenBg = Color(0xFFDCFCE7);
  static const Color statusGreenText = Color(0xFF22C55E);
  static const Color statusGreenBorder = Color(0xFFDCFCE7);

  // Admin Layout
  static const Color mainBackground = Color(0xFFF8FAFC);
  static const Color headerBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
}

// ============================================================
// Compatibility Aliases
// ============================================================

typedef DerbiColors = AdminColors;
typedef AppColors = AdminColors;
