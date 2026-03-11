import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../models/referral_level_model.dart';
import '../../models/wallet_model.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final levels = ref.watch(referralLevelsProvider);
    final pendingTotal = ref.watch(totalPendingReferralCoins);
    final totalEarned = levels.fold<int>(0, (sum, l) => sum + l.totalCollected);
    final totalUsers = levels.fold<int>(0, (s, l) => s + l.activeUsers);

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
                  Text('Network', style: AppTypography.displaySmall),
                  const Spacer(),
                  CoinBadge(amount: wallet.totalCoins),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.people_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('Invite friends.\nEarn from their activity.', textAlign: TextAlign.center, style: AppTypography.headlineMedium.copyWith(height: 1.3)),
                    const SizedBox(height: 8),
                    Text(
                      'Build your network up to 5 levels deep. When your referrals watch ads, you earn points from their activity.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatBox(value: '${user.directInvites}', label: 'Invites'),
                        const SizedBox(width: 10),
                        _StatBox(value: '$totalUsers', label: 'Users', isBold: true),
                        const SizedBox(width: 10),
                        _StatBox(value: '$totalEarned', label: 'Earned', isPoints: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Code', style: AppTypography.labelMedium),
                              const SizedBox(height: 2),
                              Text(user.referralCode, style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, letterSpacing: 2)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: user.referralCode));
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Copy', style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (pendingTotal > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: AppCard(
                  color: AppColors.coinLight,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$pendingTotal points pending! Watch an ad on each level to collect before midnight.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.coinDark, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Your Levels', style: AppTypography.headlineMedium),
            ),
            const SizedBox(height: 12),
            ...levels.map((level) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _LevelCard(level: level),
            )),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Top 10 Leaders', style: AppTypography.headlineMedium),
            ),
            const SizedBox(height: 12),
            const _TopLeadersSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isPoints;
  final bool isBold;
  const _StatBox({required this.value, required this.label, this.isPoints = false, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPoints ? AppColors.coinLight : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: isPoints ? AppColors.coin : AppColors.textPrimary,
                fontWeight: (isPoints || isBold) ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends ConsumerWidget {
  final ReferralLevelModel level;
  const _LevelCard({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: level.isUnlocked ? AppColors.surface : AppColors.surfaceSecondary,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: level.isUnlocked ? AppColors.primaryLight : AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('L${level.level}', style: AppTypography.headlineSmall.copyWith(color: level.isUnlocked ? AppColors.primary : AppColors.textTertiary, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Level ${level.level}',
                          style: AppTypography.headlineMedium.copyWith(color: level.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${level.activeUsers} Users',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: level.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (level.isUnlocked)
                      Row(
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                            child: const Center(child: Text('M', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${level.totalCollected} points earned',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.coin),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Need ${level.requiredInvites} invites to unlock',
                        style: AppTypography.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (level.isUnlocked && level.pendingCoins > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('📺 Watching ad to collect points...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 1),
                ));
                Future.delayed(const Duration(seconds: 1), () {
                  final coins = ref.read(referralLevelsProvider.notifier).collectLevel(level.level);
                  if (coins > 0) {
                    ref.read(walletProvider.notifier).addCoins(coins, 'Level ${level.level} referral', TransactionType.referral);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('+$coins points collected from Level ${level.level}!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
                  }
                });
              },
              child: Container(
                width: double.infinity, height: 44,
                decoration: BoxDecoration(color: AppColors.coin, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Collect ${level.pendingCoins} Points', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ] else if (!level.isUnlocked) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity, height: 40,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 6),
                  Text('Locked — invite ${level.requiredInvites} friends', style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopLeadersSection extends StatelessWidget {
  const _TopLeadersSection();

  static const _leaders = [
    _Leader('CryptoKing', '👑', 28450, 1230),
    _Leader('JaneFitness', '💪', 22100, 980),
    _Leader('MaxEarner', '🚀', 19800, 870),
    _Leader('BoostQueen', '⭐', 17650, 720),
    _Leader('InvitePro', '🎯', 15200, 650),
    _Leader('ActiveMike', '🏃', 12900, 540),
    _Leader('SocialStar', '✨', 11400, 480),
    _Leader('NetBuilder', '🔗', 9800, 410),
    _Leader('PointMaster', '🏆', 8500, 360),
    _Leader('AdWatcher', '📺', 7200, 290),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(_leaders.length, (i) {
            final leader = _leaders[i];
            final isTop3 = i < 3;
            return Padding(
              padding: EdgeInsets.only(bottom: i < _leaders.length - 1 ? 12 : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isTop3 ? AppColors.coin : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isTop3 ? AppColors.coinLight : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(leader.avatar, style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(leader.name, style: TextStyle(fontSize: 13, fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500, color: AppColors.textPrimary)),
                        Text('Today: ${leader.dailyPoints} pts', style: AppTypography.caption.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                        child: const Center(child: Text('M', style: TextStyle(fontSize: 6, fontWeight: FontWeight.w800, color: Colors.white))),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${leader.monthlyPoints}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.coin),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Leader {
  final String name;
  final String avatar;
  final int monthlyPoints;
  final int dailyPoints;
  const _Leader(this.name, this.avatar, this.monthlyPoints, this.dailyPoints);
}
