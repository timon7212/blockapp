import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFa78bfa), Color(0xFFc4b5fd)],
                          ).createShader(bounds),
                          child: Text(
                            'ManyBoost',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                        const SizedBox(height: 8),
                        Text('v2.1.0', style: AppTypography.bodyMedium)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 100.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Turn screen time into real rewards',
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                        const SizedBox(height: 36),
                        SurfaceCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _linkTile(
                                icon: Icons.description_outlined,
                                label: 'Terms of Service',
                                url: 'https://example.com/terms',
                              ),
                              Divider(height: 1, color: AppColors.border, indent: 52),
                              _linkTile(
                                icon: Icons.privacy_tip_outlined,
                                label: 'Privacy Policy',
                                url: 'https://example.com/privacy',
                              ),
                              Divider(height: 1, color: AppColors.border, indent: 52),
                              _linkTile(
                                icon: Icons.code_rounded,
                                label: 'Open Source Licenses',
                                url: 'https://example.com/licenses',
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_rounded, size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 6),
                            Text('Made with care', style: AppTypography.caption),
                          ],
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('About', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _linkTile({required IconData icon, required String label, required String url}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary)),
            ),
            const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
