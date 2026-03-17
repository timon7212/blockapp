import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../shared/providers/api_providers.dart';
import '../../core/constants/economy_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/dto/stats_dto.dart';

class StreakDetailScreen extends ConsumerStatefulWidget {
  const StreakDetailScreen({super.key});

  @override
  ConsumerState<StreakDetailScreen> createState() =>
      _StreakDetailScreenState();
}

class _StreakDetailScreenState
    extends ConsumerState<StreakDetailScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(apiStreakProvider);
    final walletAsync = ref.watch(apiWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              streakAsync.when(
                data: (streak) => _buildContent(
                    streak, walletAsync.valueOrNull?.totalPoints ?? 0),
                loading: () => _buildLoading(),
                error: (e, _) => _buildError(e),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality:
                      BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    AppColors.warning,
                    AppColors.accent,
                    AppColors.primary,
                    AppColors.success,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ShimmerPlaceholder(height: 200, borderRadius: 20),
                const SizedBox(height: 28),
                ShimmerPlaceholder(height: 300, borderRadius: 16),
                const SizedBox(height: 28),
                ShimmerPlaceholder(height: 200, borderRadius: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Failed to load streak data',
                    style: AppTypography.bodyMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(apiStreakProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(StreakDto streak, int totalPoints) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildStreakHero(streak)),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: _buildMultiplierTiers(streak)),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: _buildStats(streak)),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
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
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Streak', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildStreakHero(StreakDto streak) {
    final isActive = streak.collectedToday;
    final fireColor =
        isActive ? AppColors.warning : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fireColor.withValues(alpha: 0.12),
              border: Border.all(
                  color: fireColor.withValues(alpha: 0.3), width: 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: fireColor.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                Icons.local_fire_department_rounded,
                color: fireColor,
                size: 52,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.06, duration: 1500.ms),
          const SizedBox(height: 16),
          Text(
            '${streak.currentStreak}',
            style: AppTypography.number.copyWith(
                fontSize: 56, color: fireColor, height: 1.0),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scaleXY(begin: 0.8, end: 1.0),
          const SizedBox(height: 4),
          Text(
            'day streak',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          // Current multiplier badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTierName(streak.multiplier),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${streak.multiplier}x',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          if (!isActive && streak.currentStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Claim today to keep your streak!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .then()
                .scaleXY(begin: 1.0, end: 1.03, duration: 800.ms),
          ],
          if (streak.nextMilestoneLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              streak.nextMilestoneLabel,
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildMultiplierTiers(StreakDto streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Multiplier Tiers',
                    style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...EconomyConstants.streakTiers
                .asMap()
                .entries
                .map((entry) {
              final tier = entry.value;
              final isCurrentTier =
                  streak.multiplier == tier.multiplier;
              final isUnlocked =
                  streak.currentStreak >= tier.minDays;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentTier
                            ? AppColors.primary
                                .withValues(alpha: 0.2)
                            : isUnlocked
                                ? AppColors.success
                                    .withValues(alpha: 0.12)
                                : AppColors.surfaceLight,
                        border: Border.all(
                          color: isCurrentTier
                              ? AppColors.primary
                              : isUnlocked
                                  ? AppColors.success
                                      .withValues(alpha: 0.3)
                                  : AppColors.border,
                          width: isCurrentTier ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Icon(
                                isCurrentTier
                                    ? Icons
                                        .local_fire_department_rounded
                                    : Icons.check_rounded,
                                size: 18,
                                color: isCurrentTier
                                    ? AppColors.primary
                                    : AppColors.success,
                              )
                            : Icon(Icons.lock_outline_rounded,
                                size: 14,
                                color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.name,
                            style:
                                AppTypography.labelLarge.copyWith(
                              color: isCurrentTier
                                  ? AppColors.textPrimary
                                  : isUnlocked
                                      ? AppColors.textSecondary
                                      : AppColors.textTertiary,
                              fontWeight: isCurrentTier
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          Text(
                            tier.minDays == 0
                                ? 'Start here'
                                : '${tier.minDays}+ days',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrentTier
                            ? AppColors.primary
                                .withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrentTier
                            ? Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Text(
                        tier.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCurrentTier
                              ? AppColors.primary
                              : isUnlocked
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildStats(StreakDto streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stats', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.local_fire_department_rounded,
              label: 'Current Streak',
              value: '${streak.currentStreak} days',
              color: AppColors.warning,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.emoji_events_rounded,
              label: 'Longest Streak',
              value: '${streak.longestStreak} days',
              color: AppColors.accent,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.speed_rounded,
              label: 'Current Multiplier',
              value: '${streak.multiplier}x',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.today_rounded,
              label: 'Collected Today',
              value: streak.collectedToday ? 'Yes' : 'No',
              color: streak.collectedToday
                  ? AppColors.success
                  : AppColors.error,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  String _getTierName(double multiplier) {
    for (final tier in EconomyConstants.streakTiers.reversed) {
      if (multiplier >= tier.multiplier) return tier.name;
    }
    return 'Starter';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, size: 18, color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTypography.bodyMedium),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
