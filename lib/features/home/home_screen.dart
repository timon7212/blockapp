import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/glass_card.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/wallet_model.dart';
import '../../models/offerwall_item_model.dart';
import '../../services/ad_service.dart';
import '../spin_wheel/spin_wheel_screen.dart';
import '../../design_system/utils/app_page_route.dart';
import '../earn/games_screen.dart';
import '../earn/tasks_screen.dart';
import '../earn/surveys_screen.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
            if (context.mounted) {
              AppToast.show(context, message: 'Refreshed!', type: ToastType.success);
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(child: _TopBar()),
              if (_loading)
                const SliverToBoxAdapter(child: _HomeShimmer())
              else ...[
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(child: _StreakBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const SliverToBoxAdapter(child: _AccumulationWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const SliverToBoxAdapter(child: _SpinWheelPreview()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverToBoxAdapter(child: _EarnMoreSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.number(wallet.totalPoints),
                  style: AppTypography.number.copyWith(fontSize: 32),
                ),
              ],
            ),
          ),
          if (wallet.todayEarned > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '+${Formatters.number(wallet.todayEarned)} today',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

class _AccumulationWidget extends ConsumerWidget {
  const _AccumulationWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(screenTimeProvider);
    final hasPending = st.accumulatedPoints > 0;
    final progress = st.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: EdgeInsets.zero,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: st.isCapped
              ? [
                  AppColors.points.withValues(alpha: 0.08),
                  AppColors.pointsDim.withValues(alpha: 0.04),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.07),
                  AppColors.accent.withValues(alpha: 0.03),
                ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: st.isCapped ? AppColors.points : AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    st.isCapped ? 'Ready to Claim' : 'Accumulating...',
                    style: AppTypography.labelMedium.copyWith(
                      color: st.isCapped ? AppColors.points : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${st.accumulatedMinutes}/${EconomyConstants.maxAccumulationMinutes} min',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: progress,
              animation: true,
              animationDuration: 800,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: AppColors.surfaceLight,
              linearGradient: st.isCapped
                  ? const LinearGradient(colors: [AppColors.points, AppColors.pointsDim])
                  : const LinearGradient(colors: [AppColors.accent, AppColors.primary]),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.number(st.accumulatedPoints),
                    style: AppTypography.number.copyWith(
                      fontSize: 32,
                      color: st.isCapped ? AppColors.points : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of ${Formatters.number(EconomyConstants.maxPendingPoints)}',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('points accumulated', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 24),
            if (hasPending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _ClaimButton(points: st.accumulatedPoints, isFull: st.isCapped),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text('Use social media to start earning', style: AppTypography.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0);
  }
}

class _ClaimButton extends ConsumerWidget {
  final int points;
  final bool isFull;
  const _ClaimButton({required this.points, required this.isFull});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final multipliedPts = (points * streak.multiplier).round();
    final label = isFull
        ? 'Claim ${Formatters.number(multipliedPts)} pts (${streak.multiplierLabel})'
        : 'Claim ${Formatters.number(multipliedPts)} pts (${streak.multiplierLabel})';

    return GestureDetector(
      onTap: () async {
        HapticFeedback.heavyImpact();
        AppToast.show(context, message: 'Watching ad to claim points...', type: ToastType.info);
        await AdService.showRewardedAd(
          onRewarded: () {
            final basePts = ref.read(screenTimeProvider.notifier).claim();
            final streak = ref.read(streakProvider);
            final multiplied = (basePts * streak.multiplier).round();
            ref.read(streakProvider.notifier).recordClaim();
            ref.read(walletProvider.notifier).addPoints(multiplied, 'Screen time claim (${streak.multiplierLabel})', TransactionType.screenTimeClaim);
            HapticFeedback.heavyImpact();
            if (context.mounted) {
              AppToast.show(context, message: '+$multiplied points claimed! (${streak.multiplierLabel})', type: ToastType.success);
            }
            final newStreak = ref.read(streakProvider);
            if (newStreak.currentStreak == 3 || newStreak.currentStreak == 7 || newStreak.currentStreak == 14 || newStreak.currentStreak == 30) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (context.mounted) {
                  AppToast.show(context, message: '${newStreak.currentStreak}-day streak! ${newStreak.multiplierLabel} multiplier unlocked!', type: ToastType.success);
                }
              });
            }
          },
          onFailed: () {
            if (context.mounted) AppToast.show(context, message: 'Ad failed to load. Try again.', type: ToastType.error);
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isFull ? AppColors.pointsGradient : AppColors.successGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled_rounded, color: AppColors.textInverse, size: 22),
            const SizedBox(width: 10),
            Text(label, style: AppTypography.button.copyWith(color: AppColors.textInverse, fontSize: 16)),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
      duration: 2200.ms,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _SpinWheelPreview extends ConsumerWidget {
  const _SpinWheelPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spinsLeft = ref.watch(spinsRemainingProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        borderRadius: 20,
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(AppPageRoute(page: const SpinWheelScreen()));
        },
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Center(child: Icon(Icons.casino_rounded, color: AppColors.accent, size: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spin & Win', style: AppTypography.headlineMedium),
                  const SizedBox(height: 3),
                  Text('$spinsLeft spins available today', style: AppTypography.bodySmall.copyWith(color: AppColors.accent)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 24),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: 0.05, end: 0);
  }
}

class _EarnMoreSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOffers = ref.watch(offerwallProvider);

    final gameOffers = allOffers.where((o) => o.type == OfferType.reachLevel || o.type == OfferType.installApp).toList();
    final taskOffers = allOffers.where((o) => o.type == OfferType.register || o.type == OfferType.subscribe).toList();
    final surveyOffers = allOffers.where((o) => o.type == OfferType.survey).toList();

    final maxGames = gameOffers.isEmpty ? 0 : gameOffers.map((o) => o.rewardPoints).reduce((a, b) => a > b ? a : b);
    final maxTasks = taskOffers.isEmpty ? 0 : taskOffers.map((o) => o.rewardPoints).reduce((a, b) => a > b ? a : b);
    final maxSurveys = surveyOffers.isEmpty ? 0 : surveyOffers.map((o) => o.rewardPoints).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Earn More'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _EarnCategory(
                  icon: Icons.sports_esports_rounded,
                  iconColor: AppColors.success,
                  title: 'Games',
                  subtitle: 'Play & earn',
                  maxPoints: maxGames,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(AppPageRoute(page: const GamesScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EarnCategory(
                  icon: Icons.assignment_rounded,
                  iconColor: AppColors.primary,
                  title: 'Tasks',
                  subtitle: 'Complete offers',
                  maxPoints: maxTasks,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(AppPageRoute(page: const TasksScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EarnCategory(
                  icon: Icons.poll_rounded,
                  iconColor: AppColors.accent,
                  title: 'Surveys',
                  subtitle: 'Share opinion',
                  maxPoints: maxSurveys,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(AppPageRoute(page: const SurveysScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _EarnCategory extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int maxPoints;
  final VoidCallback onTap;

  const _EarnCategory({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.maxPoints,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      borderRadius: 20,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: iconColor.withValues(alpha: 0.18)),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.caption, textAlign: TextAlign.center),
          if (maxPoints > 0) ...[
            const SizedBox(height: 6),
            Text(
              'up to ${Formatters.points(maxPoints)}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const ShimmerPlaceholder(height: 60, borderRadius: 16),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(height: 280, borderRadius: 20),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(height: 72, borderRadius: 20),
          const SizedBox(height: 32),
          const ShimmerPlaceholder(height: 24, width: 120, borderRadius: 8),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ShimmerPlaceholder(height: 140, borderRadius: 20)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerPlaceholder(height: 140, borderRadius: 20)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerPlaceholder(height: 140, borderRadius: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    final String headline;
    final String subtitle;
    if (streak.currentStreak == 0) {
      headline = 'No Streak';
      subtitle = 'Start your streak by claiming points';
    } else {
      headline = 'Day ${streak.currentStreak}';
      subtitle = streak.isActiveToday ? 'Streak active today!' : 'Claim daily to keep your streak';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: const Center(
                child: Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline, style: AppTypography.headlineSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                streak.multiplierLabel,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.05, end: 0);
  }
}
