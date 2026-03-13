import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Core Dark (warmer, softer) ───
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF131316);
  static const Color surfaceMid = Color(0xFF1A1A1F);
  static const Color surfaceLight = Color(0xFF222228);
  static const Color surfaceGlass = Color(0x08FFFFFF);

  // ─── Primary (refined purple) ───
  static const Color primary = Color(0xFF8B7CF6);
  static const Color primaryLight = Color(0xFFA5A0F8);
  static const Color primaryDark = Color(0xFF6D5DD3);
  static const Color primaryMuted = Color(0x1A8B7CF6);

  // ─── Accent (used sparingly) ───
  static const Color accent = Color(0xFF67E8F9);
  static const Color accentMuted = Color(0x1A67E8F9);

  // ─── Success ───
  static const Color success = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successMuted = Color(0x1A34D399);

  // ─── Points (clean white-silver instead of gold) ───
  static const Color points = Color(0xFFF0F0F0);
  static const Color pointsDim = Color(0xFF9CA3AF);
  static const Color pointsMuted = Color(0x14F0F0F0);

  // ─── Semantic ───
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningMuted = Color(0x1AFBBF24);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textInverse = Color(0xFF09090B);

  // ─── Borders ───
  static const Color border = Color(0xFF27272A);
  static const Color borderLight = Color(0xFF1F1F23);
  static const Color borderSubtle = Color(0x0DFFFFFF);

  // ─── Nav ───
  static const Color navActive = Color(0xFFF9FAFB);
  static const Color navInactive = Color(0xFF6B7280);

  // ─── Gradients (subtle, not screaming) ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B7CF6), Color(0xFF6D5DD3)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF67E8F9), Color(0xFF8B7CF6)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const LinearGradient pointsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FAFB), Color(0xFF9CA3AF)],
  );

  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF09090B), Color(0xFF131320), Color(0xFF09090B)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Raffle Colors (calmer) ───
  static const Color raffleDaily = Color(0xFF34D399);
  static const Color raffleWeekly = Color(0xFF67E8F9);
  static const Color raffleMonthly = Color(0xFFA5A0F8);

  // ─── Shadows (subtle, not Vegas) ───
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: -4),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
  ];
}
