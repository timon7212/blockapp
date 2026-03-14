import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/constants/economy_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_model.dart';

class StreakDetailScreen extends ConsumerStatefulWidget {
  const StreakDetailScreen({super.key});

  @override
  ConsumerState<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends ConsumerState<StreakDetailScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: _buildStreakHero(streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: _buildCalendar(streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: _buildMultiplierTiers(streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: _buildStreakShield(streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: _buildStats(streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
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

  Widget _buildStreakHero(streak) {
    final isActive = streak.isActiveToday;
    final fireColor = isActive ? AppColors.warning : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Fire icon with animated glow
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
            style: AppTypography.number
                .copyWith(fontSize: 56, color: fireColor, height: 1.0),
          ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.8, end: 1.0),
          const SizedBox(height: 4),
          Text(
            streak.currentStreak == 1 ? 'day streak' : 'day streak',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          // Current tier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  streak.currentTier.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  streak.multiplierLabel,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildCalendar(streak) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build last 28 days (4 weeks)
    final days = List.generate(28, (i) {
      return today.subtract(Duration(days: 27 - i));
    });

    final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 28 Days',
                style: AppTypography.headlineSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Week day headers
            Row(
              children: weekLabels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l,
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            ...List.generate(4, (week) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: List.generate(7, (day) {
                    final idx = week * 7 + day;
                    final date = days[idx];
                    final isToday = date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final wasActive = streak.wasActiveOn(date);
                    final isFuture = date.isAfter(today);

                    return Expanded(
                      child: Center(
                        child: _CalendarDot(
                          day: date.day,
                          isToday: isToday,
                          wasActive: wasActive,
                          isFuture: isFuture,
                          isFreezeUsed: false,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.success, label: 'Active'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.accent, label: 'Today'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.surfaceLight, label: 'Missed'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildMultiplierTiers(streak) {
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
                Text('Multiplier Tiers', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            ...EconomyConstants.streakTiers.asMap().entries.map((entry) {
              final tier = entry.value;
              final isCurrentTier = streak.currentTier == tier;
              final isUnlocked = streak.currentStreak >= tier.minDays;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    // Tier indicator
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentTier
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : isUnlocked
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.surfaceLight,
                        border: Border.all(
                          color: isCurrentTier
                              ? AppColors.primary
                              : isUnlocked
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.border,
                          width: isCurrentTier ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Icon(
                                isCurrentTier
                                    ? Icons.local_fire_department_rounded
                                    : Icons.check_rounded,
                                size: 18,
                                color: isCurrentTier
                                    ? AppColors.primary
                                    : AppColors.success,
                              )
                            : Icon(Icons.lock_outline_rounded,
                                size: 14, color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.name,
                            style: AppTypography.labelLarge.copyWith(
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
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrentTier
                            ? Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3))
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
            // Progress to next tier
            if (streak.nextTier != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${streak.daysToNextTier} days to ${streak.nextTier!.label} multiplier',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildStreakShield(streak) {
    final wallet = ref.watch(walletProvider);
    final canAffordFreeze =
        wallet.totalPoints >= EconomyConstants.streakFreezeCost;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Streak Shield', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Protects your streak if you miss a day',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Owned shields
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${streak.freezesOwned}',
                          style: AppTypography.number.copyWith(
                            fontSize: 28,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('shields owned',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.accent)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Buy button
                Expanded(
                  child: GestureDetector(
                    onTap: canAffordFreeze
                        ? () {
                            HapticFeedback.heavyImpact();
                            ref
                                .read(streakProvider.notifier)
                                .buyFreeze();
                            ref.read(walletProvider.notifier).spendPoints(
                                EconomyConstants.streakFreezeCost,
                                'Streak Shield',
                                TransactionType.giftCardPurchase);
                            if (context.mounted) {
                              AppToast.show(context,
                                  message: 'Streak Shield purchased! 🛡️',
                                  type: ToastType.success);
                            }
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: canAffordFreeze
                            ? AppColors.primaryGradient
                            : null,
                        color:
                            canAffordFreeze ? null : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 24,
                            color: canAffordFreeze
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Formatters.number(EconomyConstants.streakFreezeCost)} pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: canAffordFreeze
                                  ? Colors.white
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildStats(streak) {
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
              value: streak.multiplierLabel,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.shield_rounded,
              label: 'Shields Available',
              value: '${streak.freezesOwned}',
              color: AppColors.success,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }
}

class _CalendarDot extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool wasActive;
  final bool isFuture;
  final bool isFreezeUsed;

  const _CalendarDot({
    required this.day,
    required this.isToday,
    required this.wasActive,
    required this.isFuture,
    required this.isFreezeUsed,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color? borderColor;

    if (isFuture) {
      bgColor = Colors.transparent;
      textColor = AppColors.textTertiary.withValues(alpha: 0.3);
    } else if (isToday) {
      bgColor = wasActive
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.accent.withValues(alpha: 0.15);
      textColor =
          wasActive ? AppColors.success : AppColors.accent;
      borderColor = wasActive
          ? AppColors.success.withValues(alpha: 0.5)
          : AppColors.accent.withValues(alpha: 0.4);
    } else if (wasActive) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      textColor = AppColors.success;
    } else if (isFreezeUsed) {
      bgColor = AppColors.accent.withValues(alpha: 0.1);
      textColor = AppColors.accent;
    } else {
      bgColor = AppColors.surfaceLight.withValues(alpha: 0.5);
      textColor = AppColors.textTertiary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: Center(
        child: wasActive && !isToday
            ? Icon(Icons.check_rounded, size: 16, color: textColor)
            : Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
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
