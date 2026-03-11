import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _display = '.SF Pro Display';
  static const String _text = '.SF Pro Text';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _display, fontSize: 48, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -1.5, height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _display, fontSize: 34, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.15,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _display, fontSize: 28, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.4, height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _display, fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _display, fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _text, fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _text, fontSize: 17, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _text, fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _text, fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textTertiary, height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _text, fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _text, fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _text, fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textTertiary, letterSpacing: 0.3,
  );

  static const TextStyle repCount = TextStyle(
    fontFamily: _display, fontSize: 64, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -2, height: 1.0,
  );

  static const TextStyle coinValue = TextStyle(
    fontFamily: _display, fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.coin,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _text, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textTertiary, letterSpacing: 0.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _text, fontSize: 17, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.2,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _text, fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textTertiary, letterSpacing: 1.0,
  );
}
