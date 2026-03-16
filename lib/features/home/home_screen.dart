import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/providers/auth_notifier.dart';
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
import '../../models/daily_goal_model.dart';
import '../../services/ad_service.dart';
import '../../services/celebration_service.dart';
import '../spin_wheel/spin_wheel_screen.dart';
import '../streak/streak_detail_screen.dart';
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
            // Refresh all API data
            ref.invalidate(apiWalletProvider);
            ref.invalidate(apiDailyStatsProvider);
            ref.invalidate(apiStreakProvider);
            ref.read(authNotifierProvider.notifier).refreshProfile();
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              AppToast.show(context,
                  message: 'Refreshed!', type: ToastType.success);
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
                // ── Streak Banner (tappable → streak detail) ──
                SliverToBoxAdapter(child: _StreakBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // ── Daily Goals progress ──
                const SliverToBoxAdapter(child: _DailyGoalsWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // ── Accumulation (core loop) ──
                const SliverToBoxAdapter(child: _AccumulationWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // ── Quick Actions: Spin + Raffle CTA ──
                SliverToBoxAdapter(child: _QuickActions()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // ── Earn More ──
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

// ─── Top Bar with Balance + Rank ───
class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final rank = ref.watch(rankProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Balance',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rank badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rank.rankColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: rank.rankColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '${rank.currentRank.icon} ${rank.currentRank.name}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: rank.rankColor,
                        ),
                      ),
                    ),
                  ],
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward_rounded,
                      size: 14, color: AppColors.success),
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

// ─── Streak Banner (taps to Duolingo-style detail) ───
class _StreakBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    final bool atRisk = !streak.isActiveToday && streak.currentStreak > 0;
    final Color accentColor = atRisk ? AppColors.error : AppColors.warning;

    final String headline;
    final String subtitle;
    if (streak.currentStreak == 0) {
      headline = 'Start Your Streak';
      subtitle = 'Claim points today to begin';
    } else {
      headline = '${streak.currentStreak}-day Streak 🔥';
      subtitle = streak.isActiveToday
          ? '${streak.currentTier.name} · ${streak.multiplierLabel} multiplier'
          : 'Claim now to keep your streak!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderColor: atRisk ? AppColors.error.withValues(alpha: 0.4) : null,
        onTap: () {
          Navigator.of(context)
              .push(AppPageRoute(page: const StreakDetailScreen()));
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Icon(Icons.local_fire_department_rounded,
                    color: accentColor, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline, style: AppTypography.headlineSmall),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: atRisk
                            ? AppColors.error
                            : AppColors.textTertiary,
                      )),
                ],
              ),
            ),
            // Multiplier badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                streak.multiplierLabel,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 50.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

