import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';
import '../utils/app_bottom_sheet.dart';
import 'primary_button.dart';

class ResultSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? valueWidget;
  final String buttonLabel;
  final VoidCallback onDismiss;

  const ResultSheet({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.valueWidget,
    this.buttonLabel = 'Continue',
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? valueWidget,
    String buttonLabel = 'Continue',
  }) {
    HapticFeedback.heavyImpact();
    return showAppBottomSheet(
      context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => ResultSheet(
        icon: icon,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        valueWidget: valueWidget,
        buttonLabel: buttonLabel,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ).animate().scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
          ],
          if (valueWidget != null) ...[
            const SizedBox(height: 20),
            valueWidget!.animate().fadeIn(duration: 300.ms, delay: 200.ms),
          ],
          const SizedBox(height: 28),
          PrimaryButton(
            label: buttonLabel,
            onPressed: onDismiss,
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
        ],
      ),
    );
  }
}
