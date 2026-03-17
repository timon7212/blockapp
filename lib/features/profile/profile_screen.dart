import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../data/dto/wallet_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';
import '../../design_system/utils/app_page_route.dart';
import '../settings/notifications_screen.dart';
import '../settings/help_screen.dart';
import '../settings/about_screen.dart';
import 'edit_profile_screen.dart';
import 'transaction_history_screen.dart';
import '../store/my_cards_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final walletAsync = ref.watch(apiWalletProvider);
    final streakAsync = ref.watch(apiStreakProvider);
    final transactionsAsync = ref.watch(apiTransactionsProvider);

    final displayName = authState.user?.displayName ?? 'User';
    final username = authState.user?.email?.split('@').first ?? 'user';
    final joinedAt = authState.user?.joinedAt;

    return GradientBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child:
                    Text('Profile', style: AppTypography.displaySmall),
              ).animate().fadeIn(duration: 400.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ── Avatar & Name ──
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: AppTypography.displayLarge.copyWith(
                            color: AppColors.primary, fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(displayName,
                      style: AppTypography.headlineLarge),
                  const SizedBox(height: 4),
                  Text('@$username',
                      style: AppTypography.bodyMedium),
                  if (joinedAt != null) ...[
                    const SizedBox(height: 4),
                    Text('Member since ${_formatDate(joinedAt)}',
                        style: AppTypography.caption),
                  ],
                ],
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ── Stats Row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _ProfileStat(
                      label: 'Balance',
                      value: walletAsync.when(
                        data: (w) => Formatters.points(w.totalPoints),
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      icon: Icons.trending_up_rounded,
                    ),
                    const SizedBox(width: 10),
                    _ProfileStat(
                      label: 'Streak',
                      value: streakAsync.when(
                        data: (s) => '${s.currentStreak}d',
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      icon: Icons.local_fire_department_rounded,
                    ),
                    const SizedBox(width: 10),
                    _ProfileStat(
                      label: 'Multiplier',
                      value: streakAsync.when(
                        data: (s) => '${s.multiplier}x',
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      icon: Icons.bolt_rounded,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),

            // ── Streak Multiplier Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: streakAsync.when(
                  data: (streak) =>
                      _StreakMultiplierCard(streak: streak),
                  loading: () =>
                      ShimmerPlaceholder(height: 100, borderRadius: 16),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ── My Cards ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                        AppPageRoute(page: const MyCardsScreen()));
                  },
                  child: SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.credit_card_rounded,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 12),
                        Text('My Gift Cards',
                            style: AppTypography.headlineSmall),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textTertiary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),

            // ── Recent Activity ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Recent Activity',
                        style: AppTypography.headlineMedium),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(AppPageRoute(
                            page: const TransactionHistoryScreen()));
                      },
                      child: Text('View All',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            // ── Transactions ──
            transactionsAsync.when(
              data: (txList) {
                if (txList.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                size: 40,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text('No activity yet',
                                style: AppTypography.bodyMedium),
                            Text(
                                'Start earning to see your history',
                                style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final tx = txList[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                            24, 0, 24, 6),
                        child: _ApiTransactionRow(tx: tx)
                            .animate()
                            .fadeIn(
                                duration: 300.ms,
                                delay: Duration(
                                    milliseconds: 350 + i * 50)),
                      );
                    },
                    childCount: txList.length.clamp(0, 5),
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
                            height: 60, borderRadius: 14),
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 40, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text('Could not load activity',
                            style: AppTypography.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ── Settings ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Settings',
                    style: AppTypography.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                                page: const EditProfileScreen())),
                      ),
                      Divider(
                          height: 1,
                          color: AppColors.border,
                          indent: 52),
                      _SettingTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => Navigator.of(context).push(
                            AppPageRoute(
                                page: const NotificationsScreen())),
                      ),
                      Divider(
                          height: 1,
                          color: AppColors.border,
                          indent: 52),
                      _SettingTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () => Navigator.of(context).push(
                            AppPageRoute(page: const HelpScreen())),
                      ),
                      Divider(
                          height: 1,
                          color: AppColors.border,
                          indent: 52),
                      _SettingTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        onTap: () => Navigator.of(context).push(
                            AppPageRoute(page: const AboutScreen())),
                      ),
                      Divider(
                          height: 1,
                          color: AppColors.border,
                          indent: 52),
                      _SettingTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        color: AppColors.error,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              title: const Text('Sign Out'),
                              content: const Text(
                                  'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref
                                        .read(authNotifierProvider
                                            .notifier)
                                        .logout();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(
                child: Center(
                    child: Text('v2.1.0',
                        style: AppTypography.caption))),
            SliverToBoxAdapter(child: const SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ─── Streak Multiplier Card (uses StreakDto) ───
class _StreakMultiplierCard extends StatelessWidget {
  final dynamic streak; // StreakDto
  const _StreakMultiplierCard({required this.streak});

  static const _tiers = [
    (days: 0, label: '1x', multiplier: 1.0),
    (days: 3, label: '1.1x', multiplier: 1.1),
    (days: 7, label: '1.2x', multiplier: 1.2),
    (days: 14, label: '1.3x', multiplier: 1.3),
    (days: 30, label: '1.5x', multiplier: 1.5),
  ];

  @override
  Widget build(BuildContext context) {
    final currentMultiplier = (streak.multiplier as num).toDouble();
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Text('Streak Multiplier',
                  style: AppTypography.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${currentMultiplier}x',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _tiers.map((tier) {
              final isActive = currentMultiplier >= tier.multiplier;
              final isCurrent =
                  currentMultiplier == tier.multiplier;
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.accent
                              .withValues(alpha: 0.15)
                          : isActive
                              ? AppColors.success
                                  .withValues(alpha: 0.1)
                              : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.accent
                                .withValues(alpha: 0.4)
                            : isActive
                                ? AppColors.success
                                    .withValues(alpha: 0.2)
                                : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tier.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? AppColors.accent
                              : isActive
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tier.days == 0 ? 'Start' : '${tier.days}d',
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrent
                          ? AppColors.accent
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProfileStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        borderRadius: 16,
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: 8),
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

// ─── API Transaction Row ──
class _ApiTransactionRow extends StatelessWidget {
  final TransactionDto tx;
  const _ApiTransactionRow({required this.tx});

  IconData get _icon {
    final t = tx.type.value;
    if (t.contains('screen_time') || t.contains('points_collected')) {
      return Icons.timer_rounded;
    }
    if (t.contains('spin')) return Icons.casino_rounded;
    if (t.contains('referral')) return Icons.people_rounded;
    if (t.contains('raffle')) return Icons.emoji_events_rounded;
    if (t.contains('gift')) return Icons.card_giftcard_rounded;
    if (t.contains('cash')) return Icons.payments_rounded;
    return Icons.toll_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.points > 0;
    return SurfaceCard(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon,
                size: 17,
                color: isPositive
                    ? AppColors.success
                    : AppColors.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description,
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(_timeAgo(tx.timestamp),
                    style: AppTypography.caption),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${Formatters.number(tx.points)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPositive
                    ? AppColors.success
                    : AppColors.error),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SettingTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Text(label,
                style: AppTypography.bodyLarge.copyWith(
                    color: color ?? AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
