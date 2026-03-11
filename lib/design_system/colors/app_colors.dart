import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF5F5F7);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFFD6EAFF);
  static const Color green = Color(0xFF34C759);
  static const Color greenLight = Color(0xFFD4F5DC);
  static const Color orange = Color(0xFFFF9500);
  static const Color red = Color(0xFFFF3B30);
  static const Color redLight = Color(0xFFFFE5E3);
  static const Color purple = Color(0xFFAF52DE);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color teal = Color(0xFF5AC8FA);
  static const Color indigo = Color(0xFF5856D6);
  static const Color pink = Color(0xFFFF2D55);

  static const Color coin = Color(0xFFFFB800);
  static const Color coinDark = Color(0xFFE5A600);
  static const Color coinLight = Color(0xFFFFF4D6);

  static const Color streak = Color(0xFFFF6B00);
  static const Color streakLight = Color(0xFFFFE8D6);

  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE5E5EA);
  static const Color borderLight = Color(0xFFF2F2F7);
  static const Color divider = Color(0xFFD1D1D6);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color inactive = Color(0xFFC7C7CC);

  static const Color navActive = Color(0xFF1C1C1E);
  static const Color navInactive = Color(0xFF8E8E93);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static const LinearGradient coinGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCC4D), Color(0xFFFFB800), Color(0xFFE5A600)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007AFF), Color(0xFF0055D4)],
  );

  static const LinearGradient streakGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
  );
}
