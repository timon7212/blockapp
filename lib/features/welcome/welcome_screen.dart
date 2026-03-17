import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/primary_button.dart';

/// Premium onboarding-style welcome screen.
///
/// Shown BEFORE auth to sell the value proposition.
/// Flow: Welcome → Auth → Onboarding (new users) → Main
///
/// 3 animated pages:
///   1. Hero — "Your Screen Time Has Value"
///   2. How It Works — 3 simple steps
///   3. CTA — Trust signals + "Get Started"
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _totalPages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.heavyImpact();
      widget.onGetStarted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Skip ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_page < _totalPages - 1)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onGetStarted();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Skip',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── Pages ──
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    _PageHero(),
                    _PageHowItWorks(),
                    _PageCTA(),
                  ],
                ),
              ),

              // ── Dots ──
              _buildDots(),
              const SizedBox(height: 28),

              // ── Buttons ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: _page == _totalPages - 1
                          ? "Get Started — It's Free"
                          : 'Continue',
                      icon: _page == _totalPages - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      gradient: _page == _totalPages - 1
                          ? AppColors.successGradient
                          : AppColors.primaryGradient,
                      height: 56,
                      onPressed: _next,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onSignIn();
                      },
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: bottomPadding + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGE 1: HERO — "Your Screen Time Has Value"
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PageHero extends StatelessWidget {
  const _PageHero();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Floating icon with glow ──
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Icon container
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 40,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -8,
                    end: 8,
                    duration: 2500.ms,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
          const SizedBox(height: 48),

          // ── Title ──
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF9FAFB), Color(0xFFA5A0F8)],
            ).createShader(bounds),
            child: Text(
              'Your Screen Time\nHas Value',
              style: AppTypography.displayLarge.copyWith(
                fontSize: 34,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.15, end: 0, duration: 600.ms),

          const SizedBox(height: 16),

          // ── Subtitle ──
          Text(
            'Every minute you spend scrolling\ncan earn you real rewards',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 40),

          // ── Quick value props ──
          _QuickProp(
            icon: Icons.phone_android_rounded,
            text: 'Use social media as usual',
            delay: 400,
          ),
          const SizedBox(height: 10),
          _QuickProp(
            icon: Icons.bolt_rounded,
            text: 'Earn points automatically',
            delay: 550,
          ),
          const SizedBox(height: 10),
          _QuickProp(
            icon: Icons.card_giftcard_rounded,
            text: 'Redeem for gift cards & cash',
            delay: 700,
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGE 2: HOW IT WORKS — 3 Steps
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PageHowItWorks extends StatelessWidget {
  const _PageHowItWorks();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'How It Works',
            style: AppTypography.displaySmall.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          Text(
            'Three simple steps to start earning',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 36),

          // Step 1
          _StepTile(
            step: '1',
            icon: Icons.phone_android_rounded,
            title: 'Browse Normally',
            subtitle: 'Use Instagram, TikTok, X — just like always',
            color: AppColors.primary,
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: -0.05, end: 0),

          // Connector
          _Connector(
            fromColor: AppColors.primary,
            toColor: AppColors.accent,
          ),

          // Step 2
          _StepTile(
            step: '2',
            icon: Icons.bolt_rounded,
            title: 'Earn Points',
            subtitle: 'Up to 2,000 pts per 20-min session, automatically',
            color: AppColors.accent,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.05, end: 0),

          // Connector
          _Connector(
            fromColor: AppColors.accent,
            toColor: AppColors.success,
          ),

          // Step 3
          _StepTile(
            step: '3',
            icon: Icons.card_giftcard_rounded,
            title: 'Get Rewards',
            subtitle: 'Redeem for gift cards, cash out, or donate',
            color: AppColors.success,
          ).animate().fadeIn(duration: 400.ms, delay: 450.ms).slideX(begin: -0.05, end: 0),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGE 3: CTA — Trust signals + Get Started
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PageCTA extends StatelessWidget {
  const _PageCTA();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Celebratory icon ──
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: -8,
                ),
              ],
            ),
            child:
                const Icon(Icons.rocket_launch_rounded, size: 40, color: Colors.white),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 36),

          Text(
            'Ready to Start\nEarning?',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 32,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

          const SizedBox(height: 14),

          Text(
            'Join thousands turning their\nscreen time into real rewards',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 36),

          // ── Stats ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(value: '50K+', label: 'active users'),
              _StatDivider(),
              _StatPill(value: '4.8★', label: 'rating'),
              _StatDivider(),
              _StatPill(value: '100%', label: 'free'),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

          const SizedBox(height: 32),

          // ── Trust badges ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TrustBadge(
                  icon: Icons.verified_user_rounded,
                  label: 'Secure',
                  color: AppColors.success,
                ),
                _TrustBadge(
                  icon: Icons.credit_card_off_rounded,
                  label: 'No card',
                  color: AppColors.accent,
                ),
                _TrustBadge(
                  icon: Icons.timer_rounded,
                  label: '2 min setup',
                  color: AppColors.primary,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _QuickProp extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _QuickProp({
    required this.icon,
    required this.text,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, color: AppColors.primary, size: 18)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _StepTile({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        AppTypography.headlineSmall.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.4), size: 24),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final Color fromColor;
  final Color toColor;

  const _Connector({required this.fromColor, required this.toColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 24,
      margin: const EdgeInsets.only(left: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fromColor.withValues(alpha: 0.4),
            toColor.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;

  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border,
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
