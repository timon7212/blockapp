import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/gradient_background.dart';

/// Redesigned auth screen.
///
/// Key UX improvements over v1:
/// - Social sign-in buttons FIRST (lowest friction)
/// - Default to Sign Up (new users coming from welcome)
/// - Warm, friendly header with emoji-style icon
/// - Collapsible referral code field
/// - Toggle "Already have an account?" at the bottom
/// - Error banner with shake animation
class AuthScreen extends ConsumerStatefulWidget {
  final bool initialLoginMode;

  const AuthScreen({super.key, this.initialLoginMode = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _nameC = TextEditingController();
  final _referralC = TextEditingController();
  bool _obscure = true;
  bool _showReferral = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialLoginMode;
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    _nameC.dispose();
    _referralC.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();

    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isLogin) {
      notifier.login(
        email: _emailC.text.trim(),
        password: _passwordC.text,
      );
    } else {
      notifier.register(
        email: _emailC.text.trim(),
        password: _passwordC.text,
        displayName: _nameC.text.trim(),
        referralCode:
            _referralC.text.trim().isEmpty ? null : _referralC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 28),

                // ── Header Icon ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_isLogin),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient:
                          _isLogin ? null : AppColors.primaryGradient,
                      color: _isLogin ? AppColors.surface : null,
                      borderRadius: BorderRadius.circular(20),
                      border: _isLogin
                          ? Border.all(color: AppColors.border)
                          : null,
                      boxShadow: _isLogin
                          ? null
                          : [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 24,
                                spreadRadius: -4,
                              ),
                            ],
                    ),
                    child: Icon(
                      _isLogin
                          ? Icons.waving_hand_rounded
                          : Icons.celebration_rounded,
                      size: 28,
                      color:
                          _isLogin ? AppColors.primary : Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 18),

                // ── Title ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    key: ValueKey('title_$_isLogin'),
                    style: AppTypography.displaySmall
                        .copyWith(fontSize: 26),
                  ),
                ),

                const SizedBox(height: 6),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _isLogin
                        ? 'Sign in to continue earning'
                        : 'Start turning screen time into rewards',
                    key: ValueKey('sub_$_isLogin'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Social Sign-In (lowest friction first) ──
                _SocialAuthButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  onTap: () => _showComingSoon('Google'),
                ),
                const SizedBox(height: 10),
                _SocialAuthButton(
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple (soon)',
                  onTap: null,
                  disabled: true,
                ),

                const SizedBox(height: 22),

                // ── Divider ──
                Row(
                  children: [
                    Expanded(
                      child:
                          Divider(color: AppColors.border, thickness: 1),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or with email',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          Divider(color: AppColors.border, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ── Email Verification Banner ──
                if (authState.needsEmailVerification) ...[
                  _VerificationBanner(
                    email: _emailC.text.trim(),
                    onDismiss: () => ref
                        .read(authNotifierProvider.notifier)
                        .clearError(),
                  ),
                  const SizedBox(height: 14),
                ]
                // ── Generic Error Banner ──
                else if (authState.error != null) ...[
                  _ErrorBanner(
                    message: authState.error!,
                    onDismiss: () => ref
                        .read(authNotifierProvider.notifier)
                        .clearError(),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Form ──
                Form(
                  key: _formKey,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        // Name field (sign up only)
                        if (!_isLogin) ...[
                          _InputField(
                            controller: _nameC,
                            label: 'Your name',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        _InputField(
                          controller: _emailC,
                          label: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || !v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _InputField(
                          controller: _passwordC,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 8) {
                              return 'At least 8 characters';
                            }
                            return null;
                          },
                        ),

                        // Referral code (sign up only, collapsible)
                        if (!_isLogin) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(
                                () => _showReferral = !_showReferral),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showReferral
                                      ? Icons.remove_circle_outline
                                      : Icons
                                          .add_circle_outline_rounded,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Have a referral code?',
                                  style:
                                      AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showReferral) ...[
                            const SizedBox(height: 12),
                            _InputField(
                              controller: _referralC,
                              label: 'Referral Code',
                              icon: Icons.card_giftcard_rounded,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ── Submit Button ──
                _GradientButton(
                  label: _isLogin ? 'Sign In' : 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _submit,
                ),

                const SizedBox(height: 20),

                // ── Toggle sign-in / sign-up ──
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isLogin = !_isLogin;
                      _showReferral = false;
                      ref
                          .read(authNotifierProvider.notifier)
                          .clearError();
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      style:
                          AppTypography.bodyMedium.copyWith(fontSize: 13),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: const TextStyle(
                              color: AppColors.textTertiary),
                        ),
                        TextSpan(
                          text: _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Terms of Service ──
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),

                // ── Dev Mode Bypass (debug only) ──
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(authNotifierProvider.notifier)
                          .devBypass();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.developer_mode_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Dev Mode — Skip',
                            style: AppTypography.caption.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: bottomPadding + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider Sign-In coming soon'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT FIELD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style:
          AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySmall
            .copyWith(color: AppColors.textTertiary),
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOCIAL AUTH BUTTON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || onTap == null;
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GRADIENT SUBMIT BUTTON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.primaryGradient,
          color: isLoading ? AppColors.surfaceLight : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.button
                      .copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ERROR BANNER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded,
                color: AppColors.error.withValues(alpha: 0.6), size: 16),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .shake(hz: 2, rotation: 0.015, duration: 400.ms);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMAIL VERIFICATION BANNER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _VerificationBanner extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onDismiss;

  const _VerificationBanner({
    required this.email,
    required this.onDismiss,
  });

  @override
  ConsumerState<_VerificationBanner> createState() =>
      _VerificationBannerState();
}

class _VerificationBannerState extends ConsumerState<_VerificationBanner> {
  bool _resending = false;
  String? _resendMessage;

  void _resend() async {
    if (_resending || widget.email.isEmpty) return;
    setState(() {
      _resending = true;
      _resendMessage = null;
    });
    final msg = await ref
        .read(authNotifierProvider.notifier)
        .resendVerification(widget.email);
    if (mounted) {
      setState(() {
        _resending = false;
        _resendMessage = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_email_unread_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please verify your email to sign in',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(Icons.close_rounded,
                    color: AppColors.warning.withValues(alpha: 0.6),
                    size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Check your inbox for a verification link.',
            style: AppTypography.caption.copyWith(
              color: AppColors.warning.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _resend,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _resending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.warning,
                      ),
                    )
                  : Text(
                      _resendMessage ?? 'Resend Verification Email',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .shake(hz: 2, rotation: 0.01, duration: 400.ms);
  }
}
