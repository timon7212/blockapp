import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../design_system/widgets/result_sheet.dart';
import '../../core/utils/formatters.dart';
import '../../models/raffle_model.dart';
import '../../services/ad_service.dart';
import '../../design_system/utils/app_page_route.dart';
import '../earn/games_screen.dart';
import '../spin_wheel/spin_wheel_screen.dart';
import 'winners_history_screen.dart';

class RafflesScreen extends ConsumerWidget {
  const RafflesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raffles = ref.watch(rafflesProvider);

    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
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
                        Navigator.of(context).push(AppPageRoute(page: const WinnersHistoryScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('Winners', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
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
                child: Text('Complete actions to enter. No points required.', style: AppTypography.bodySmall),
              ).animate().fadeIn(duration: 400.ms, delay: 50.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            if (raffles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('No raffles available', style: AppTypography.headlineMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text('Check back soon', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              )
            else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: _RaffleCard(raffle: raffles[i])
                        .animate()
                        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 100 + i * 100))
                        .slideY(begin: 0.03, end: 0),
                  ),
                  childCount: raffles.length,
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 30)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RaffleCard extends ConsumerWidget {
  final RaffleModel raffle;
  const _RaffleCard({required this.raffle});

  Color get _color {
    switch (raffle.type) {
      case RaffleType.daily: return AppColors.raffleDaily;
      case RaffleType.weekly: return AppColors.raffleWeekly;
      case RaffleType.monthly: return AppColors.raffleMonthly;
    }
  }

  IconData get _icon {
    switch (raffle.type) {
      case RaffleType.daily: return Icons.bolt_rounded;
      case RaffleType.weekly: return Icons.emoji_events_rounded;
      case RaffleType.monthly: return Icons.diamond_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedTasks = raffle.entryTasks.where((t) => t.isCompleted).length;
    final allDone = raffle.allTasksCompleted;
    final winnersCount = (raffle.totalParticipants * 0.1).round().clamp(1, 9999);

    return SurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      borderColor: raffle.isEntered ? _color.withValues(alpha: 0.3) : AppColors.border,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                          Text(raffle.title, style: AppTypography.headlineMedium),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(raffle.type.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _color)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.points(raffle.prizePoints), style: AppTypography.headlineLarge.copyWith(color: _color)),
                        const SizedBox(height: 2),
                        Text('pts prize', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _RaffleStat(icon: Icons.people_outline_rounded, label: Formatters.compact(raffle.totalParticipants)),
                    const SizedBox(width: 16),
                    _RaffleStat(icon: Icons.timer_outlined, label: Formatters.duration(raffle.timeRemaining)),
                    const SizedBox(width: 16),
                    _RaffleStat(icon: Icons.emoji_events_outlined, label: '$winnersCount winners'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Text('Entry Tasks', style: AppTypography.headlineSmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: allDone ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedTasks/${raffle.entryTasks.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: allDone ? AppColors.success : AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          ...raffle.entryTasks.map((task) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _TaskRow(task: task, raffleId: raffle.id, color: _color),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: PrimaryButton(
              label: raffle.isEntered ? 'Entered' : allDone ? 'Enter Raffle' : 'Complete Tasks to Enter',
              enabled: allDone && !raffle.isEntered,
              gradient: raffle.isEntered
                  ? LinearGradient(colors: [AppColors.success.withValues(alpha: 0.3), AppColors.success.withValues(alpha: 0.2)])
                  : LinearGradient(colors: [_color, _color.withValues(alpha: 0.7)]),
              icon: raffle.isEntered ? Icons.check_circle_rounded : null,
              height: 48,
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(rafflesProvider.notifier).enterRaffle(raffle.id);
                ResultSheet.show(
                  context,
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  title: 'You\'re In!',
                  subtitle: 'Entered ${raffle.title}. Good luck!',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final RaffleEntryTask task;
  final String raffleId;
  final Color color;
  const _TaskRow({required this.task, required this.raffleId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.isCompleted ? AppColors.success : Colors.transparent,
            border: task.isCompleted ? null : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: task.isCompleted ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(width: 10),
        Icon(task.icon, size: 16, color: task.isCompleted ? AppColors.textTertiary : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textTertiary,
                ),
              ),
              if (!task.isCompleted && task.requiredCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            minHeight: 3,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${task.currentCount}/${task.requiredCount}', style: AppTypography.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (!task.isCompleted)
          GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              if (task.type == RaffleTaskType.watchAds) {
                await AdService.showRewardedAd(
                  onRewarded: () {
                    ref.read(rafflesProvider.notifier).completeTask(raffleId, task.id);
                    HapticFeedback.mediumImpact();
                  },
                  onFailed: () {
                    if (context.mounted) AppToast.show(context, message: 'Ad failed to load. Try again.', type: ToastType.error);
                  },
                );
              } else if (task.type == RaffleTaskType.completeOffer) {
                Navigator.of(context).push(AppPageRoute(page: const GamesScreen()));
              } else if (task.type == RaffleTaskType.inviteFriend) {
                final container = ProviderScope.containerOf(context);
                container.read(currentTabProvider.notifier).state = 3;
              } else if (task.type == RaffleTaskType.spinWheel) {
                Navigator.of(context).push(AppPageRoute(page: const SpinWheelScreen()));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                task.type == RaffleTaskType.watchAds ? 'Watch' : 'Go',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
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
