import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';
import '../../models/cash_out_model.dart';

class CashOutHistoryScreen extends ConsumerWidget {
  const CashOutHistoryScreen({super.key});

  Color _statusColor(CashOutStatus status) {
    switch (status) {
      case CashOutStatus.pending:
        return AppColors.warning;
      case CashOutStatus.processing:
        return AppColors.accent;
      case CashOutStatus.completed:
        return AppColors.success;
      case CashOutStatus.failed:
        return AppColors.error;
    }
  }

  String _maskDestination(String method, String dest) {
    if (method == 'PayPal') {
      final parts = dest.split('@');
      if (parts.length == 2 && parts[0].length > 2) {
        return '${parts[0].substring(0, 2)}***@${parts[1]}';
      }
      return dest;
    }
    if (dest.length > 4) {
      return '**** **** **** ${dest.substring(dest.length - 4)}';
    }
    return dest;
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(cashOutRequestsProvider);

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
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Cash Out History', style: AppTypography.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('No requests yet', style: AppTypography.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    req.method == 'PayPal'
                                        ? Icons.account_balance_wallet_rounded
                                        : Icons.credit_card_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(req.method, style: AppTypography.headlineSmall),
                                      const SizedBox(height: 2),
                                      Text(
                                        _maskDestination(req.method, req.destination),
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${Formatters.number(req.pointsAmount)} pts',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(req.status).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        req.status.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(req.status),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(_formatDate(req.createdAt), style: AppTypography.caption),
                                  ],
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
