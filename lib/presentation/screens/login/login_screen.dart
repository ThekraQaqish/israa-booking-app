import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isra_fields_booking/core/constants/app_constants.dart';
import 'package:isra_fields_booking/core/theme/app_colors.dart';
import 'package:isra_fields_booking/core/theme/app_text_styles.dart';
import 'package:isra_fields_booking/core/widgets/custom_button.dart';
import 'package:isra_fields_booking/presentation/providers/auth_provider.dart';
import 'package:isra_fields_booking/presentation/providers/auth_state.dart';
import 'package:isra_fields_booking/presentation/widgets/student_id_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();

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

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _shakeController.forward(from: 0);
      return;
    }

    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .login(_studentIdController.text.trim());
  }

  void _onAuthStateChanged(AuthState? previous, AuthState next) {
    if (next is AuthError) {
      _shakeController.forward(from: 0);
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
    ref.listen<AuthState>(authProvider, _onAuthStateChanged);

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppConstants.paddingXXL),
                _buildHeader(),
                const SizedBox(height: AppConstants.paddingXXL),
                _buildForm(isLoading, errorMessage),
                const SizedBox(height: AppConstants.paddingXL),
                AppButton(
                  label: 'Login',
                  onPressed: isLoading ? null : _handleLogin,
                  isLoading: isLoading,
                  prefixIcon: isLoading ? null : Icons.login_rounded,
                ),
                const SizedBox(height: AppConstants.paddingL),
                _buildHelpText(),
                const SizedBox(height: AppConstants.paddingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            size: 52,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),
        Text('Welcome Back!', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppConstants.paddingS),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
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
        final offset =
            _shakeAnimation.value * 10 * (1 - _shakeAnimation.value);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Card wrapper
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXL),
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
                    style: AppTextStyles.headingSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  StudentIdTextField(
                    controller: _studentIdController,
                    enabled: !isLoading,
                    onChanged: (_) {
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
                        return 'Must be exactly ${AppConstants.studentIdLength} digits.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Error banner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
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

            const SizedBox(height: AppConstants.paddingM),

            // Dev hint card
            _DevHintCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Column(
      children: [
        Text('Having trouble logging in?', style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Contact IT department at it@isra.edu.jo'),
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

// ── Error Banner ──────────────────────────────────────────────────────────────

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
                Text('Login Failed',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.error)),
                const SizedBox(height: 2),
                Text(message,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dev Hint Card ─────────────────────────────────────────────────────────────

class _DevHintCard extends StatelessWidget {
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
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          ...AppConstants.mockValidStudentIds.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $id',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Note: ID ending in 050 is suspended (tests error state)',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}