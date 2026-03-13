import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const _faq = [
    (
      question: 'How does earning work?',
      answer:
          'Use social media apps as you normally do. Every minute of screen time earns you 100 points, up to 2,000 per session. When your points are ready, open DoomScroll and watch a short video to claim them to your balance.',
    ),
    (
      question: 'What are streaks?',
      answer:
          'Claim your points daily to build a streak. The longer your streak, the higher your claim multiplier. A 7-day streak gives you 1.2x, and 30+ days gives you 1.5x bonus on every claim.',
    ),
    (
      question: 'How do I cash out?',
      answer:
          'Once you reach 10,000 points, you can withdraw via PayPal or bank card. Go to Store > Cash Out tab to start the process.',
    ),
    (
      question: 'How does the referral program work?',
      answer:
          'Share your unique code with friends. You earn 10% of what your Level 1 referrals earn, and 5% from Level 2. Watch an ad on each level to collect your pending earnings.',
    ),
    (
      question: 'How are raffles drawn?',
      answer:
          'Raffles are drawn at the end of each period (daily/weekly/monthly). Winners are selected randomly from all participants who completed the required entry tasks.',
    ),
    (
      question: "My points didn't credit",
      answer:
          'Points from offers can take up to 24 hours to credit. If after 24 hours they still haven\'t appeared, use the Report feature on the offer detail page.',
    ),
  ];

  final Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...List.generate(_faq.length, (i) {
                      final item = _faq[i];
                      final isExpanded = _expanded[i] ?? false;
                      return Padding(
                        padding: EdgeInsets.only(bottom: i < _faq.length - 1 ? 10 : 0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _expanded[i] = !isExpanded);
                          },
                          child: SurfaceCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.question,
                                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 22),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox(width: double.infinity),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Text(
                                      item.answer,
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                                    ),
                                  ),
                                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 200),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * i));
                    }),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        launchUrl(Uri.parse('mailto:support@doomscroll.app'));
                      },
                      child: SurfaceCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Contact Us',
                              style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * _faq.length)),
                  ],
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
          Text('Help & Support', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }
}
