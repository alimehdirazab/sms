import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderFaint),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.school_outlined,
                  size: 34,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'School Management System',
                style: GoogleFonts.instrumentSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: AppColors.ink,
                  letterSpacing: -0.02 * 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your portal to continue',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.inkSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              _RoleCard(
                title: "I'm a Parent",
                subtitle: "Track your child's progress, attendance & fees",
                icon: Icons.family_restroom_outlined,
                onTap: () => context.goNamed(RouteNames.parentLogin),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: "I'm a Teacher",
                subtitle: 'Manage attendance, marks & weekly schedules',
                icon: Icons.person_pin_outlined,
                onTap: () => context.goNamed(RouteNames.teacherLogin),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInset,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderFaint),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: AppColors.accent, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.inkSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
