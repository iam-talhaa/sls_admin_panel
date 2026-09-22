import 'package:flutter/material.dart';

/// Dark theme color palette — pixel-identical to original SLS Dark design.
class AppColorsDark {
  AppColorsDark._();

  static const Color background = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color surfaceElevatedHigher = Color(0xFF333336);

  static const Color primaryRed = Color(0xFFED1C24);
  static const Color primaryRedDark = Color(0xFFC7141B);
  static const Color primaryRedLight = Color(0xFF3B1E21);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF636366);

  static const Color border = Color(0xFF38383A);
  static const Color borderFocused = Color(0xFFED1C24);
  static const Color inputFill = Color(0xFF1E1E1E);
  static const Color inputHint = Color(0xFF6E6E73);

  static const Color success = Color(0xFF34C759);
  static const Color successBg = Color(0x1F34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningBg = Color(0x1FFF9F0A);
  static const Color error = Color(0xFFFF453A);
  static const Color errorBg = Color(0x1FFF453A);
  static const Color info = Color(0xFF0A84FF);
  static const Color infoBg = Color(0x1F0A84FF);

  static const Color tableRowHover = Color(0xFF2A2A2A);
  static const Color shadow = Color(0x00000000); // border-only depth in dark mode
  static const Color divider = Color(0xFF2C2C2E);

  // Fixed sidebar tokens (brand anchor)
  static const Color sidebarBackground = Color(0xFF1E1E1E);
  static const Color sidebarSurface = Color(0xFF1E1E1E);
  static const Color sidebarSurfaceElevated = Color(0xFF2A2A2A);
  static const Color sidebarSurfaceElevatedHigher = Color(0xFF333336);
  static const Color sidebarBorder = Color(0xFF38383A);
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarTextMuted = Color(0xFF8E8E93);
}

/// Light theme color palette — curated for a high-end luxury aesthetic.
class AppColorsLight {
  AppColorsLight._();

  static const Color background = Color(0xFFF6F6F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceElevatedHigher = Color(0xFFF1F1F3);

  static const Color primaryRed = Color(0xFFED1C24); // brand red unchanged
  static const Color primaryRedDark = Color(0xFFC7141B);
  static const Color primaryRedLight = Color(0xFFFDE8E9);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textMuted = Color(0xFF9A9AA0);

  static const Color border = Color(0xFFE4E4E7);
  static const Color borderFocused = Color(0xFFED1C24);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputHint = Color(0xFFA0A0A6);

  static const Color success = Color(0xFF1FA34A);
  static const Color successBg = Color(0x1F1FA34A);
  static const Color warning = Color(0xFFCC7A00);
  static const Color warningBg = Color(0x1FCC7A00);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0x1FDC2626);
  static const Color info = Color(0xFF0284C7);
  static const Color infoBg = Color(0x1F0284C7);

  static const Color tableRowHover = Color(0xFFF1F1F3);
  static const Color shadow = Color(0x14000000); // ~8% soft elevation shadow
  static const Color divider = Color(0xFFE4E4E7);
}

/// Static alias keeping sidebar & dark anchors constant where required.
class AppColors {
  AppColors._();

  static const Color primaryRed = Color(0xFFED1C24);
  static const Color primaryRedDark = Color(0xFFC7141B);
  static const Color primaryRedLight = Color(0xFF3B1E21);
  static const Color info = Color(0xFF0A84FF);

  // Fixed Sidebar colors (remains dark luxury anchor in both light & dark modes)
  static const Color sidebarBackground = AppColorsDark.sidebarBackground;
  static const Color sidebarSurface = AppColorsDark.sidebarSurface;
  static const Color sidebarSurfaceElevated = AppColorsDark.sidebarSurfaceElevated;
  static const Color sidebarSurfaceElevatedHigher = AppColorsDark.sidebarSurfaceElevatedHigher;
  static const Color sidebarBorder = AppColorsDark.sidebarBorder;
  static const Color sidebarText = AppColorsDark.sidebarText;
  static const Color sidebarTextMuted = AppColorsDark.sidebarTextMuted;
}
