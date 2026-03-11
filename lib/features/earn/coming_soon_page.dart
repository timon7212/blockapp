import 'package:flutter/material.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';

class ComingSoonPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const ComingSoonPage({super.key, required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: AppTypography.headlineLarge),
                ],
              ),
            ),
            const Spacer(),
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.displaySmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subtitle, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Text('Coming Soon', style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
