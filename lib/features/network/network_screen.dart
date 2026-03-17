import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../shared/providers/api_providers.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../data/dto/referral_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/glass_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../services/ad_service.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final walletAsync = ref.watch(apiWalletProvider);
    final referralAsync = ref.watch(apiReferralStatsProvider);
    final inviteesAsync = ref.watch(apiInviteesProvider);

    final referralCode =
        authState.user?.referralCode ?? '------';
    final totalPoints = walletAsync.valueOrNull?.totalPoints ?? 0;

    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    Text('Network', style: AppTypography.displaySmall),
                    const Spacer(),
                    CoinBadge(amount: totalPoints),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // ── Invite & Earn Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: referralAsync.when(
                  data: (stats) => _InviteCard(
                    referralCode: referralCode,
                    stats: stats,
                    totalPoints: totalPoints,
                  ),
                  loading: () =>
                      ShimmerPlaceholder(height: 300, borderRadius: 20),
                  error: (e, _) => _InviteCard(
                    referralCode: referralCode,
                    stats: null,
                    totalPoints: totalPoints,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.03, end: 0),
            ),

            // ── Pending Points Banner ──
            referralAsync.when(
              data: (stats) {
                if (stats.totalPending <= 0) {
                  return const SliverToBoxAdapter(
                      child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(14),
                      borderColor:
                          AppColors.success.withValues(alpha: 0.2),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.bolt_rounded,
                                color: AppColors.success, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${Formatters.number(stats.totalPending)} points pending! Watch an ad on each level to collect.',
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                );
              },
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Your Levels',
                    style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            // ── Level Cards ──
            referralAsync.when(
              data: (stats) => SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _ApiLevelCard(
                      level: 1,
                      label: 'Direct',
                      commissionPercent:
                          stats.childCommissionPercent,
                      activeUsers: stats.directInvites,
                      pendingPoints: stats.pendingChildPoints,
                      totalCollected: stats.totalCollected,
                      onCollect: () => _collectLevel(
                          context, ref, 'child'),
                    ).animate().fadeIn(
                        duration: 400.ms, delay: 300.ms),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _ApiLevelCard(
                      level: 2,
                      label: 'Indirect',
                      commissionPercent:
                          stats.grandChildCommissionPercent,
                      activeUsers: stats.grandChildInvites,
                      pendingPoints:
                          stats.pendingGrandChildPoints,
                      totalCollected: 0,
                      onCollect: () => _collectLevel(
                          context, ref, 'grandchild'),
                    ).animate().fadeIn(
                        duration: 400.ms, delay: 400.ms),
                  ),
                ]),
              ),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ShimmerPlaceholder(
                          height: 120, borderRadius: 16),
                      const SizedBox(height: 10),
                      ShimmerPlaceholder(
                          height: 120, borderRadius: 16),
                    ],
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 40, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text('Failed to load referral data',
                            style: AppTypography.bodyMedium),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            ref.invalidate(apiReferralStatsProvider);
                            ref.invalidate(apiInviteesProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Invitees ──
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Your Invitees',
                    style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            inviteesAsync.when(
              data: (invitees) {
                if (invitees.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 40,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text('No invitees yet',
                                style: AppTypography.bodyMedium),
                            Text('Share your code to start earning!',
                                style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final inv = invitees[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                            24, 0, 24, 6),
                        child: SurfaceCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    inv.displayName.isNotEmpty
                                        ? inv.displayName[0]
                                            .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(inv.displayName,
                                        style: AppTypography
                                            .labelMedium
                                            .copyWith(
                                                color: AppColors
                                                    .textPrimary)),
                                    Text(
                                      'L${inv.level == 'grandchild' ? '2' : '1'} · Joined ${_timeAgo(inv.joinedAt)}',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '+${Formatters.number(inv.pointsEarned)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                                duration: 300.ms,
                                delay: Duration(
                                    milliseconds: 450 + i * 50)),
                      );
                    },
                    childCount: invitees.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: ShimmerPlaceholder(
                            height: 56, borderRadius: 14),
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink()),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('How It Works',
                    style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: const [
                      _HowItWorksRow(
                          icon: Icons.person_rounded,
                          title: 'Level 1 — Direct',
                          desc:
                              'You earn 10% of what your direct referrals earn'),
                      SizedBox(height: 14),
                      _HowItWorksRow(
                          icon: Icons.group_rounded,
                          title: 'Level 2 — Indirect',
                          desc:
                              'You earn 5% of what their referrals earn'),
                      SizedBox(height: 14),
                      _HowItWorksRow(
                          icon: Icons.play_circle_outline_rounded,
                          title: 'Claim via Ad',
                          desc:
                              'Watch 1 ad per level to collect pending points'),
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

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  void _collectLevel(
      BuildContext context, WidgetRef ref, String level) async {
    HapticFeedback.heavyImpact();
    AppToast.show(context,
        message: 'Loading ad...', type: ToastType.info);
    await AdService.showRewardedAd(
      onRewarded: () async {
        try {
          final repo = ref.read(referralRepoProvider);
          final result = level == 'child'
              ? await repo.collectChildReferrals()
              : await repo.collectGrandchildReferrals();

          ref.invalidate(apiWalletProvider);
          ref.invalidate(apiReferralStatsProvider);
          ref.read(authNotifierProvider.notifier).refreshProfile();

          HapticFeedback.heavyImpact();
          if (context.mounted) {
            AppToast.show(context,
                message:
                    '+${Formatters.number(result.pointsCollected)} pts from Level ${level == 'child' ? '1' : '2'}!',
                type: ToastType.success);
          }
        } catch (e) {
          debugPrint('Collect referral failed: $e');
          if (context.mounted) {
            AppToast.show(context,
                message: 'Failed to collect: ${e.toString()}',
                type: ToastType.error);
          }
        }
      },
      onFailed: () {
        if (context.mounted) {
          AppToast.show(context,
              message: 'Ad failed to load. Try again.',
              type: ToastType.error);
        }
      },
    );
  }
}

class _InviteCard extends ConsumerWidget {
  final String referralCode;
  final ReferralStatsDto? stats;
  final int totalPoints;

  const _InviteCard({
    required this.referralCode,
    required this.stats,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
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
            child: const Icon(Icons.people_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Invite & Earn',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'Earn from 2 levels deep. Watch an ad to collect your network earnings.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatPill(
                  value: '${stats?.directInvites ?? 0}',
                  label: 'Invites'),
              const SizedBox(width: 8),
              _StatPill(
                  value:
                      '${(stats?.directInvites ?? 0) + (stats?.grandChildInvites ?? 0)}',
                  label: 'Network'),
              const SizedBox(width: 8),
              _StatPill(
                  value: Formatters.points(
                      stats?.totalCollected ?? 0),
                  label: 'Earned'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Code',
                        style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text(referralCode,
                        style: AppTypography.headlineLarge
                            .copyWith(letterSpacing: 2)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: referralCode));
                  HapticFeedback.mediumImpact();
                  AppToast.show(context,
                      message: 'Code copied!',
                      type: ToastType.success);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded,
                          size: 16,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('Copy',
                          style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Share.share(
                    'I earned ${Formatters.number(totalPoints)} points just by using my phone!\n\n'
                    'ManyBoost turns your screen time into real rewards — gift cards, cash & more.\n\n'
                    'Use my code: $referralCode\n'
                    'https://manyboost.io/ref/$referralCode',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.share_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Share',
                          style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
            Text(value,
                style: AppTypography.headlineSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

class _ApiLevelCard extends StatelessWidget {
  final int level;
  final String label;
  final double commissionPercent;
  final int activeUsers;
  final int pendingPoints;
  final int totalCollected;
  final VoidCallback onCollect;

  const _ApiLevelCard({
    required this.level,
    required this.label,
    required this.commissionPercent,
    required this.activeUsers,
    required this.pendingPoints,
    required this.totalCollected,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      borderColor: pendingPoints > 0
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.border,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  level == 1
                      ? Icons.person_rounded
                      : Icons.group_rounded,
                  color: AppColors.primary,
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
                        Text('Level $level',
                            style: AppTypography.headlineSmall),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(6)),
                          child: Text(
                              '${commissionPercent.toInt()}%',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$activeUsers $label referrals',
                        style: AppTypography.bodySmall),
                    if (totalCollected > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                          '${Formatters.number(totalCollected)} earned total',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (pendingPoints > 0) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onCollect,
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
                    const Icon(Icons.play_circle_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                        'Collect ${Formatters.number(pendingPoints)} pts',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
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
  const _HowItWorksRow(
      {required this.icon, required this.title, required this.desc});

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
