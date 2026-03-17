import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/raffle_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../design_system/widgets/result_sheet.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';
import '../../services/ad_service.dart';
import '../../design_system/utils/app_page_route.dart';
import '../earn/games_screen.dart';
import '../spin_wheel/spin_wheel_screen.dart';
import 'winners_history_screen.dart';

class RafflesScreen extends ConsumerWidget {
  const RafflesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiRafflesAsync = ref.watch(apiRafflesProvider);

    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    Text('Raffles', style: AppTypography.displaySmall),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                            AppPageRoute(page: const WinnersHistoryScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('Winners',
                                style: AppTypography.labelMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Complete actions to enter. No points required.',
                    style: AppTypography.bodySmall),
              ).animate().fadeIn(duration: 400.ms, delay: 50.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // ── Body: API-only ──
            ...apiRafflesAsync.when(
              data: (apiRaffles) {
                if (apiRaffles.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    ),
                  ];
                }
                return [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: _ApiRaffleCard(raffle: apiRaffles[i])
                            .animate()
                            .fadeIn(
                                duration: 500.ms,
                                delay: Duration(
                                    milliseconds: 100 + i * 100))
                            .slideY(begin: 0.03, end: 0),
                      ),
                      childCount: apiRaffles.length,
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 30)),
                ];
              },
              loading: () => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ShimmerPlaceholder(
                              height: 220, borderRadius: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              error: (e, st) {
                debugPrint('Raffles API error: $e');
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: 'Could not load raffles',
                      onRetry: () => ref.invalidate(apiRafflesProvider),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('No raffles available',
              style: AppTypography.headlineMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Check back soon', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

// ─── Error State ───
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.headlineMedium
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
  }
}

// ─── API Raffle Card (uses RaffleDto) ───
class _ApiRaffleCard extends ConsumerWidget {
  final RaffleDto raffle;
  const _ApiRaffleCard({required this.raffle});

  Color get _color {
    switch (raffle.type) {
      case RaffleTypeDto.daily:
        return AppColors.raffleDaily;
      case RaffleTypeDto.weekly:
        return AppColors.raffleWeekly;
      case RaffleTypeDto.monthly:
        return AppColors.raffleMonthly;
    }
  }

  IconData get _icon {
    switch (raffle.type) {
      case RaffleTypeDto.daily:
        return Icons.bolt_rounded;
      case RaffleTypeDto.weekly:
        return Icons.emoji_events_rounded;
      case RaffleTypeDto.monthly:
        return Icons.diamond_rounded;
    }
  }

  String get _typeLabel {
    switch (raffle.type) {
      case RaffleTypeDto.daily:
        return 'Daily';
      case RaffleTypeDto.weekly:
        return 'Weekly';
      case RaffleTypeDto.monthly:
        return 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedPrereqs = raffle.prerequisites.where((p) => p.met).length;
    final allMet = raffle.isEligible;
    final winnersCount =
        (raffle.totalParticipants * 0.1).round().clamp(1, 9999);
    final timeRemaining = Duration(seconds: raffle.timeRemainingSeconds);

    return SurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      borderColor: raffle.isEntered
          ? _color.withValues(alpha: 0.3)
          : AppColors.border,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_icon, color: _color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(raffle.title,
                              style: AppTypography.headlineMedium),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_typeLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _color)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.points(raffle.prizeAmount),
                            style: AppTypography.headlineLarge
                                .copyWith(color: _color)),
                        const SizedBox(height: 2),
                        Text('pts prize', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _RaffleStat(
                        icon: Icons.people_outline_rounded,
                        label:
                            Formatters.compact(raffle.totalParticipants)),
                    const SizedBox(width: 16),
                    _RaffleStat(
                        icon: Icons.timer_outlined,
                        label: Formatters.duration(timeRemaining)),
                    const SizedBox(width: 16),
                    _RaffleStat(
                        icon: Icons.emoji_events_outlined,
                        label: '$winnersCount winners'),
                  ],
                ),
              ],
            ),
          ),
          // Prerequisites
          if (raffle.prerequisites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Text('Requirements', style: AppTypography.headlineSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allMet
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.surfaceMid,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$completedPrereqs/${raffle.prerequisites.length}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: allMet
                              ? AppColors.success
                              : AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            ...raffle.prerequisites.map((prereq) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: _PrerequisiteRow(prereq: prereq, color: _color),
                )),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: PrimaryButton(
              label: raffle.isEntered
                  ? 'Entered ✓'
                  : allMet
                      ? 'Enter Raffle'
                      : 'Complete Requirements',
              enabled: allMet && !raffle.isEntered,
              gradient: raffle.isEntered
                  ? LinearGradient(colors: [
                      AppColors.success.withValues(alpha: 0.3),
                      AppColors.success.withValues(alpha: 0.2)
                    ])
                  : LinearGradient(
                      colors: [_color, _color.withValues(alpha: 0.7)]),
              icon: raffle.isEntered ? Icons.check_circle_rounded : null,
              height: 48,
              onPressed: () async {
                HapticFeedback.heavyImpact();
                try {
                  await ref.read(raffleRepoProvider).enterRaffle(
                      raffle.id,
                      const RaffleEntryRequest(adType: 'rewarded'));
                  ref.invalidate(apiRafflesProvider);
                  if (context.mounted) {
                    ResultSheet.show(
                      context,
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      title: 'You\'re In!',
                      subtitle: 'Entered ${raffle.title}. Good luck!',
                    );
                  }
                } catch (e) {
                  debugPrint('Enter raffle failed: $e');
                  if (context.mounted) {
                    AppToast.show(context,
                        message: 'Failed to enter: $e',
                        type: ToastType.error);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prerequisite Row (API) ───
class _PrerequisiteRow extends StatelessWidget {
  final RafflePrerequisiteDto prereq;
  final Color color;
  const _PrerequisiteRow({required this.prereq, required this.color});

  IconData get _icon {
    switch (prereq.type) {
      case 'ads_watched':
        return Icons.play_circle_outline_rounded;
      case 'tasks_completed':
        return Icons.assignment_outlined;
      case 'surveys_completed':
        return Icons.poll_outlined;
      case 'games_completed':
        return Icons.sports_esports_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String get _title {
    switch (prereq.type) {
      case 'ads_watched':
        return 'Watch ${prereq.requiredCount} ads';
      case 'tasks_completed':
        return 'Complete ${prereq.requiredCount} tasks';
      case 'surveys_completed':
        return 'Complete ${prereq.requiredCount} surveys';
      case 'games_completed':
        return 'Play ${prereq.requiredCount} games';
      default:
        return '${prereq.type}: ${prereq.requiredCount}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (prereq.userCurrentCount / prereq.requiredCount).clamp(0.0, 1.0);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: prereq.met ? AppColors.success : Colors.transparent,
            border: prereq.met
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: prereq.met
              ? const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Icon(_icon,
            size: 16,
            color: prereq.met
                ? AppColors.textTertiary
                : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: prereq.met
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  decoration:
                      prereq.met ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textTertiary,
                ),
              ),
              if (!prereq.met && prereq.requiredCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          '${prereq.userCurrentCount}/${prereq.requiredCount}',
                          style: AppTypography.caption
                              .copyWith(fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RaffleStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RaffleStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
