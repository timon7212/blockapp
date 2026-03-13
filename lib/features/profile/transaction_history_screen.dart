import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_model.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final ledger = wallet.ledger;

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
                child: ledger.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text('No transactions yet', style: AppTypography.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: ledger.length,
                        itemBuilder: (context, i) {
                          final tx = ledger[i];
                          final isPositive = tx.points > 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SurfaceCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              borderRadius: 14,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_txIcon(tx.type), size: 17, color: isPositive ? AppColors.success : AppColors.error),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tx.description, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(_timeAgo(tx.timestamp), style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isPositive ? '+' : ''}${Formatters.number(tx.points)}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPositive ? AppColors.success : AppColors.error),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 + i * 30)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _txIcon(TransactionType type) {
    switch (type) {
      case TransactionType.screenTimeClaim:
        return Icons.timer_rounded;
      case TransactionType.spinWheel:
        return Icons.casino_rounded;
      case TransactionType.offerwall:
        return Icons.assignment_rounded;
      case TransactionType.referral:
        return Icons.people_rounded;
      case TransactionType.rafflePrize:
        return Icons.emoji_events_rounded;
      case TransactionType.giftCardPurchase:
        return Icons.card_giftcard_rounded;
      case TransactionType.cashOut:
        return Icons.payments_rounded;
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
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Transaction History', style: AppTypography.headlineLarge),
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
