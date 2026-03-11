import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.width,
    this.height = 56,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.textPrimary;

    return GestureDetector(
      onTap: enabled && !isLoading
          ? () {
              HapticFeedback.mediumImpact();
              onPressed();
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : buttonColor,
            borderRadius: BorderRadius.circular(16),
            border: outlined
                ? Border.all(color: AppColors.border, width: 1.5)
                : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: outlined ? buttonColor : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: outlined ? buttonColor : Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTypography.button.copyWith(
                          color: outlined ? AppColors.textPrimary : Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
