import 'package:flutter/foundation.dart';
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
import '../../models/offerwall_item_model.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
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
    final walletAsync = ref.watch(apiWalletProvider);
    final streakAsync = ref.watch(apiStreakProvider);

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
                    // API status indicator
                    walletAsync.when(
                      data: (_) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('API ✓',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700)),
                      ),
                      loading: () => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('API...',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.amber,
                                fontWeight: FontWeight.w700)),
                      ),
                      error: (_, __) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('API ✕',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.error,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Streak multiplier badge
                    streakAsync.when(
                      data: (s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '🔥 ${s.multiplier}x',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                walletAsync.when(
                  data: (w) => Text(
                    Formatters.number(w.totalPoints),
                    style: AppTypography.number.copyWith(fontSize: 32),
                  ),
                  loading: () => Text(
                    '...',
                    style: AppTypography.number.copyWith(fontSize: 32),
                  ),
                  error: (e, _) => Text(
                    'N/A',
                    style: AppTypography.number
                        .copyWith(fontSize: 32, color: AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          walletAsync.whenOrNull(
                data: (w) => w.todayPoints > 0
                    ? Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.success.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '+${Formatters.number(w.todayPoints)} today',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

// ─── Streak Banner (taps to Duolingo-style detail) ───
// Pure API-driven — no mock fallback
class _StreakBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(apiStreakProvider);

    return streakAsync.when(
      data: (streak) {
        final bool atRisk = !streak.collectedToday && streak.currentStreak > 0;
        final Color accentColor = atRisk ? AppColors.error : AppColors.warning;
        final String multiplierLabel = '${streak.multiplier}x';

        final String headline;
        final String subtitle;
        if (streak.currentStreak == 0) {
          headline = 'Start Your Streak';
          subtitle = 'Claim points today to begin';
        } else {
          headline = '${streak.currentStreak}-day Streak 🔥';
          subtitle = streak.collectedToday
              ? '$multiplierLabel multiplier · ${streak.nextMilestoneLabel}'
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
                    multiplierLabel,
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
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ShimmerPlaceholder(height: 60, borderRadius: 16),
      ),
      error: (e, st) {
        debugPrint('Error loading streak: $e');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderColor: AppColors.error.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Could not load streak',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                GestureDetector(
                  onTap: () => ref.invalidate(apiStreakProvider),
                  child: Text('Retry',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Daily Summary Widget (API-driven) ───
class _DailyGoalsWidget extends ConsumerWidget {
  const _DailyGoalsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(apiDailyStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: dailyAsync.when(
        data: (stats) => SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text("Today's Stats",
                      style: AppTypography.headlineSmall
                          .copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _DailyStatItem(
                    icon: Icons.timer_rounded,
                    label: 'Screen Time',
                    value: '${stats.screenTimeMinutes}m',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _DailyStatItem(
                    icon: Icons.toll_rounded,
                    label: 'Earned',
                    value: Formatters.number(stats.pointsEarned),
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  _DailyStatItem(
                    icon: Icons.savings_rounded,
                    label: 'Collected',
                    value: Formatters.number(stats.pointsCollected),
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => ShimmerPlaceholder(height: 100, borderRadius: 16),
        error: (_, __) => const SizedBox.shrink(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 80.ms);
  }
}

class _DailyStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DailyStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: AppTypography.headlineSmall
                    .copyWith(fontSize: 13, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ─── Accumulation Widget (Core Loop) ───
// Pure API-driven — uses apiWalletProvider for uncollected points, apiDailyStatsProvider for sessions
class _AccumulationWidget extends ConsumerWidget {
  const _AccumulationWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(apiWalletProvider);
    final dailyStatsAsync = ref.watch(apiDailyStatsProvider);

    return walletAsync.when(
      data: (wallet) {
        final uncollected = wallet.uncollectedPoints;
        final hasPending = uncollected > 0;
        final maxPts = EconomyConstants.maxAccumulationMinutes *
            EconomyConstants.pointsPerMinute;
        final isCapped = uncollected >= maxPts;
        final progress = maxPts > 0
            ? (uncollected / maxPts).clamp(0.0, 1.0)
            : 0.0;

        // Session counter from daily stats
        final sessionsCollected = dailyStatsAsync.valueOrNull?.pointsCollected ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            padding: EdgeInsets.zero,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCapped
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
                              isCapped ? AppColors.points : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCapped ? 'Ready to Claim!' : hasPending ? 'Points Available' : 'Accumulating...',
                        style: AppTypography.labelMedium.copyWith(
                          color:
                              isCapped ? AppColors.points : AppColors.success,
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
                          'Collected ${sessionsCollected}x today',
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
                  linearGradient: isCapped
                      ? const LinearGradient(
                          colors: [AppColors.points, AppColors.pointsDim])
                      : const LinearGradient(
                          colors: [AppColors.accent, AppColors.primary]),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.number(uncollected),
                        style: AppTypography.number.copyWith(
                          fontSize: 32,
                          color: isCapped
                              ? AppColors.points
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'uncollected',
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
                        points: uncollected, isFull: isCapped),
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
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ShimmerPlaceholder(height: 280, borderRadius: 20),
      ),
      error: (e, st) {
        debugPrint('Error loading wallet for accumulation: $e');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SurfaceCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.error.withValues(alpha: 0.3),
            child: Column(
              children: [
                Icon(Icons.cloud_off_rounded,
                    color: AppColors.error, size: 32),
                const SizedBox(height: 10),
                Text('Could not load wallet data',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.error)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    ref.invalidate(apiWalletProvider);
                    ref.invalidate(apiDailyStatsProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Retry',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Claim Button — pure API ───
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

    // Guard: don't call API if no uncollected points (prevents 400 error)
    if (widget.points <= 0) {
      if (mounted) {
        AppToast.show(context,
            message: 'No points to collect yet. Browse social media first!',
            type: ToastType.info);
      }
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    await AdService.showRewardedAd(
      onRewarded: () async {
        try {
          // Call API to collect points
          final result = await ref.read(eventsRepoProvider).collectPoints();
          final claimedPts = result.pointsCollected;
          debugPrint('✅ API collectPoints: $claimedPts pts, new balance: ${result.newBalance}');

          // Refresh all API providers
          ref.invalidate(apiWalletProvider);
          ref.invalidate(apiDailyStatsProvider);
          ref.invalidate(apiStreakProvider);
          ref.read(authNotifierProvider.notifier).refreshProfile();
          _retryCount = 0;

          HapticFeedback.heavyImpact();

          // Show celebration
          if (context.mounted) {
            final streakMultiplier = ref.read(apiStreakProvider).valueOrNull?.multiplier ?? 1.0;
            CelebrationService.showPointsClaimed(
              context,
              points: claimedPts,
              multiplierLabel: '${streakMultiplier}x',
            );
          }
        } catch (e) {
          debugPrint('❌ API collectPoints failed: $e');
          if (context.mounted) {
            AppToast.show(context,
                message: 'Failed to collect points: $e',
                type: ToastType.error);
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
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
    final streakAsync = ref.watch(apiStreakProvider);
    final multiplier = streakAsync.valueOrNull?.multiplier ?? 1.0;
    final multipliedPts = (widget.points * multiplier).round();

    final label = _isLoading
        ? 'Claiming...'
        : _retryCount >= _maxRetries
            ? 'Retry later'
            : 'Claim ${Formatters.number(multipliedPts)} pts (${multiplier}x)';

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
    // Spins count is not available from daily stats API, use constant
    const spinsLeft = EconomyConstants.maxSpinsPerDay;

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