// ─── Daily Goals Mini Widget ───
class _DailyGoalsWidget extends ConsumerWidget {
  const _DailyGoalsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(dailyGoalsProvider);
    final completed = goals.completedCount;
    final total = goals.totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Daily Goals',
                    style: AppTypography.headlineSmall
                        .copyWith(fontSize: 14)),
                const Spacer(),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: completed == total
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress dots
            Row(
              children: goals.goals.map((g) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: g.isCompleted
                                ? AppColors.success
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          g.icon,
                          size: 18,
                          color: g.isCompleted
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.title,
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            color: g.isCompleted
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (goals.allCompleted && !goals.dailyBonusClaimed) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  ref.read(dailyGoalsProvider.notifier).claimDailyBonus();
                  ref.read(walletProvider.notifier).addPoints(
                        EconomyConstants.dailyGoalBonusFull,
                        'Daily Goals Bonus ⭐',
                        TransactionType.offerwall,
                      );
                  CelebrationService.showDailyGoalsComplete(
                    context,
                    bonusPoints: EconomyConstants.dailyGoalBonusFull,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Claim ${Formatters.number(EconomyConstants.dailyGoalBonusFull)} bonus! ⭐',
                      style: AppTypography.button
                          .copyWith(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 80.ms);
  }
}

// ─── Accumulation Widget (Core Loop) ───
class _AccumulationWidget extends ConsumerWidget {
  const _AccumulationWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(screenTimeProvider);
    final hasPending = st.accumulatedPoints > 0;
    final progress = st.progress.clamp(0.0, 1.0);
    final sessionsToday = ref.watch(sessionsClaimedTodayProvider);

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
                      color:
                          st.isCapped ? AppColors.points : AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    st.isCapped ? 'Ready to Claim!' : 'Accumulating...',
                    style: AppTypography.labelMedium.copyWith(
                      color:
                          st.isCapped ? AppColors.points : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Sessions counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Session ${sessionsToday + 1}/${EconomyConstants.maxSessionsPerDay}',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
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
                  ? const LinearGradient(
                      colors: [AppColors.points, AppColors.pointsDim])
                  : const LinearGradient(
                      colors: [AppColors.accent, AppColors.primary]),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.number(st.accumulatedPoints),
                    style: AppTypography.number.copyWith(
                      fontSize: 32,
                      color: st.isCapped
                          ? AppColors.points
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${st.accumulatedMinutes}/${EconomyConstants.maxAccumulationMinutes} min',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('points accumulated',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 24),
            if (hasPending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _ClaimButton(
                    points: st.accumulatedPoints, isFull: st.isCapped),
              )
            else
              // ── Empty State: Guide user to social media ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android_rounded,
                              size: 18, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            'Go browse social media!',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.accent,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Open Instagram, TikTok, X, or Snapchat.\nAfter 20 min, come back to claim 2,000 pts!',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(
          begin: 0.05,
          end: 0,
        );
  }
}

// ─── Claim Button with improved error handling ───
class _ClaimButton extends ConsumerStatefulWidget {
  final int points;
  final bool isFull;
  const _ClaimButton({required this.points, required this.isFull});

  @override
  ConsumerState<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends ConsumerState<_ClaimButton> {
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  void _claim() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    await AdService.showRewardedAd(
      onRewarded: () {
        final basePts = ref.read(screenTimeProvider.notifier).claim();
        final streak = ref.read(streakProvider);
        final multiplied = (basePts * streak.multiplier).round();

        // Record streak
        ref.read(streakProvider.notifier).recordClaim();

        // Add points
        ref.read(walletProvider.notifier).addPoints(
              multiplied,
              'Screen time claim (${streak.multiplierLabel})',
              TransactionType.screenTimeClaim,
            );

        // Update rank
        ref.read(rankProvider.notifier).addPoints(multiplied);

        // Complete daily goal
        ref
            .read(dailyGoalsProvider.notifier)
            .completeGoal(DailyGoalType.claimSession);

        // Track ad watched
        ref
            .read(dailyGoalsProvider.notifier)
            .completeGoal(DailyGoalType.watchAds);

        // Increment sessions
        ref.read(sessionsClaimedTodayProvider.notifier).state++;

        // Reset retry count
        _retryCount = 0;

        HapticFeedback.heavyImpact();

        // Show celebration
        if (context.mounted) {
          CelebrationService.showPointsClaimed(
            context,
            points: multiplied,
            multiplierLabel: streak.multiplierLabel,
          );
        }

        // Check for streak milestone
        final newStreak = ref.read(streakProvider);
        if (newStreak.isSpecialMilestone) {
          Future.delayed(const Duration(milliseconds: 2800), () {
            if (context.mounted) {
              CelebrationService.showStreakMilestone(
                context,
                days: newStreak.currentStreak,
                tierName: newStreak.currentTier.name,
                multiplierLabel: newStreak.multiplierLabel,
              );
            }
          });
        }

        setState(() => _isLoading = false);
      },
      onFailed: () {
        setState(() {
          _isLoading = false;
          _retryCount++;
        });
        if (context.mounted) {
          if (_retryCount >= _maxRetries) {
            AppToast.show(context,
                message:
                    'Ad service unavailable. Please try again later.',
                type: ToastType.error);
          } else {
            AppToast.show(context,
                message:
                    'Ad failed to load. Tap to retry ($_retryCount/$_maxRetries)',
                type: ToastType.error);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final multipliedPts = (widget.points * streak.multiplier).round();

    final label = _isLoading
        ? 'Loading ad...'
        : _retryCount >= _maxRetries
            ? 'Retry later'
            : 'Claim ${Formatters.number(multipliedPts)} pts (${streak.multiplierLabel})';

    return GestureDetector(
      onTap: _retryCount < _maxRetries ? _claim : null,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _retryCount >= _maxRetries
              ? null
              : widget.isFull
                  ? AppColors.pointsGradient
                  : AppColors.successGradient,
          color:
              _retryCount >= _maxRetries ? AppColors.surfaceLight : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                _retryCount >= _maxRetries
                    ? Icons.error_outline_rounded
                    : Icons.play_circle_filled_rounded,
                color: _retryCount >= _maxRetries
                    ? AppColors.textTertiary
                    : AppColors.textInverse,
                size: 22,
              ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: _retryCount >= _maxRetries
                    ? AppColors.textTertiary
                    : AppColors.textInverse,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 2200.ms,
          color: Colors.white.withValues(alpha: 0.12),
        );
  }
}

// ─── Quick Actions: Spin + Raffle CTA ───
class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spinsLeft = ref.watch(spinsRemainingProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Spin Wheel
          Expanded(
            child: SurfaceCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context)
                    .push(AppPageRoute(page: const SpinWheelScreen()));
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Icon(Icons.casino_rounded,
                            color: AppColors.accent, size: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spin & Win',
                            style: AppTypography.headlineSmall
                                .copyWith(fontSize: 13)),
                        Text('$spinsLeft spins left',
                            style: AppTypography.caption.copyWith(
                                color: spinsLeft > 0
                                    ? AppColors.accent
                                    : AppColors.textTertiary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Raffle CTA
          Expanded(
            child: SurfaceCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              borderColor: AppColors.success.withValues(alpha: 0.2),
              onTap: () {
                HapticFeedback.mediumImpact();
                // Navigate to raffles tab
                ref.read(currentTabProvider.notifier).state = 1;
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Icon(Icons.emoji_events_rounded,
                            color: AppColors.success, size: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raffles',
                            style: AppTypography.headlineSmall
                                .copyWith(fontSize: 13)),
                        Text('Win 50K+ pts',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.success, fontSize: 10)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ─── Earn More Section ───
class _EarnMoreSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOffers = ref.watch(offerwallProvider);

    final gameOffers = allOffers
        .where(
            (o) => o.type == OfferType.reachLevel || o.type == OfferType.installApp)
        .toList();
    final taskOffers = allOffers
        .where(
            (o) => o.type == OfferType.register || o.type == OfferType.subscribe)
        .toList();
    final surveyOffers =
        allOffers.where((o) => o.type == OfferType.survey).toList();

    final maxGames = gameOffers.isEmpty
        ? 0
        : gameOffers
            .map((o) => o.rewardPoints)
            .reduce((a, b) => a > b ? a : b);
    final maxTasks = taskOffers.isEmpty
        ? 0
        : taskOffers
            .map((o) => o.rewardPoints)
            .reduce((a, b) => a > b ? a : b);
    final maxSurveys = surveyOffers.isEmpty
        ? 0
        : surveyOffers
            .map((o) => o.rewardPoints)
            .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Earn More'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Complete offers to earn extra points',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textTertiary),
          ),
        ),
        const SizedBox(height: 14),
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
                    Navigator.of(context)
                        .push(AppPageRoute(page: const GamesScreen()));
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
                    Navigator.of(context)
                        .push(AppPageRoute(page: const TasksScreen()));
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
                    Navigator.of(context)
                        .push(AppPageRoute(page: const SurveysScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.05, end: 0);
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
              border:
                  Border.all(color: iconColor.withValues(alpha: 0.18)),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(subtitle,
              style: AppTypography.caption,
              textAlign: TextAlign.center),
          if (maxPoints > 0) ...[
            const SizedBox(height: 6),
            Text(
              'up to ${Formatters.points(maxPoints)}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success),
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
          const SizedBox(height: 20),
          const ShimmerPlaceholder(height: 80, borderRadius: 16),
          const SizedBox(height: 24),
          const ShimmerPlaceholder(height: 280, borderRadius: 20),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child:
                      ShimmerPlaceholder(height: 72, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      ShimmerPlaceholder(height: 72, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerPlaceholder(height: 24, width: 120, borderRadius: 8),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child:
                      ShimmerPlaceholder(height: 140, borderRadius: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      ShimmerPlaceholder(height: 140, borderRadius: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      ShimmerPlaceholder(height: 140, borderRadius: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
