import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _page = 0;

  int? _dailyMinutes;
  final Set<String> _selectedInterests = {};
  bool _claimDemoCompleted = false;
  bool _earningsAnimated = false;

  int _animatedEarnings = 0;
  Timer? _earningsTimer;

  int _animatedAccPoints = 0;
  Timer? _accTimer;

  bool _adLoading = false;
  bool _adDone = false;
  double _adProgress = 0;
  Timer? _adTimer;

  late final AnimationController _progressAnimController;
  late final Animation<double> _progressAnim;
  bool _accAnimStarted = false;

  late final ConfettiController _claimConfetti;
  late final ConfettiController _readyConfetti;

  @override
  void initState() {
    super.initState();
    _claimConfetti = ConfettiController(duration: const Duration(seconds: 2));
    _readyConfetti = ConfettiController(duration: const Duration(seconds: 3));

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0.7).animate(
      CurvedAnimation(parent: _progressAnimController, curve: Curves.easeOut),
    );
    _progressAnimController.addListener(() {
      if (mounted) {
        setState(() {
          _animatedAccPoints = (_progressAnim.value / 0.7 * 1400).round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _earningsTimer?.cancel();
    _accTimer?.cancel();
    _adTimer?.cancel();
    _progressAnimController.dispose();
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
    if (_page < 10) _goTo(_page + 1);
  }

  void _complete() {
    HapticFeedback.heavyImpact();
    ref.read(onboardingCompleteProvider.notifier).state = true;
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

  void _startAccumulationAnim() {
    if (_accAnimStarted) return;
    _accAnimStarted = true;
    _progressAnimController.forward();
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
        _adProgress = (_adProgress + 1 / 60).clamp(0.0, 1.0);
      });
      if (_adProgress >= 1.0) {
        t.cancel();
        setState(() {
          _adLoading = false;
          _adDone = true;
          _claimDemoCompleted = true;
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
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _page = i),
                      children: [
                        _buildWelcome(),
                        _buildQuestion1(),
                        _buildEarningsDemo(),
                        _buildAccumulationDemo(),
                        _buildClaimDemo(),
                        _buildStreaks(),
                        _buildQuestion2(),
                        _buildSpinWheel(),
                        _buildReferral(),
                        _buildNotifications(),
                        _buildReady(),
                      ],
                    ),
                  ),
                  _buildDots(),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final showSkip = _page > 0 && _page < 10;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(11, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _page == i ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _page == i ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
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

  Widget _buildWelcome() {
    return _wrapStep(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1.08, 1.08),
              duration: 1500.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 48),
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
          'Turn your screen time into real rewards',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
      ],
      button: PrimaryButton(
        label: "Let's Go",
        icon: Icons.arrow_forward_rounded,
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

  Widget _buildQuestion1() {
    final options = [
      ('Less than 30 min', Icons.timer_outlined, 20),
      ('30 min – 1 hour', Icons.timelapse_rounded, 45),
      ('1–2 hours', Icons.access_time_filled_rounded, 90),
      ('More than 2 hours', Icons.all_inclusive_rounded, 150),
    ];

    return _wrapStep(
      children: [
        Text(
          'How much time do you\nspend on social media daily?',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        ...options.map((o) {
          final selected = _dailyMinutes == o.$3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              borderColor: selected ? AppColors.primary : null,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _dailyMinutes = o.$3);
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(o.$2, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      o.$1,
                      style: AppTypography.headlineSmall.copyWith(
                        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (100 * options.indexOf(o)).ms);
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

  Widget _buildEarningsDemo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page == 2) _startEarningsAnimation();
    });

    return _wrapStep(
      children: [
        const SizedBox(height: 24),
        Text(
          'Based on your usage, you could earn',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Text(
          Formatters.number(_animatedEarnings),
          style: AppTypography.number.copyWith(fontSize: 56),
        ),
        Text(
          'pts / day',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: 24),
        Text(
          "That's ~${Formatters.number(_monthlyPts)} points per month",
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        if (_monthlyPts >= 5000) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Enough for Amazon \$5 Gift Card',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
      button: PrimaryButton(
        label: "That's Amazing",
        icon: Icons.auto_awesome_rounded,
        gradient: AppColors.successGradient,
        onPressed: _next,
      ),
    );
  }

  Widget _buildAccumulationDemo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page == 3) _startAccumulationAnim();
    });

    return _wrapStep(
      children: [
        const SizedBox(height: 16),
        Text(
          'How It Works',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'While you use social apps, points\naccumulate automatically',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (context, _) {
            return SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _progressAnim.value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progressAnim.value * 100).round()}%',
                        style: AppTypography.number.copyWith(fontSize: 28),
                      ),
                      Text(
                        '${Formatters.number(_animatedAccPoints)} pts',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Up to 2,000 points per session.\nThen claim them!',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      ],
      button: PrimaryButton(
        label: 'Got it',
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

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
        const SizedBox(height: 24),
        Text(
          'Claim Your Points',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Watch a quick ad to claim your points',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 48),
        if (!_adLoading && !_adDone) ...[
          PrimaryButton(
            label: 'Claim 1,400 pts',
            icon: Icons.play_circle_outline_rounded,
            gradient: AppColors.successGradient,
            onPressed: _startAdDemo,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
        ],
        if (_adLoading) ...[
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Loading ad…',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _adProgress,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_adDone) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                const SizedBox(height: 12),
                Text(
                  '+1,400 points!',
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.success),
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
      button: _claimDemoCompleted
          ? PrimaryButton(
              label: 'Continue',
              gradient: AppColors.primaryGradient,
              onPressed: _next,
            )
          : null,
    );
  }

  Widget _buildStreaks() {
    final streaks = [
      ('Day 1–2', '1.0x', AppColors.textTertiary),
      ('Day 3–6', '1.1x', AppColors.textSecondary),
      ('Day 7–13', '1.2x', AppColors.textSecondary),
      ('Day 14–29', '1.3x', AppColors.primaryLight),
      ('Day 30+', '1.5x', AppColors.accent),
    ];

    return _wrapStep(
      children: [
        Text(
          'Daily Streaks = More Rewards',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        ...streaks.asMap().entries.map((e) {
          final s = e.value;
          final isHighlight = e.key == streaks.length - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              borderColor: isHighlight ? AppColors.accent.withValues(alpha: 0.4) : null,
              color: isHighlight ? AppColors.accentMuted : null,
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: s.$3,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.$1, style: AppTypography.headlineSmall),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: s.$3.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.$2,
                      style: AppTypography.labelMedium.copyWith(
                        color: s.$3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (80 * e.key).ms).slideX(begin: 0.1, end: 0);
        }),
        const SizedBox(height: 20),
        Text(
          'Claim every day to build your streak.\nHigher streak = bigger multiplier on every claim.',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '1,400 pts × 1.5x = 2,100 pts',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.primaryLight),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
      ],
      button: PrimaryButton(
        label: 'Love it',
        icon: Icons.favorite_rounded,
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

  Widget _buildQuestion2() {
    final interests = [
      ('Games', Icons.sports_esports_rounded, AppColors.success),
      ('Surveys', Icons.poll_rounded, AppColors.accent),
      ('Gift Cards', Icons.card_giftcard_rounded, AppColors.primary),
      ('Cash Out', Icons.payments_rounded, AppColors.success),
      ('Raffles', Icons.emoji_events_rounded, AppColors.accent),
      ('Referrals', Icons.people_rounded, AppColors.primary),
    ];

    return _wrapStep(
      children: [
        Text(
          'What interests you most?',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: interests.map((item) {
            final selected = _selectedInterests.contains(item.$1);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (selected) {
                    _selectedInterests.remove(item.$1);
                  } else {
                    _selectedInterests.add(item.$1);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? item.$3.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? item.$3 : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.$2, color: selected ? item.$3 : AppColors.textTertiary, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            item.$1,
                            style: AppTypography.labelMedium.copyWith(
                              color: selected ? item.$3 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.check_circle_rounded, color: item.$3, size: 16),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
      button: PrimaryButton(
        label: 'Continue',
        gradient: AppColors.primaryGradient,
        onPressed: _next,
        enabled: _selectedInterests.isNotEmpty,
      ),
    );
  }

  Widget _buildSpinWheel() {
    final tiers = [
      ('Common', AppColors.textSecondary),
      ('Rare', AppColors.primary),
      ('Epic', AppColors.accent),
      ('Legendary', AppColors.success),
    ];

    return _wrapStep(
      children: [
        Text(
          '4 Free Spins Every Day',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.accent.withValues(alpha: 0.1),
                AppColors.surface,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 3),
          ),
          child: Center(
            child: Text(
              'SPIN',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primaryLight,
                letterSpacing: 2,
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .rotate(duration: 8000.ms, begin: 0, end: 0.05)
            .then()
            .rotate(duration: 8000.ms, begin: 0.05, end: 0),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: tiers.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.$2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.$2.withValues(alpha: 0.3)),
              ),
              child: Text(
                t.$1,
                style: AppTypography.labelMedium.copyWith(color: t.$2, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Spin the wheel after watching a short ad.\nWin up to 5,000 points!',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
      button: PrimaryButton(
        label: "Can't Wait",
        icon: Icons.auto_awesome_rounded,
        gradient: AppColors.accentGradient,
        onPressed: _next,
      ),
    );
  }

  Widget _buildReferral() {
    return _wrapStep(
      children: [
        Text(
          'Invite Friends,\nEarn Together',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 36),
        _buildRefTreeRow(
          label: 'You',
          badge: null,
          count: 1,
          color: AppColors.primary,
        ).animate().fadeIn(duration: 300.ms),
        _buildConnectorLines(1, 3),
        _buildRefTreeRow(
          label: 'Level 1',
          badge: '10%',
          count: 3,
          color: AppColors.accent,
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
        _buildConnectorLines(3, 5),
        _buildRefTreeRow(
          label: 'Level 2',
          badge: '5%',
          count: 5,
          color: AppColors.success,
        ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
        const SizedBox(height: 28),
        Text(
          'You earn a percentage of what your network earns. The more active friends, the more you make.',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
      ],
      button: PrimaryButton(
        label: 'Awesome',
        icon: Icons.thumb_up_rounded,
        gradient: AppColors.primaryGradient,
        onPressed: _next,
      ),
    );
  }

  Widget _buildRefTreeRow({
    required String label,
    required String? badge,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
          ],
          ...List.generate(count, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(Icons.person_rounded, color: color, size: 20),
              ),
            );
          }),
          if (badge == null) ...[
            const SizedBox(width: 12),
            Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectorLines(int fromCount, int toCount) {
    return SizedBox(
      height: 24,
      child: CustomPaint(
        size: const Size(200, 24),
        painter: _ConnectorPainter(
          color: AppColors.border,
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    return _wrapStep(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accentMuted,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.notifications_active_rounded, size: 44, color: AppColors.accent),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 32),
        Text(
          'Stay in the Loop',
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 12),
        Text(
          'Get notified when your points are ready to claim, when you win a raffle, or when new offers arrive.',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        const SizedBox(height: 40),
        PrimaryButton(
          label: 'Enable Notifications',
          icon: Icons.notifications_rounded,
          gradient: AppColors.accentGradient,
          onPressed: () {
            HapticFeedback.mediumImpact();
            _next();
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _next();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Maybe Later',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page == 10) _readyConfetti.play();
    });

    final dailyDisplay = _dailyPts > 0 ? _dailyPts : 2000;

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
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successMuted,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.check_rounded, size: 48, color: AppColors.success),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 32),
        Text(
          "You're All Set!",
          style: AppTypography.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'Your daily earning potential:',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        const SizedBox(height: 20),
        Text(
          Formatters.number(dailyDisplay),
          style: AppTypography.number.copyWith(fontSize: 52),
        ).animate().fadeIn(duration: 500.ms, delay: 400.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
            ),
        Text(
          'pts / day',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textTertiary),
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
      ],
      button: PrimaryButton(
        label: 'Start Earning',
        icon: Icons.rocket_launch_rounded,
        gradient: AppColors.successGradient,
        onPressed: _complete,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final Color color;

  _ConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midX = size.width / 2;
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), paint);
    canvas.drawLine(Offset(midX - 30, size.height), Offset(midX + 30, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
