import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glossy_3d_icons.dart';

class FintechNavItem {
  final String iconType; // 'home', 'discover', 'billing', 'account'
  final String label;

  const FintechNavItem({
    required this.iconType,
    required this.label,
  });
}

/// Luxury Fintech Bottom Navigation Bar matching Image 2
class FintechNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterActionTap;
  final String centerActionLabel;
  final List<FintechNavItem> items;

  const FintechNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterActionTap,
    this.centerActionLabel = 'Complaint',
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Items are arranged: [Item 0, Item 1, Center Button, Item 2, Item 3]
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main bottom bar surface
        Container(
          height: 68 + (bottomPadding > 0 ? bottomPadding : 10),
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding > 0 ? bottomPadding : 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (items.isNotEmpty) _buildNavItem(0, items[0]),
              if (items.length > 1) _buildNavItem(1, items[1]),
              // Placeholder gap for center elevated button
              const SizedBox(width: 68),
              if (items.length > 2) _buildNavItem(2, items[2]),
              if (items.length > 3) _buildNavItem(3, items[3]),
            ],
          ),
        ),

        // Center elevated circular button (Image 2)
        Positioned(
          top: -24,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
              if (onCenterActionTap != null) {
                onCenterActionTap!();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9E00), Color(0xFFFF6D00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  centerActionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, FintechNavItem item) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Glossy3DIcon(
                type: item.iconType,
                isSelected: isSelected,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF8E8E93),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
