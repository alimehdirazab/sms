import 'package:flutter/material.dart';

/// Authoritative design tokens for EduCore: Quiet Editorial Luxury.
/// Source of truth: DESIGN.md
abstract class AppColors {
  // Page Background & Surfaces
  static const Color bg = Color(0xFFFAF9F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceInset = Color(0xFFF5F4F1);
  static const Color surfaceHover = Color(0xFFF8F7F5);

  // Hairline Borders & Dividers
  static const Color border = Color(0xFFE8E6E1);
  static const Color borderFaint = Color(0xFFF0EEE9);
  static const Color borderHover = Color(0xFFDCDAD4);

  // Ink (Typography & Content)
  static const Color ink = Color(0xFF18181B);
  static const Color inkSecondary = Color(0xFF52525B);
  static const Color inkMuted = Color(0xFF71717A);
  static const Color inkFaint = Color(0xFFA1A1AA);

  // Accent (Deep Indigo Brand)
  static const Color accent = Color(0xFF2E2E99);
  static const Color accentHover = Color(0xFF24247A);
  static const Color accentPressed = Color(0xFF1B1B5C);
  static const Color accentTint = Color(0xFFECECF9);
  static const Color focusRing = Color(0x332E2E99); // rgba(46, 46, 153, 0.20)

  // Semantic - Success
  static const Color success = Color(0xFF2D6A4F);
  static const Color successBg = Color(0xFFEAF4ED);
  static const Color successBorder = Color(0xFFC6E2CD);

  // Semantic - Warning
  static const Color warning = Color(0xFF995D00);
  static const Color warningBg = Color(0xFFFEF6E9);
  static const Color warningBorder = Color(0xFFF8DFB4);

  // Semantic - Danger
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerBg = Color(0xFFFDF2F2);
  static const Color dangerBorder = Color(0xFFF8C8C8);

  // Semantic - Info
  static const Color info = Color(0xFF2E2E99);
  static const Color infoBg = Color(0xFFECECF9);
  static const Color infoBorder = Color(0xFFC5C5EE);

  // Semantic - Neutral
  static const Color neutral = Color(0xFF71717A);
  static const Color neutralDot = Color(0xFFA1A1AA);
  static const Color neutralBg = Color(0xFFF5F4F1);
  static const Color neutralBorder = Color(0xFFE8E6E1);

  // Auth Brand Panel
  static const Color brandBg = Color(0xFF141233);
  static const Color brandGlow = Color(0x523B2F8F); // rgba(59, 47, 143, 0.32)
  static const Color brandGrid = Color(0x08FFFFFF);
  static const Color brandDivider = Color(0x26FFFFFF);
}

/// Border radius tokens matching DESIGN.md Section 4
abstract class AppRadius {
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 18.0;
  static const double full = 9999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}

/// Shadows matching DESIGN.md Section 4
abstract class AppShadows {
  /// Subtle near-flat shadow for cards at rest: 0 1px 2px rgba(24, 24, 27, 0.03)
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0818181B),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Popover / dropdown shadow: 0 4px 16px rgba(24, 24, 27, 0.06)
  static const List<BoxShadow> popover = [
    BoxShadow(
      color: Color(0x0F18181B),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Modal overlay shadow: 0 24px 48px -16px rgba(15, 23, 42, 0.18)
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x2E0F172A),
      blurRadius: 48,
      spreadRadius: -16,
      offset: Offset(0, 24),
    ),
  ];
}

