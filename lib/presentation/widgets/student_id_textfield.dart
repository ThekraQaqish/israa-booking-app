import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';

/// ---------------------------------------------------------------------------
/// Reusable Student ID input widget.
///
/// Features:
///  - Numeric-only keyboard
///  - 10-digit hard character limit
///  - Live digit counter (e.g., 7 / 10)
///  - Inline validation feedback
///  - Animated border on focus
///  - Optional clear button
/// ---------------------------------------------------------------------------
class StudentIdTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFieldSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  const StudentIdTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<StudentIdTextField> createState() => _StudentIdTextFieldState();
}

class _StudentIdTextFieldState extends State<StudentIdTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderAnimController;
  late Animation<double> _borderAnim;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _borderAnimController = AnimationController(
      vsync: this,
      duration: AppConstants.animationFast,
    );
    _borderAnim = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _borderAnimController, curve: Curves.easeOut),
    );
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _borderAnimController.forward();
    } else {
      _borderAnimController.reverse();
    }
  }

  void _handleChanged(String value) {
    // Clear error as user types
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
    widget.onChanged?.call(value);
    setState(() {}); // Refresh counter
  }

  void _validate() {
    final validator = widget.validator ?? AppValidators.validateStudentId;
    setState(() {
      _errorText = validator(widget.controller.text);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    _borderAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = widget.controller.text.length;
    final isComplete = currentLength == AppConstants.studentIdLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.badge_outlined,
              size: AppConstants.iconSizeS,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.paddingXS),
            Text(
              'Student ID',
              style: AppTextStyles.labelLarge.copyWith(
                color: _errorText != null
                    ? AppColors.error
                    : _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // ── Digit Counter ──────────────────────────────────────────────
            AnimatedSwitcher(
              duration: AppConstants.animationFast,
              child: Text(
                '$currentLength / ${AppConstants.studentIdLength}',
                key: ValueKey(currentLength),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isComplete
                      ? AppColors.success
                      : _errorText != null
                          ? AppColors.error
                          : AppColors.textHint,
                  fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingS),

        // ── Input Field ───────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _borderAnim,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.input.copyWith(
                letterSpacing: 3.0, // Spacious digits for readability
                fontWeight: FontWeight.w600,
              ),
              maxLength: AppConstants.studentIdLength,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AppConstants.studentIdLength),
              ],
              decoration: InputDecoration(
                hintText: '_ _ _ _ _ _ _ _ _ _',
                hintStyle: AppTextStyles.inputHint.copyWith(
                  letterSpacing: 3.0,
                ),
                counterText: '', // Hide the default counter (we have a custom one)
                prefixIcon: const Icon(
                  Icons.dialpad_rounded,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeM,
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? _buildSuffixIcon(isComplete)
                    : null,
                // Override border color based on state
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(
                    color: _errorText != null
                        ? AppColors.inputErrorBorder
                        : isComplete
                            ? AppColors.success
                            : AppColors.inputBorder,
                    width: _borderAnim.value,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(
                    color: _errorText != null
                        ? AppColors.inputErrorBorder
                        : AppColors.inputFocusedBorder,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(
                    color: AppColors.inputErrorBorder,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: widget.enabled
                    ? AppColors.inputFill
                    : AppColors.surfaceVariant,
                errorText: null, // We render error manually below
              ),
              onChanged: _handleChanged,
              onFieldSubmitted: (_) {
                _validate();
                widget.onFieldSubmitted?.call();
              },
              validator: (_) => _errorText, // Bridge to Form validation
            );
          },
        ),

        // ── Error Message ─────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: AppConstants.animationFast,
          child: _errorText != null
              ? Padding(
                  key: const ValueKey('error'),
                  padding: const EdgeInsets.only(
                    top: AppConstants.paddingXS,
                    left: AppConstants.paddingXS,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: AppTextStyles.inputError,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-error')),
        ),
      ],
    );
  }

  Widget _buildSuffixIcon(bool isComplete) {
    if (isComplete) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
      );
    }
    return IconButton(
      icon: const Icon(Icons.clear_rounded, color: AppColors.textHint),
      onPressed: () {
        widget.controller.clear();
        setState(() => _errorText = null);
        widget.onChanged?.call('');
      },
    );
  }

  /// Expose external validation trigger (e.g., from login button press).
  void validate() => _validate();
}