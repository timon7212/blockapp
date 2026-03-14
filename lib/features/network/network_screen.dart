import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/glass_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../models/referral_level_model.dart';
import '../../models/wallet_model.dart';
import '../../services/ad_service.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final levels = ref.watch(referralLevelsProvider);
    final pendingTotal = ref.watch(totalPendingReferralPoints);
    final totalEarned = levels.fold<int>(0, (sum, l) => sum + l.totalCollected);
    final totalUsers = levels.fold<int>(0, (s, l) => s + l.activeUsers);

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
                    Text('Network', style: AppTypography.displaySmall),
                    const Spacer(),
                    CoinBadge(amount: wallet.totalPoints),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.people_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(height: 16),
                      Text('Invite & Earn', style: AppTypography.headlineLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        'Earn from 2 levels deep. Watch an ad to collect your network earnings.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatPill(value: '${user.directInvites}', label: 'Invites'),
                          const SizedBox(width: 8),
                          _StatPill(value: '$totalUsers', label: 'Network'),
                          const SizedBox(width: 8),
                          _StatPill(value: Formatters.points(totalEarned), label: 'Earned'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Code', style: AppTypography.caption),
                                const SizedBox(height: 4),
                                Text(user.referralCode, style: AppTypography.headlineLarge.copyWith(letterSpacing: 2)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: user.referralCode));
                              HapticFeedback.mediumImpact();
                              AppToast.show(context, message: 'Code copied!', type: ToastType.success);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMid,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Text('Copy', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Share.share(
                                'I earned ${Formatters.number(wallet.totalPoints)} points just by using my phone! 🤯\n\n'
                                'DoomScroll turns your screen time into real rewards — gift cards, cash & more.\n\n'
                                'Use my code: ${user.referralCode}\n'
                                'https://doomscroll.app/ref/${user.referralCode}',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Share', style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.03, end: 0),
            ),

            if (pendingTotal > 0) ...[
              SliverToBoxAdapter(child: const SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppColors.success.withValues(alpha: 0.2),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${Formatters.number(pendingTotal)} points pending! Watch an ad on each level to collect.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),
            ],

            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Your Levels', style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            if (levels.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text('No referral levels yet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _LevelCard(level: levels[i])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 300 + i * 100)),
                  ),
                  childCount: levels.length,
                ),
              ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('How It Works', style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _HowItWorksRow(icon: Icons.person_rounded, title: 'Level 1 — Direct', desc: 'You earn 10% of what your direct referrals earn'),
                      const SizedBox(height: 14),
                      _HowItWorksRow(icon: Icons.group_rounded, title: 'Level 2 — Indirect', desc: 'You earn 5% of what their referrals earn'),
                      const SizedBox(height: 14),
                      _HowItWorksRow(icon: Icons.play_circle_outline_rounded, title: 'Claim via Ad', desc: 'Watch 1 ad per level to collect pending points'),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption),
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
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      borderColor: level.pendingPoints > 0 ? AppColors.success.withValues(alpha: 0.2) : AppColors.border,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: level.isUnlocked ? 0.1 : 0.04),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  level.level == 1 ? Icons.person_rounded : Icons.group_rounded,
                  color: level.isUnlocked ? AppColors.primary : AppColors.textTertiary,
                  size: 20,
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
                          style: AppTypography.headlineSmall.copyWith(color: level.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('${level.commissionPercent.toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${level.activeUsers} ${level.level == 1 ? 'direct' : 'indirect'} referrals',
                      style: AppTypography.bodySmall,
                    ),
                    if (level.isUnlocked) ...[
                      const SizedBox(height: 2),
                      Text('${Formatters.number(level.totalCollected)} earned total', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (level.isUnlocked && level.pendingPoints > 0) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                HapticFeedback.heavyImpact();
                AppToast.show(context, message: 'Loading ad...', type: ToastType.info);
                await AdService.showRewardedAd(
                  onRewarded: () {
                    final pts = ref.read(referralLevelsProvider.notifier).collectLevel(level.level);
                    if (pts > 0) {
                      ref.read(walletProvider.notifier).addPoints(pts, 'Level ${level.level} referral', TransactionType.referral);
                      HapticFeedback.heavyImpact();
                      if (context.mounted) {
                        AppToast.show(context, message: '+${Formatters.number(pts)} points from Level ${level.level}!', type: ToastType.success);
                      }
                    }
                  },
                  onFailed: () {
                    if (context.mounted) AppToast.show(context, message: 'Ad failed to load. Try again.', type: ToastType.error);
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Collect ${Formatters.number(level.pendingPoints)} pts', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ] else if (!level.isUnlocked) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(color: AppColors.surfaceMid, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 6),
                  Text('Invite ${level.requiredInvites} friends to unlock', style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _HowItWorksRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineSmall),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
