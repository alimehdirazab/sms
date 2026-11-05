import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum EduCoreButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

/// Tactile, quiet luxury button component aligned with DESIGN.md Section 7.1.
/// Maintains backwards compatibility with [AnimatedBouncyButton].
class AnimatedBouncyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExpanded;
  final double? width;
  final double height;
  final bool isLoading;
  final EduCoreButtonVariant variant;

  const AnimatedBouncyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isExpanded = true,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
    this.variant = EduCoreButtonVariant.primary,
  });

  @override
  State<AnimatedBouncyButton> createState() => _AnimatedBouncyButtonState();
}

class _AnimatedBouncyButtonState extends State<AnimatedBouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    Color border;

    if (!isEnabled) {
      bg = AppColors.surfaceInset;
      fg = AppColors.inkFaint;
      border = AppColors.border;
    } else if (widget.backgroundColor != null) {
      bg = widget.backgroundColor!;
      fg = widget.foregroundColor ?? Colors.white;
      border = widget.backgroundColor!;
    } else {
      switch (widget.variant) {
        case EduCoreButtonVariant.primary:
          bg = AppColors.accent;
          fg = Colors.white;
          border = AppColors.accent;
          break;
        case EduCoreButtonVariant.secondary:
          bg = AppColors.surface;
          fg = AppColors.ink;
          border = AppColors.border;
          break;
        case EduCoreButtonVariant.outline:
          bg = AppColors.surface;
          fg = AppColors.inkSecondary;
          border = AppColors.borderHover;
          break;
        case EduCoreButtonVariant.ghost:
          bg = Colors.transparent;
          fg = AppColors.inkSecondary;
          border = Colors.transparent;
          break;
        case EduCoreButtonVariant.destructive:
          bg = AppColors.surface;
          fg = AppColors.danger;
          border = AppColors.dangerBorder;
          break;
      }
    }

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.isExpanded ? widget.width ?? double.infinity : widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border, width: 1),
            boxShadow: (widget.variant == EduCoreButtonVariant.primary && isEnabled)
                ? const [
                    BoxShadow(
                      color: Color(0x0A2E2E99),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
