import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/gradient_background.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  void _signIn(WidgetRef ref) {
    HapticFeedback.heavyImpact();
    ref.read(authProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                Text(
                  'DoomScroll',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),

                const SizedBox(height: 12),

                Text(
                  'Turn screen time into rewards',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 200.ms, duration: 500.ms),

                const Spacer(flex: 2),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.accent.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 52,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1, end: 1.05, duration: 2400.ms, curve: Curves.easeInOut)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms),

                const Spacer(flex: 3),

                _AuthButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  onTap: () => _signIn(ref),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 12),

                _AuthButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.textPrimary,
                  iconColor: AppColors.textPrimary,
                  borderColor: AppColors.border,
                  onTap: () => _signIn(ref),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 12),

                _AuthButton(
                  label: 'Continue with Email',
                  icon: Icons.email_outlined,
                  backgroundColor: AppColors.surfaceMid,
                  textColor: AppColors.textSecondary,
                  iconColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                  onTap: () => _signIn(ref),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms),

                SizedBox(height: bottomPadding + 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.button.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
