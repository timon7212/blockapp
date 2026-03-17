import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/cashout_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';

class CashOutHistoryScreen extends ConsumerWidget {
  const CashOutHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.accent;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(apiCashOutHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
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
                    Text('Cash Out History',
                        style: AppTypography.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: historyAsync.when(
                  data: (requests) {
                    if (requests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 48,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('No requests yet',
                                style: AppTypography.bodyMedium),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(24, 4, 24, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final req = requests[i];
                        return SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  req.paymentMethod == 'paypal'
                                      ? Icons
                                          .account_balance_wallet_rounded
                                      : Icons.credit_card_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        req.paymentMethod == 'paypal'
                                            ? 'PayPal'
                                            : 'Bank Card',
                                        style: AppTypography
                                            .headlineSmall),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${req.cashValue.toStringAsFixed(2)}',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${Formatters.number(req.coinAmount)} pts',
                                    style: AppTypography.labelMedium
                                        .copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(req.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      req.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _statusColor(req.status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                      _formatDate(req.requestedAt),
                                      style: AppTypography.caption),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ShimmerPlaceholder(
                              height: 80, borderRadius: 16),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Cash out history error: $e');
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text('Could not load history',
                              style: AppTypography.bodyMedium),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => ref.invalidate(
                                apiCashOutHistoryProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text('Retry',
                                  style: AppTypography.labelMedium
                                      .copyWith(
                                          color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ),
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
}
