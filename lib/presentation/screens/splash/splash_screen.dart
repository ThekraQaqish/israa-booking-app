import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';

/// ---------------------------------------------------------------------------
/// Splash Screen — entry point of the app.
///
/// Shows the university logo + app name for [AppConstants.splashDuration],
/// then navigates based on authentication state:
///   Authenticated   → /home
///   Unauthenticated → /login
/// ---------------------------------------------------------------------------
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _textSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      context.go(RouteConstants.home);
    } else {
      context.go(RouteConstants.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Main Content ───────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ────────────────────────────────────────────────
                    FadeTransition(
                      opacity: _logoFadeAnim,
                      child: ScaleTransition(
                        scale: _logoScaleAnim,
                        child: _buildLogoCircle(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── App Name ────────────────────────────────────────────
                    FadeTransition(
                      opacity: _textFadeAnim,
                      child: SlideTransition(
                        position: _textSlideAnim,
                        child: _buildTextBlock(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ─────────────────────────────────────────────────────
            FadeTransition(
              opacity: _textFadeAnim,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCircle() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.sports_soccer_rounded,
          size: 64,
          color: AppColors.primary,
        ),
        // FUTURE: Replace Icon with Image.asset(AppConstants.logoPath)
      ),
    );
  }

  Widget _buildTextBlock() {
    return Column(
      children: [
        Text(
          AppConstants.universityName,
          style: AppTextStyles.headingMedium.copyWith(
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Fields Booking',
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
          ),
          child: Text(
            '⚽  Students Only',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.secondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}