import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../repositories/auth_repository.dart';

/// Splash screen aligned with DESIGN.md Section 2 (Auth Brand Panel Tokens)
/// and Section 5 (Logo Mark Specification).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 1800));
    final authBloc = context.read<AuthBloc>();
    final authRepo = context.read<AuthRepository>();

    AuthState authState = authBloc.state;
    if (authState is AuthInitial || authState is AuthLoading) {
      try {
        authState = await authBloc.stream
            .firstWhere((s) => s is! AuthInitial && s is! AuthLoading)
            .timeout(const Duration(milliseconds: 2500));
      } catch (_) {
        try {
          final cachedUser = await authRepo.getCachedUser();
          if (cachedUser != null) {
            authState = AuthSuccess(user: cachedUser);
          } else {
            authState = const AuthUnauthenticated();
          }
        } catch (_) {
          authState = const AuthUnauthenticated();
        }
      }
    }

    await minDelay;
    if (!mounted) return;

    if (authState is AuthSuccess) {
      final role = authState.role.toUpperCase();
      if (role == 'TEACHER') {
        context.goNamed(RouteNames.teacherHome);
      } else {
        context.goNamed(RouteNames.parentHome);
      }
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: Stack(
        children: [
          // Ambient radial glow top-center
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandGlow,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark matching DESIGN.md Section 5
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B2F8F),
                          Color(0xFF231A5C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x474C3AAA),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'EduCore',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 36,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      letterSpacing: -0.02 * 36,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'School Management ERP',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withValues(alpha: 0.70),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
