import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = enabled
        ? (gradient ?? AppColors.primaryGradient)
        : null;

    return GestureDetector(
      onTap: enabled && !isLoading
          ? () {
              HapticFeedback.mediumImpact();
              onPressed?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          color: enabled ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: enabled ? Colors.white : AppColors.textTertiary, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: enabled ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
