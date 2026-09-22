import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceElevatedHigher;
  final Color primaryRed;
  final Color primaryRedDark;
  final Color primaryRedLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color borderFocused;
  final Color inputFill;
  final Color inputHint;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;
  final Color info;
  final Color infoBg;
  final Color tableRowHover;
  final Color shadow;
  final Color divider;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceElevatedHigher,
    required this.primaryRed,
    required this.primaryRedDark,
    required this.primaryRedLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderFocused,
    required this.inputFill,
    required this.inputHint,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.info,
    required this.infoBg,
    required this.tableRowHover,
    required this.shadow,
    required this.divider,
  });

  static const dark = AppColorScheme(
    background: AppColorsDark.background,
    surface: AppColorsDark.surface,
    surfaceElevated: AppColorsDark.surfaceElevated,
    surfaceElevatedHigher: AppColorsDark.surfaceElevatedHigher,
    primaryRed: AppColorsDark.primaryRed,
    primaryRedDark: AppColorsDark.primaryRedDark,
    primaryRedLight: AppColorsDark.primaryRedLight,
    textPrimary: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
    textMuted: AppColorsDark.textMuted,
    border: AppColorsDark.border,
    borderFocused: AppColorsDark.borderFocused,
    inputFill: AppColorsDark.inputFill,
    inputHint: AppColorsDark.inputHint,
    success: AppColorsDark.success,
    successBg: AppColorsDark.successBg,
    warning: AppColorsDark.warning,
    warningBg: AppColorsDark.warningBg,
    error: AppColorsDark.error,
    errorBg: AppColorsDark.errorBg,
    info: AppColorsDark.info,
    infoBg: AppColorsDark.infoBg,
    tableRowHover: AppColorsDark.tableRowHover,
    shadow: AppColorsDark.shadow,
    divider: AppColorsDark.divider,
  );

  static const light = AppColorScheme(
    background: AppColorsLight.background,
    surface: AppColorsLight.surface,
    surfaceElevated: AppColorsLight.surfaceElevated,
    surfaceElevatedHigher: AppColorsLight.surfaceElevatedHigher,
    primaryRed: AppColorsLight.primaryRed,
    primaryRedDark: AppColorsLight.primaryRedDark,
    primaryRedLight: AppColorsLight.primaryRedLight,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
    textMuted: AppColorsLight.textMuted,
    border: AppColorsLight.border,
    borderFocused: AppColorsLight.borderFocused,
    inputFill: AppColorsLight.inputFill,
    inputHint: AppColorsLight.inputHint,
    success: AppColorsLight.success,
    successBg: AppColorsLight.successBg,
    warning: AppColorsLight.warning,
    warningBg: AppColorsLight.warningBg,
    error: AppColorsLight.error,
    errorBg: AppColorsLight.errorBg,
    info: AppColorsLight.info,
    infoBg: AppColorsLight.infoBg,
    tableRowHover: AppColorsLight.tableRowHover,
    shadow: AppColorsLight.shadow,
    divider: AppColorsLight.divider,
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceElevatedHigher,
    Color? primaryRed,
    Color? primaryRedDark,
    Color? primaryRedLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderFocused,
    Color? inputFill,
    Color? inputHint,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? errorBg,
    Color? info,
    Color? infoBg,
    Color? tableRowHover,
    Color? shadow,
    Color? divider,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceElevatedHigher: surfaceElevatedHigher ?? this.surfaceElevatedHigher,
      primaryRed: primaryRed ?? this.primaryRed,
      primaryRedDark: primaryRedDark ?? this.primaryRedDark,
      primaryRedLight: primaryRedLight ?? this.primaryRedLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderFocused: borderFocused ?? this.borderFocused,
      inputFill: inputFill ?? this.inputFill,
      inputHint: inputHint ?? this.inputHint,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      tableRowHover: tableRowHover ?? this.tableRowHover,
      shadow: shadow ?? this.shadow,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      surfaceElevatedHigher: Color.lerp(surfaceElevatedHigher, other.surfaceElevatedHigher, t) ?? surfaceElevatedHigher,
      primaryRed: Color.lerp(primaryRed, other.primaryRed, t) ?? primaryRed,
      primaryRedDark: Color.lerp(primaryRedDark, other.primaryRedDark, t) ?? primaryRedDark,
      primaryRedLight: Color.lerp(primaryRedLight, other.primaryRedLight, t) ?? primaryRedLight,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t) ?? borderFocused,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      inputHint: Color.lerp(inputHint, other.inputHint, t) ?? inputHint,
      success: Color.lerp(success, other.success, t) ?? success,
      successBg: Color.lerp(successBg, other.successBg, t) ?? successBg,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningBg: Color.lerp(warningBg, other.warningBg, t) ?? warningBg,
      error: Color.lerp(error, other.error, t) ?? error,
      errorBg: Color.lerp(errorBg, other.errorBg, t) ?? errorBg,
      info: Color.lerp(info, other.info, t) ?? info,
      infoBg: Color.lerp(infoBg, other.infoBg, t) ?? infoBg,
      tableRowHover: Color.lerp(tableRowHover, other.tableRowHover, t) ?? tableRowHover,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
    );
  }
}

extension AppColorSchemeX on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
}
