import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/wallet_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(apiTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: txAsync.when(
                  data: (txList) {
                    if (txList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                size: 40,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text('No transactions yet',
                                style: AppTypography.bodyMedium),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: txList.length,
                      itemBuilder: (context, i) {
                        final tx = txList[i];
                        final isPositive = tx.points > 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
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
                                    color: (isPositive
                                            ? AppColors.success
                                            : AppColors.error)
                                        .withValues(alpha: 0.08),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                      _txIcon(tx.type),
                                      size: 17,
                                      color: isPositive
                                          ? AppColors.success
                                          : AppColors.error),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.description,
                                          style: AppTypography
                                              .labelMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .textPrimary),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis),
                                      Text(
                                          _timeAgo(tx.timestamp),
                                          style:
                                              AppTypography.caption),
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
                          ).animate().fadeIn(
                              duration: 300.ms,
                              delay: Duration(
                                  milliseconds: 50 + i * 30)),
                        );
                      },
                    );
                  },
                  loading: () => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: List.generate(
                        6,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: ShimmerPlaceholder(
                              height: 60, borderRadius: 14),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 40, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text('Failed to load transactions',
                            style: AppTypography.bodyMedium),
                        const SizedBox(height: 4),
                        Text(e.toString(),
                            style: AppTypography.caption,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.invalidate(apiTransactionsProvider),
                          icon: const Icon(Icons.refresh_rounded,
                              size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _txIcon(TransactionTypeDto type) {
    switch (type) {
      case TransactionTypeDto.screenTime:
      case TransactionTypeDto.pointsCollected:
        return Icons.timer_rounded;
      case TransactionTypeDto.spinWheel:
        return Icons.casino_rounded;
      case TransactionTypeDto.task:
      case TransactionTypeDto.survey:
        return Icons.assignment_rounded;
      case TransactionTypeDto.referral:
        return Icons.people_rounded;
      case TransactionTypeDto.raffleWin:
        return Icons.emoji_events_rounded;
      case TransactionTypeDto.giftCardPurchase:
        return Icons.card_giftcard_rounded;
      case TransactionTypeDto.cashOut:
        return Icons.payments_rounded;
      case TransactionTypeDto.game:
        return Icons.sports_esports_rounded;
      case TransactionTypeDto.donation:
        return Icons.volunteer_activism_rounded;
      case TransactionTypeDto.welcomeBonus:
        return Icons.card_giftcard_rounded;
    }
  }

  static Widget _buildHeader(BuildContext context) {
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
          Text('Transaction History',
              style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
