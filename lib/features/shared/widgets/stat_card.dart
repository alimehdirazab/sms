import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_status_colors.dart';

/// Editorial KPI Metric Card matching DESIGN.md Section 7.6 & Section 8.2.
/// - Surface: Pure white, 14px radius, 1px border #E8E6E1
/// - Top label: 12px font-medium sentence case (#71717A)
/// - Metric numeral: Instrument Serif italic (32-38px) in #18181B
/// - Bottom supporting caption or status dot (#A1A1AA / semantic)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? caption;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.caption,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInset,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: color ?? AppColors.inkSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.instrumentSerif(
              fontSize: 32,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: AppColors.ink,
              letterSpacing: -0.02 * 32,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: AppColors.inkFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A 6px semantic status dot paired with sentence-case text.
/// Matches DESIGN.md Section 1, 2 & 7.3 ("Status = Dot + Text").
class StatusDot extends StatelessWidget {
  final String label;
  final Color color;
  final double dotSize;

  const StatusDot({
    super.key,
    required this.label,
    required this.color,
    this.dotSize = 6.0,
  });

  factory StatusDot.semantic(
    BuildContext context, {
    required String label,
    required String kind,
  }) {
    final status = AppStatusColors.of(context);
    final color = switch (kind.toLowerCase()) {
      'success' || 'approved' || 'present' => status.success,
      'warning' || 'pending' || 'half-day' => status.warning,
      'danger' || 'rejected' || 'absent' => status.danger,
      'info' => status.info,
      _ => status.neutral,
    };
    return StatusDot(label: label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Quiet editorial badge pill matching DESIGN.md Section 7.3.
/// Full pill 9999px radius, 1px semantic border, subtle tint background,
/// 6px dot, and sentence-case 11px text.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final bool filled;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.filled = false,
  });

  /// Factory that maps a semantic name to an [AppStatusColors] entry.
  factory StatusPill.semantic(
    BuildContext context, {
    required String label,
    required String kind,
    IconData? icon,
  }) {
    final status = AppStatusColors.of(context);
    final (fg, bg, border) = switch (kind.toLowerCase()) {
      'success' || 'approved' || 'present' => (
          status.success,
          status.successContainer,
          status.successBorder,
        ),
      'warning' || 'pending' || 'half-day' => (
          status.warning,
          status.warningContainer,
          status.warningBorder,
        ),
      'danger' || 'rejected' || 'absent' => (
          status.danger,
          status.dangerContainer,
          status.dangerBorder,
        ),
      'info' => (
          status.info,
          status.infoContainer,
          status.infoBorder,
        ),
      _ => (
          status.neutral,
          status.neutralContainer,
          status.neutralBorder,
        ),
    };

    return StatusPill(
      label: label,
      color: fg,
      backgroundColor: bg,
      borderColor: border,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.10);
    final border = borderColor ?? color.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: filled ? color : border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: filled ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: filled ? Colors.white : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading with optional trailing action, used to structure long
/// scrolling dashboards consistently.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
