import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../unlock/unlock_modal.dart';
import '../earn/spin_wheel_page.dart';
import '../earn/tasks_page.dart';
import '../earn/games_page.dart';
import '../earn/surveys_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final blockedCount = ref.watch(activeBlockedAppsCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _TopBar(coins: wallet.totalCoins),
              const SizedBox(height: 24),
              _BlockStatusCard(blockedApps: blockedCount),
              const SizedBox(height: 24),
              const _MoreWaysToEarn(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int coins;
  const _TopBar({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('ManyBoost', style: AppTypography.displaySmall),
          const Spacer(),
          CoinBadge(amount: coins, fontSize: 16),
        ],
      ),
    );
  }
}

class _BlockStatusCard extends ConsumerStatefulWidget {
  final int blockedApps;
  const _BlockStatusCard({required this.blockedApps});

  @override
  ConsumerState<_BlockStatusCard> createState() => _BlockStatusCardState();
}

class _BlockStatusCardState extends ConsumerState<_BlockStatusCard> {
  bool _unlocked = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  void _startUnlockTimer() {
    setState(() {
      _unlocked = true;
      _remainingSeconds = 15 * 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() { _unlocked = false; _remainingSeconds = 0; });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _unlocked ? AppColors.greenLight : AppColors.redLight, shape: BoxShape.circle),
              child: Icon(_unlocked ? Icons.lock_open_rounded : Icons.lock_rounded, size: 32, color: _unlocked ? AppColors.green : AppColors.red),
            ),
            const SizedBox(height: 16),
            if (_unlocked) ...[
              Text('Apps Unlocked', style: AppTypography.headlineLarge.copyWith(color: AppColors.green)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(14)),
                child: Text(_formattedTime, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()], color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 6),
              Text('remaining', style: AppTypography.bodySmall),
            ] else ...[
              Text('Apps Blocked', style: AppTypography.headlineLarge.copyWith(color: AppColors.red)),
              const SizedBox(height: 4),
              Text('${widget.blockedApps} apps are currently blocked', style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _unlocked ? null : () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => UnlockModal(onUnlocked: _startUnlockTimer));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  color: _unlocked ? AppColors.inactive : AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _unlocked ? null : [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_unlocked ? Icons.lock_clock_rounded : Icons.lock_open_rounded, color: _unlocked ? AppColors.textTertiary : Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(_unlocked ? 'Unlocked' : 'Unlock Apps', style: AppTypography.button.copyWith(fontSize: 16, color: _unlocked ? AppColors.textTertiary : Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EarnAction { spinWheel, tasks, games, surveys, inviteFriends }

class _MoreWaysToEarn extends StatelessWidget {
  const _MoreWaysToEarn();

  static const _items = [
    _EarnWayItem('🎰', 'Spin Wheel', AppColors.purple, _EarnAction.spinWheel, 500),
    _EarnWayItem('📋', 'Tasks', AppColors.primary, _EarnAction.tasks, 750),
    _EarnWayItem('🎮', 'Games', AppColors.green, _EarnAction.games, 4850),
    _EarnWayItem('📊', 'Surveys', AppColors.orange, _EarnAction.surveys, 200),
    _EarnWayItem('👥', 'Invite Friends', AppColors.teal, _EarnAction.inviteFriends, 10000),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('More ways to earn', style: AppTypography.headlineMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final item = _items[i];
              return _EarnWayCard(item: item, onTap: () {
                HapticFeedback.selectionClick();
                switch (item.action) {
                  case _EarnAction.spinWheel:
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpinWheelPage()));
                    break;
                  case _EarnAction.tasks:
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksPage()));
                    break;
                  case _EarnAction.games:
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GamesPage()));
                    break;
                  case _EarnAction.surveys:
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurveysPage()));
                    break;
                  case _EarnAction.inviteFriends:
                    final ref = ProviderScope.containerOf(context);
                    ref.read(currentTabProvider.notifier).state = 3;
                    break;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

class _EarnWayItem {
  final String emoji;
  final String title;
  final Color color;
  final _EarnAction action;
  final int maxCoins;
  const _EarnWayItem(this.emoji, this.title, this.color, this.action, this.maxCoins);
}

class _EarnWayCard extends StatelessWidget {
  final _EarnWayItem item;
  final VoidCallback onTap;
  const _EarnWayCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 8),
            Text(item.title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('up to ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.coin)),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                ),
                const SizedBox(width: 2),
                Text('${item.maxCoins}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.coin)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
