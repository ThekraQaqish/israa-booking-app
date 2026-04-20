import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';
import '../../widgets/student_id_text_field.dart';

/// ---------------------------------------------------------------------------
/// Login Screen — student ID-based authentication.
///
/// States handled:
///   AuthInitial       → idle form
///   AuthLoading       → button shows spinner, field disabled
///   AuthError         → error banner displayed, form re-enabled
///   AuthAuthenticated → router redirect handles navigation automatically
/// ---------------------------------------------------------------------------
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _studentIdFieldKey = GlobalKey<FormFieldState>();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Client-side validation first
    if (!(_formKey.currentState?.validate() ?? false)) {
      _shakeController.forward(from: 0);
      return;
    }

    // Clear any previous auth error
    ref.read(authProvider.notifier).clearError();

    // Trigger login
    await ref
        .read(authProvider.notifier)
        .login(_studentIdController.text.trim());
  }

  void _onAuthStateChanged(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated) {
      // Router redirect handles navigation — nothing needed here
      return;
    }

    if (next is AuthError) {
      // Shake the form on error
      _shakeController.forward(from: 0);
      // Show SnackBar for accessibility in addition to inline error
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to navigate on success and shake on error
    ref.listen<AuthState>(authProvider, _onAuthStateChanged);

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage =
        authState is AuthError ? (authState).message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppConstants.paddingXXL),

                // ── Header ─────────────────────────────────────────────────
                _buildHeader(),
                const SizedBox(height: AppConstants.paddingXXL),

                // ── Form ───────────────────────────────────────────────────
                _buildForm(isLoading, errorMessage),
                const SizedBox(height: AppConstants.paddingXL),

                // ── Login Button ───────────────────────────────────────────
                AppButton(
                  label: 'Login',
                  onPressed: isLoading ? null : _handleLogin,
                  isLoading: isLoading,
                  prefixIcon: isLoading ? null : Icons.login_rounded,
                ),
                const SizedBox(height: AppConstants.paddingL),

                // ── Help Text ──────────────────────────────────────────────
                _buildHelpText(),
                const SizedBox(height: AppConstants.paddingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget Builders ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        // ── Logo ──────────────────────────────────────────────────────────
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.sports_soccer_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),

        // ── Title ─────────────────────────────────────────────────────────
        Text(
          'Welcome Back!',
          style: AppTextStyles.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingS),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Sign in with your\n'),
              TextSpan(
                text: 'Isra University Student ID',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading, String? errorMessage) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset =
            _shakeAnimation.value * 10 * (1 - _shakeAnimation.value);
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Wrapper ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Credentials',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // ── Student ID Field ───────────────────────────────────
                  StudentIdTextField(
                    controller: _studentIdController,
                    enabled: !isLoading,
                    onChanged: (_) {
                      // Clear auth-level error when user starts typing
                      if (ref.read(authProvider) is AuthError) {
                        ref.read(authProvider.notifier).clearError();
                      }
                    },
                    onFieldSubmitted: _handleLogin,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Student ID is required.';
                      }
                      if (value.length != AppConstants.studentIdLength) {
                        return 'Student ID must be exactly ${AppConstants.studentIdLength} digits.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // ── Auth Error Banner ─────────────────────────────────────────
            AnimatedSwitcher(
              duration: AppConstants.animationNormal,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: errorMessage != null
                  ? Padding(
                      key: ValueKey(errorMessage),
                      padding: const EdgeInsets.only(
                          top: AppConstants.paddingM),
                      child: _ErrorBanner(message: errorMessage),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-error')),
            ),

            // ── Hint for testing ──────────────────────────────────────────
            const SizedBox(height: AppConstants.paddingM),
            _MockHintCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Column(
      children: [
        Text(
          'Having trouble logging in?',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextButton.icon(
          onPressed: () {
            // FUTURE: Open help dialog or contact screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact the IT department at it@isra.edu.jo'),
              ),
            );
          },
          icon: const Icon(Icons.help_outline_rounded, size: 16),
          label: const Text('Contact IT Support'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: AppConstants.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login Failed',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dev-only hint card showing valid test IDs. Remove before going to production.
class _MockHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined,
                  color: AppColors.info, size: 16),
              const SizedBox(width: 6),
              Text(
                'DEV MODE — Test Student IDs',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.info, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          ...AppConstants.mockValidStudentIds.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $id',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            'Note: ID ending in 050 is suspended (tests error state)',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}