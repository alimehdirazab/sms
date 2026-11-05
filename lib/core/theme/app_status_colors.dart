import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised semantic colours for status indicators (attendance, marks,
/// fee verification, leave status...). Registered as a [ThemeExtension] on
/// both light and dark themes so screens never hardcode literal colours.
/// Aligned with DESIGN.md Section 2.
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color successBorder;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color warningBorder;

  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color dangerBorder;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color infoBorder;

  final Color neutral;
  final Color neutralContainer;
  final Color neutralBorder;

  const AppStatusColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.successBorder,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.warningBorder,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.dangerBorder,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.infoBorder,
    required this.neutral,
    required this.neutralContainer,
    required this.neutralBorder,
  });

  static const AppStatusColors light = AppStatusColors(
    success: AppColors.success,
    onSuccess: Colors.white,
    successContainer: AppColors.successBg,
    successBorder: AppColors.successBorder,
    warning: AppColors.warning,
    onWarning: Colors.white,
    warningContainer: AppColors.warningBg,
    warningBorder: AppColors.warningBorder,
    danger: AppColors.danger,
    onDanger: Colors.white,
    dangerContainer: AppColors.dangerBg,
    dangerBorder: AppColors.dangerBorder,
    info: AppColors.info,
    onInfo: Colors.white,
    infoContainer: AppColors.infoBg,
    infoBorder: AppColors.infoBorder,
    neutral: AppColors.neutral,
    neutralContainer: AppColors.neutralBg,
    neutralBorder: AppColors.neutralBorder,
  );

  static const AppStatusColors dark = AppStatusColors(
    success: Color(0xFF6FD68F),
    onSuccess: Color(0xFF00391A),
    successContainer: Color(0xFF10502A),
    successBorder: Color(0xFF2D6A4F),
    warning: Color(0xFFFFB95C),
    onWarning: Color(0xFF4A2800),
    warningContainer: Color(0xFF6B3D00),
    warningBorder: Color(0xFF995D00),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF690005),
    dangerContainer: Color(0xFF93000A),
    dangerBorder: Color(0xFFB91C1C),
    info: Color(0xFF9CCAFF),
    onInfo: Color(0xFF00305F),
    infoContainer: Color(0xFF134B85),
    infoBorder: Color(0xFF2E2E99),
    neutral: Color(0xFFB7BCC5),
    neutralContainer: Color(0xFF3A3F46),
    neutralBorder: Color(0xFF52525B),
  );

  /// Convenience accessor with a safe fallback when the extension is absent.
  static AppStatusColors of(BuildContext context) =>
      Theme.of(context).extension<AppStatusColors>() ?? light;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? successBorder,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? warningBorder,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? dangerBorder,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? infoBorder,
    Color? neutral,
    Color? neutralContainer,
    Color? neutralBorder,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      successBorder: successBorder ?? this.successBorder,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      warningBorder: warningBorder ?? this.warningBorder,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      infoBorder: infoBorder ?? this.infoBorder,
      neutral: neutral ?? this.neutral,
      neutralContainer: neutralContainer ?? this.neutralContainer,
      neutralBorder: neutralBorder ?? this.neutralBorder,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      infoBorder: Color.lerp(infoBorder, other.infoBorder, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralContainer: Color.lerp(neutralContainer, other.neutralContainer, t)!,
      neutralBorder: Color.lerp(neutralBorder, other.neutralBorder, t)!,
    );
  }
}
