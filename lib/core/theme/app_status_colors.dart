import 'package:flutter/material.dart';

/// Centralised semantic colours for status indicators (attendance, marks,
/// fee verification, leave status...). Registered as a [ThemeExtension] on
/// both light and dark themes so screens never hardcode literal colours.
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;

  final Color danger;
  final Color onDanger;
  final Color dangerContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;

  final Color neutral;
  final Color neutralContainer;

  const AppStatusColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.neutral,
    required this.neutralContainer,
  });

  static const AppStatusColors light = AppStatusColors(
    success: Color(0xFF1B873F),
    onSuccess: Colors.white,
    successContainer: Color(0xFFD8F3E1),
    warning: Color(0xFFB25E00),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFE7C7),
    danger: Color(0xFFBA1A1A),
    onDanger: Colors.white,
    dangerContainer: Color(0xFFFFDAD6),
    info: Color(0xFF1565C0),
    onInfo: Colors.white,
    infoContainer: Color(0xFFD6E6FF),
    neutral: Color(0xFF6B7280),
    neutralContainer: Color(0xFFEDEFF2),
  );

  static const AppStatusColors dark = AppStatusColors(
    success: Color(0xFF6FD68F),
    onSuccess: Color(0xFF00391A),
    successContainer: Color(0xFF10502A),
    warning: Color(0xFFFFB95C),
    onWarning: Color(0xFF4A2800),
    warningContainer: Color(0xFF6B3D00),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF690005),
    dangerContainer: Color(0xFF93000A),
    info: Color(0xFF9CCAFF),
    onInfo: Color(0xFF00305F),
    infoContainer: Color(0xFF134B85),
    neutral: Color(0xFFB7BCC5),
    neutralContainer: Color(0xFF3A3F46),
  );

  /// Convenience accessor with a safe fallback when the extension is absent.
  static AppStatusColors of(BuildContext context) =>
      Theme.of(context).extension<AppStatusColors>() ?? light;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? neutral,
    Color? neutralContainer,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      neutral: neutral ?? this.neutral,
      neutralContainer: neutralContainer ?? this.neutralContainer,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralContainer: Color.lerp(neutralContainer, other.neutralContainer, t)!,
    );
  }
}
