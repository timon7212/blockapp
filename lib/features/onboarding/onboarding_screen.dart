import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/economy_constants.dart';
import '../../data/dto/user_dto.dart';
import '../../data/repositories/user_repository.dart';

/// Streamlined 6-step onboarding:
///
/// 1. Welcome — Value prop in <10 seconds
/// 2. How much social media? — Personalization hook
/// 3. Earnings reveal + How it works — Dopamine spike
/// 4. Claim demo — Instant gratification (aha-moment!)
/// 5. Streaks & multipliers — Loss aversion primer
/// 6. You're ready! — Confetti + welcome bonus
///
/// Removed: interests question, spin wheel explanation, referral deep-dive,
/// separate notifications step (all discoverable in-app)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _page = 0;
  static const _totalPages = 6;

  int? _dailyMinutes;
  bool _earningsAnimated = false;
  int _animatedEarnings = 0;
  Timer? _earningsTimer;

  // Claim demo state
  bool _adLoading = false;
  bool _adDone = false;
  double _adProgress = 0;
  Timer? _adTimer;

  late final ConfettiController _claimConfetti;
  late final ConfettiController _readyConfetti;

  // Welcome bonus
  static const int _welcomeBonus = 500;
  // ignore: unused_field
  bool _bonusClaimed = false;

  @override
  void initState() {
    super.initState();
    _claimConfetti = ConfettiController(duration: const Duration(seconds: 2));
    _readyConfetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _earningsTimer?.cancel();
    _adTimer?.cancel();
    _claimConfetti.dispose();
    _readyConfetti.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    HapticFeedback.mediumImpact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_page < _totalPages - 1) _goTo(_page + 1);
  }

  void _complete() async {
    HapticFeedback.heavyImpact();
    _bonusClaimed = true;

    // Call API to complete onboarding
    try {
      final userRepo = UserRepository();
      await userRepo.completeOnboarding(OnboardingRequest(
        trackedAppIds: ['instagram', 'tiktok', 'twitter', 'snapchat'],
        goal: _dailyMinutes != null
            ? 'reduce_${_dailyMinutes}min'
            : 'reduce_general',
      ));
    } catch (_) {
      // Continue even if API call fails
    }

    // Refresh profile to get onboardingComplete = true
    ref.read(authNotifierProvider.notifier).refreshProfile();
  }

  int get _dailyPts {
    final capped = (_dailyMinutes ?? 20).clamp(0, 20);
    return capped * 100;
  }

  int get _monthlyPts => _dailyPts * 30;

  void _startEarningsAnimation() {
    if (_earningsAnimated) return;
    _earningsAnimated = true;
    _animatedEarnings = 0;
    final target = _dailyPts;
    const steps = 60;
    final increment = (target / steps).ceil();
    _earningsTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _animatedEarnings = (_animatedEarnings + increment).clamp(0, target);
      });
      if (_animatedEarnings >= target) t.cancel();
    });
  }

  void _startAdDemo() {
    setState(() {
      _adLoading = true;
      _adProgress = 0;
    });
    _adTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _adProgress = (_adProgress + 1 / 40).clamp(0.0, 1.0);
      });
      if (_adProgress >= 1.0) {
        t.cancel();
        setState(() {
          _adLoading = false;
          _adDone = true;
        });
        _claimConfetti.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              // Progress bar instead of dots (more engaging)
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildWelcome(),           // Step 1
                    _buildQuestion(),          // Step 2
                    _buildEarningsReveal(),    // Step 3
                    _buildClaimDemo(),         // Step 4
                    _buildStreaksPreview(),     // Step 5
                    _buildReady(),             // Step 6
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final showSkip = _page > 0 && _page < _totalPages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          if (_page > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _goTo(_page - 1);
              },
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textTertiary, size: 24),
            )
          else
            const SizedBox(width: 24),
          const Spacer(),
          if (showSkip)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _complete();
              },
              child: Text(
                'Skip',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_page + 1) / _totalPages;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_page + 1}/$_totalPages',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapStep({required List<Widget> children, Widget? button}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  ...children,
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (button != null) ...[
            button,
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 1: Welcome — Hook in <10 seconds
  // ──────────────────────────────────────────────
  Widget _buildWelcome() {
    return _wrapStep(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child:
              const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1.08, 1.08),
              duration: 1500.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 40),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ).createShader(bounds),
          child: Text(
            'DoomScroll',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 42,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          'Turn your screen time\ninto real rewards',
          style: AppTypography.bodyLarge.copyWith(fontSize: 18, height: 1.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: 32),
        // Quick value props
        _ValuePropRow(
          icon: Icons.phone_android_rounded,
          text: 'Use social media as usual',
          delay: 400,
        ),
        const SizedBox(height: 12),
        _ValuePropRow(
          icon: Icons.bolt_rounded,
          text: 'Earn points automatically',
          delay: 550,
        ),
        const SizedBox(height: 12),
        _ValuePropRow(
          icon: Icons.card_giftcard_rounded,
          text: 'Redeem for gift cards & cash',
          delay: 700,
        ),
      ],
      button: PrimaryButton(
        label: "Let's Go",
        icon: Icons.arrow_forward_rounded,
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 2: How much social media?
  // ──────────────────────────────────────────────
  Widget _buildQuestion() {
    final options = [
      ('Less than 30 min', Icons.timer_outlined, 20),
      ('30 min – 1 hour', Icons.timelapse_rounded, 45),
      ('1–2 hours', Icons.access_time_filled_rounded, 90),
      ('2+ hours', Icons.all_inclusive_rounded, 150),
    ];

    return _wrapStep(
      children: [
        Text(
          'How much time do you\nspend on social media?',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Instagram, TikTok, X, Snapchat...',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 28),
        ...options.asMap().entries.map((entry) {
          final o = entry.value;
          final selected = _dailyMinutes == o.$3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              borderColor: selected ? AppColors.primary : null,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _dailyMinutes = o.$3);
              },
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(o.$2,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      o.$1,
                      style: AppTypography.headlineSmall.copyWith(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ).animate().fadeIn(
              duration: 300.ms, delay: (100 * entry.key).ms);
        }),
      ],
      button: PrimaryButton(
        label: 'Continue',
        gradient: AppColors.primaryGradient,
        onPressed: _next,
        enabled: _dailyMinutes != null,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 3: Earnings reveal + How it works
  // ──────────────────────────────────────────────
  Widget _buildEarningsReveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page == 2) _startEarningsAnimation();
    });

    return _wrapStep(
      children: [
        const SizedBox(height: 16),
        Text(
          'Your earning potential',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        Text(
          Formatters.number(_animatedEarnings),
          style: AppTypography.number.copyWith(fontSize: 56),
        ),
        Text(
          'pts / session',
          style: AppTypography.headlineSmall
              .copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: 8),
        Text(
          'Up to ${EconomyConstants.maxSessionsPerDay} sessions per day · ~${Formatters.number(_monthlyPts * 4)} pts/month',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        const SizedBox(height: 32),
        // Quick steps
        _StepIndicator(
          number: '1',
          title: 'Browse social media',
          subtitle: 'Instagram, TikTok, X, Snapchat — as usual',
          icon: Icons.phone_android_rounded,
          color: AppColors.primary,
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 12),
        _StepIndicator(
          number: '2',
          title: 'Points accumulate',
          subtitle: 'Up to 2,000 pts per 20-min session',
          icon: Icons.bolt_rounded,
          color: AppColors.accent,
        ).animate().fadeIn(duration: 400.ms, delay: 550.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 12),
        _StepIndicator(
          number: '3',
          title: 'Watch an ad & claim',
          subtitle: 'One short ad unlocks your earned points',
          icon: Icons.play_circle_rounded,
          color: AppColors.success,
        ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -0.1, end: 0),
      ],
      button: PrimaryButton(
        label: "Let's Try It!",
        icon: Icons.auto_awesome_rounded,
        gradient: AppColors.successGradient,
        onPressed: _next,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 4: Claim demo — THE AHA MOMENT
  // ──────────────────────────────────────────────
  Widget _buildClaimDemo() {
    return _wrapStep(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _claimConfetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            maxBlastForce: 20,
            minBlastForce: 5,
            numberOfParticles: 25,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.success,
              AppColors.primaryLight,
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Try It Now!',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          'See how easy it is to claim',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 36),
        if (!_adLoading && !_adDone) ...[
          // Simulated accumulation card
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.success.withValues(alpha: 0.3),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Ready to Claim',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '1,400',
                  style: AppTypography.number.copyWith(fontSize: 44),
                ),
                Text('points accumulated',
                    style: AppTypography.bodySmall),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .scaleXY(begin: 0.95, end: 1.0),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '▶ Watch Ad & Claim 1,400 pts',
            gradient: AppColors.successGradient,
            onPressed: _startAdDemo,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                  duration: 2000.ms,
                  color: Colors.white.withValues(alpha: 0.1)),
        ],
        if (_adLoading) ...[
          SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.play_circle_rounded,
                    color: AppColors.primary, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Watching ad...',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _adProgress,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_adProgress * 100).round()}%',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
        if (_adDone) ...[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.successMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 56),
                const SizedBox(height: 16),
                Text(
                  '+1,400 points!',
                  style: AppTypography.headlineLarge
                      .copyWith(color: AppColors.success),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added to your balance',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.success),
                ),
              ],
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms),
        ],
      ],
      button: _adDone
          ? PrimaryButton(
              label: 'Continue',
              gradient: AppColors.primaryGradient,
              onPressed: _next,
            )
          : null,
    );
  }

  // ──────────────────────────────────────────────
  // STEP 5: Streaks + Multipliers + Bonus features
  // ──────────────────────────────────────────────
  Widget _buildStreaksPreview() {
    return _wrapStep(
      children: [
        Text(
          'Earn Even More',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),
        // Streak multipliers
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 8),
                  Text('Daily Streak Multiplier',
                      style: AppTypography.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              _StreakRow('Days 1-2', '1.0x', false),
              _StreakRow('Days 3-6', '1.1x', false),
              _StreakRow('Days 7-13', '1.2x', false),
              _StreakRow('Days 14-29', '1.3x', false),
              _StreakRow('Days 30+', '1.5x', true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '2,000 pts × 1.5x = 3,000 pts per session!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 16),
        // More ways to earn
        Row(
          children: [
            Expanded(
              child: _BonusFeatureCard(
                icon: Icons.casino_rounded,
                label: 'Spin & Win',
                subtitle: '4 free spins/day',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BonusFeatureCard(
                icon: Icons.emoji_events_rounded,
                label: 'Raffles',
                subtitle: 'Win big prizes',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BonusFeatureCard(
                icon: Icons.people_rounded,
                label: 'Referrals',
                subtitle: 'Earn 10%',
                color: AppColors.primary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
      ],
      button: PrimaryButton(
        label: 'Almost Done',
        icon: Icons.arrow_forward_rounded,
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STEP 6: Ready! — Welcome bonus + enable notifications
  // ──────────────────────────────────────────────
  Widget _buildReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page == _totalPages - 1) _readyConfetti.play();
    });

    return _wrapStep(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _readyConfetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            maxBlastForce: 30,
            minBlastForce: 10,
            numberOfParticles: 40,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.success,
              AppColors.primaryLight,
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successMuted,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.celebration_rounded,
              size: 48, color: AppColors.success),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 28),
        Text(
          "You're All Set!",
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: 16),
        // Welcome bonus card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard_rounded,
                    color: AppColors.primaryLight, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Bonus',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                    Text(
                      '+$_welcomeBonus points',
                      style: AppTypography.headlineMedium
                          .copyWith(color: AppColors.primaryLight),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 24),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 400.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 20),
        // Tips
        Text(
          'Your first goal:',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderColor: AppColors.accent.withValues(alpha: 0.2),
          child: Row(
            children: [
              Icon(Icons.phone_android_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Go browse social media for 20 min,\nthen come back to claim your points!',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 750.ms),
      ],
      button: PrimaryButton(
        label: 'Start Earning! 🚀',
        gradient: AppColors.successGradient,
        onPressed: _complete,
      ),
    );
  }
}

// ─── Helper Widgets ───

class _ValuePropRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _ValuePropRow({
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
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Icon(icon, color: AppColors.primary, size: 18)),
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
    ).animate().fadeIn(duration: 300.ms, delay: delay.ms).slideX(begin: -0.1, end: 0);
  }
}

class _StepIndicator extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StepIndicator({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
                    style: AppTypography.headlineSmall
                        .copyWith(fontSize: 14)),
                Text(subtitle,
                    style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.5), size: 22),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _StreakRow extends StatelessWidget {
  final String days;
  final String multiplier;
  final bool isHighlight;

  const _StreakRow(this.days, this.multiplier, this.isHighlight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: isHighlight ? AppColors.accent : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              days,
              style: AppTypography.bodySmall.copyWith(
                color: isHighlight
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              multiplier,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isHighlight
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BonusFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _BonusFeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: color, size: 20)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary, fontSize: 12)),
          Text(subtitle,
              style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

