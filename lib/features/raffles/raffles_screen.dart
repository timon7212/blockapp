import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../core/utils/formatters.dart';
import '../../models/raffle_model.dart';
import '../../models/mission_model.dart';
import '../earn/spin_wheel_page.dart';
import '../earn/tasks_page.dart';

class RafflesScreen extends ConsumerWidget {
  const RafflesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raffles = ref.watch(rafflesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Text('Raffles', style: AppTypography.displaySmall),
                  const Spacer(),
                  CoinBadge(amount: ref.watch(walletProvider).totalCoins),
                ],
              ),
            ),
            ...raffles.map((raffle) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _RaffleSection(raffle: raffle),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _RaffleSection extends ConsumerWidget {
  final RaffleModel raffle;
  const _RaffleSection({required this.raffle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(raffleMissionsProvider(raffle.type));
    final completedCount = missions.where((m) => m.completed).length;
    final allDone = completedCount >= missions.length;

    final typeColors = {
      RaffleType.daily: AppColors.green,
      RaffleType.weekly: AppColors.primary,
      RaffleType.monthly: AppColors.purple,
    };
    final color = typeColors[raffle.type] ?? AppColors.primary;
    final winnersCount = (raffle.totalParticipants * 0.1).round().clamp(1, 9999);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(raffle.type.emoji, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(raffle.title, style: AppTypography.headlineMedium),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(raffle.type.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                          ),
                        ],
                      ),
                    ),
                    Text(Formatters.currency(raffle.prizeAmount), style: AppTypography.headlineLarge.copyWith(color: color)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _RaffleStat(icon: Icons.people_outline_rounded, label: Formatters.compact(raffle.totalParticipants)),
                    const SizedBox(width: 16),
                    _RaffleStat(icon: Icons.timer_outlined, label: Formatters.duration(raffle.timeRemaining)),
                    const SizedBox(width: 16),
                    _RaffleStat(icon: Icons.emoji_events_outlined, label: '$winnersCount winners'),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showWinnersHistory(context, raffle),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text('Winners History', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Row(
              children: [
                Text('Tasks to enter', style: AppTypography.headlineSmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: allDone ? AppColors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$completedCount/${missions.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: allDone ? AppColors.green : AppColors.primary)),
                ),
              ],
            ),
          ),
          ...missions.map((m) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: _MissionRow(mission: m),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (!allDone) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Complete all tasks to enter this raffle'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ));
                  return;
                }
                if (raffle.isEntered) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Entered ${raffle.title}!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                ));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, height: 48,
                decoration: BoxDecoration(
                  color: raffle.isEntered ? AppColors.greenLight : allDone ? color : AppColors.inactive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    raffle.isEntered ? '✓ Entered' : allDone ? 'Enter Raffle' : 'Complete Tasks to Enter',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: raffle.isEntered ? AppColors.green : allDone ? Colors.white : AppColors.textTertiary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWinnersHistory(BuildContext context, RaffleModel raffle) {
    final winnersCount = (raffle.totalParticipants * 0.1).round().clamp(1, 10);
    final mockWinners = List.generate(winnersCount, (i) => _MockWinner(
      'User${1000 + i}',
      ['👑', '⭐', '🏆', '💎', '🎯', '✨', '🔥', '💪', '🚀', '🎉'][i % 10],
    ));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('${raffle.title} — Previous Winners', style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text('${mockWinners.length} winners (10% of participants)', style: AppTypography.bodySmall),
            const SizedBox(height: 16),
            ...mockWinners.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(w.avatar, style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Text(w.name, style: AppTypography.headlineSmall),
                  const Spacer(),
                  Text(Formatters.currency(raffle.prizeAmount / mockWinners.length), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.green)),
                ],
              ),
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _MockWinner {
  final String name;
  final String avatar;
  const _MockWinner(this.name, this.avatar);
}

class _MissionRow extends StatelessWidget {
  final MissionModel mission;
  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mission.completed ? AppColors.green : AppColors.surfaceSecondary,
            border: mission.completed ? null : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: mission.completed ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(width: 8),
        Text(mission.icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            mission.title,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: mission.completed ? AppColors.textTertiary : AppColors.textPrimary,
              decoration: mission.completed ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textTertiary,
            ),
          ),
        ),
        if (!mission.completed)
          GestureDetector(
            onTap: () => _handleMissionAction(context, mission),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Go', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  void _handleMissionAction(BuildContext context, MissionModel mission) {
    HapticFeedback.selectionClick();
    switch (mission.type) {
      case MissionType.exercise:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Go to Home and unlock apps with exercise!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ));
        final ref = ProviderScope.containerOf(context);
        ref.read(currentTabProvider.notifier).state = 0;
        break;
      case MissionType.watchAd:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Go to Home and unlock apps by watching an ad!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ));
        final ref = ProviderScope.containerOf(context);
        ref.read(currentTabProvider.notifier).state = 0;
        break;
      case MissionType.spinWheel:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpinWheelPage()));
        break;
      case MissionType.inviteFriend:
        final ref = ProviderScope.containerOf(context);
        ref.read(currentTabProvider.notifier).state = 3;
        break;
      case MissionType.completeTask:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksPage()));
        break;
    }
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
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
