import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../colors/app_colors.dart';

class CoinBadge extends StatelessWidget {
  final int amount;
  final double fontSize;

  const CoinBadge({
    super.key,
    required this.amount,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: fontSize * 0.85,
            height: fontSize * 0.85,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textTertiary, width: 1),
            ),
          ),
          SizedBox(width: fontSize * 0.4),
          Text(
            Formatters.points(amount),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
