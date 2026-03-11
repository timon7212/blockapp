import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class CoinBadge extends StatelessWidget {
  final int amount;
  final double fontSize;
  final bool showPlus;

  const CoinBadge({
    super.key,
    required this.amount,
    this.fontSize = 15,
    this.showPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: fontSize + 4,
          height: fontSize + 4,
          decoration: const BoxDecoration(
            gradient: AppColors.coinGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: fontSize * 0.6,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${showPlus ? '+' : ''}$amount',
          style: AppTypography.labelLarge.copyWith(
            fontSize: fontSize,
            color: AppColors.coin,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
