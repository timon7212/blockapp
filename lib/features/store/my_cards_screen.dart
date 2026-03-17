import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/gift_card_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(apiRedemptionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text('My Gift Cards',
                        style: AppTypography.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: historyAsync.when(
                  data: (cards) {
                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.credit_card_off_rounded,
                                size: 48,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('No redeemed cards yet',
                                style: AppTypography.bodyMedium),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cards.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return _CardItem(card: cards[i])
                            .animate()
                            .fadeIn(
                                duration: 300.ms,
                                delay: Duration(
                                    milliseconds: i * 50));
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
                              height: 120, borderRadius: 16),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Redemption history error: $e');
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text('Could not load cards',
                              style: AppTypography.bodyMedium),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => ref.invalidate(
                                apiRedemptionHistoryProvider),
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

class _CardItem extends StatelessWidget {
  final RedemptionHistoryDto card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_giftcard_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.productName,
                        style: AppTypography.headlineSmall),
                    Text(
                        '${Formatters.fiatValue(card.faceValue)} ${card.currency} Gift Card',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_timeAgo(card.redeemedAt),
                      style: AppTypography.caption),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(card.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      card.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(card.status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (card.redemptionLink != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      card.redemptionLink!,
                      style: AppTypography.number.copyWith(
                          fontSize: 13, letterSpacing: 0.5),
                      maxLines: 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: card.redemptionLink!));
                      HapticFeedback.mediumImpact();
                      AppToast.show(context,
                          message: 'Link copied!',
                          type: ToastType.success);
                    },
                    child: const Icon(Icons.copy_rounded,
                        size: 18, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.toll_rounded,
                  size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${Formatters.number(card.coinCost)} pts spent',
                  style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
