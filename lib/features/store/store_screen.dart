import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/glass_card.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/gift_card_model.dart';
import '../../models/wallet_model.dart';
import '../../models/redeemed_card_model.dart';
import '../../models/cash_out_model.dart';
import '../../design_system/utils/app_page_route.dart';
import '../../design_system/utils/app_bottom_sheet.dart';
import 'my_cards_screen.dart';
import 'cash_out_history_screen.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _tab = 0;
  bool _loading = true;
  final _tabs = ['Store', 'Gift Cards', 'Cash Out'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('Store', style: AppTypography.displaySmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.toll_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Balance ${Formatters.number(wallet.totalPoints)}',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _SegmentedControl(
              tabs: _tabs,
              selected: _tab,
              onTap: (i) {
                HapticFeedback.selectionClick();
                setState(() => _tab = i);
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 16),
            if (_loading)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ShimmerCardList(count: 4, itemHeight: 80),
                ),
              )
            else
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: const [
                    _PartnerOffersTab(),
                    _GiftCardsTab(),
                    _CashOutTab(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Partner Offers Tab ───

class _PartnerOffersTab extends ConsumerWidget {
  const _PartnerOffersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(partnerOffersProvider);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final o = offers[i];
        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          onTap: () {
            HapticFeedback.selectionClick();
            _showPartnerDetail(context, o);
          },
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(o.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.brand, style: AppTypography.headlineSmall),
                    const SizedBox(height: 3),
                    Text(o.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${o.discountPercent.toInt()}% off',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${Formatters.number(o.pointsCost)} pts', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.02, end: 0);
      },
    );
  }

  void _showPartnerDetail(BuildContext context, dynamic o) {
    showAppBottomSheet(
      context,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 28),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(o.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(o.brand, style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(o.description, style: AppTypography.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discount', style: AppTypography.caption),
                      Text('${o.discountPercent.toInt()}% off', style: AppTypography.headlineMedium.copyWith(color: AppColors.success)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Unlock cost', style: AppTypography.caption),
                      Text('${Formatters.number(o.pointsCost)} pts', style: AppTypography.headlineMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Get Deal',
              gradient: AppColors.primaryGradient,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                AppToast.show(context, message: 'Deal activated! Check your email.', type: ToastType.success);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segmented Control ───

class _SegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;
  const _SegmentedControl({required this.tabs, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = selected == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: active ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppColors.textPrimary : AppColors.textTertiary),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Gift Cards Tab ───

class _GiftCardsTab extends ConsumerWidget {
  const _GiftCardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final giftCards = ref.watch(giftCardsProvider);
    final wallet = ref.watch(walletProvider);
    final redeemed = ref.watch(redeemedCardsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (redeemed.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(AppPageRoute(page: const MyCardsScreen()));
                },
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card_rounded, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Text('My Cards', style: AppTypography.headlineSmall),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${redeemed.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final gc = giftCards[i];
                final canAfford = wallet.totalPoints >= gc.pointsCost;
                return _GiftCardItem(
                  card: gc,
                  canAfford: canAfford,
                  onRedeem: () => _redeemGiftCard(context, ref, gc),
                ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * i));
              },
              childCount: giftCards.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
          ),
        ),
      ],
    );
  }

  void _redeemGiftCard(BuildContext context, WidgetRef ref, GiftCardModel gc) {
    HapticFeedback.mediumImpact();
    final wallet = ref.read(walletProvider);
    if (wallet.totalPoints < gc.pointsCost) {
      AppToast.show(context, message: 'Need ${Formatters.number(gc.pointsCost - wallet.totalPoints)} more points', type: ToastType.error);
      return;
    }
    showAppBottomSheet(
      context,
      isScrollControlled: true,
      builder: (_) => _RedeemConfirmSheet(gc: gc),
    );
  }
}

// ─── Gift Card Item (aesthetic, centered) ───

class _GiftCardItem extends StatelessWidget {
  final GiftCardModel card;
  final bool canAfford;
  final VoidCallback onRedeem;
  const _GiftCardItem({required this.card, required this.canAfford, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      onTap: canAfford ? onRedeem : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            ),
            child: Icon(card.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            card.brand,
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${Formatters.fiatValue(card.faceValue)} Gift Card',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.toll_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${Formatters.number(card.pointsCost)} pts',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              gradient: canAfford ? AppColors.primaryGradient : null,
              color: canAfford ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                canAfford ? 'Redeem' : 'Not enough pts',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: canAfford ? Colors.white : AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Redeem Confirm Sheet ───

class _RedeemConfirmSheet extends ConsumerWidget {
  final GiftCardModel gc;
  const _RedeemConfirmSheet({required this.gc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(gc.icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Redeem ${gc.brand}?', style: AppTypography.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('${Formatters.fiatValue(gc.faceValue)} Gift Card', style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.toll_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text('${Formatters.number(gc.pointsCost)} pts', style: AppTypography.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Confirm Redeem',
            gradient: AppColors.successGradient,
            onPressed: () {
              Navigator.pop(context);
              final code = _generateCode();
              ref.read(walletProvider.notifier).spendPoints(gc.pointsCost, '${gc.brand} gift card', TransactionType.giftCardPurchase);
              ref.read(redeemedCardsProvider.notifier).add(RedeemedCardModel(
                id: 'rc_${DateTime.now().millisecondsSinceEpoch}',
                brand: gc.brand,
                icon: gc.icon,
                code: code,
                pointsSpent: gc.pointsCost,
                faceValue: gc.faceValue,
                redeemedAt: DateTime.now(),
              ));
              HapticFeedback.heavyImpact();
              _showRedeemSuccess(context, gc, code);
            },
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeemSuccess(BuildContext context, GiftCardModel gc, String code) {
    showAppBottomSheet(
      context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => _RedeemSuccessSheet(gc: gc, code: code),
    );
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final segments = List.generate(4, (_) => List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join());
    return segments.join('-');
  }
}

// ─── Redeem Success Sheet ───

class _RedeemSuccessSheet extends StatelessWidget {
  final GiftCardModel gc;
  final String code;
  const _RedeemSuccessSheet({required this.gc, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Card Redeemed!', style: AppTypography.headlineLarge),
          const SizedBox(height: 4),
          Text('${gc.brand} ${Formatters.fiatValue(gc.faceValue)} Gift Card', style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.success.withValues(alpha: 0.2),
            child: Column(
              children: [
                Text('Your Gift Card Code', style: AppTypography.labelMedium),
                const SizedBox(height: 12),
                SelectableText(code, style: AppTypography.number.copyWith(fontSize: 20, letterSpacing: 2, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    HapticFeedback.mediumImpact();
                    AppToast.show(context, message: 'Code copied!', type: ToastType.success);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text('Copy Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to use', style: AppTypography.labelLarge),
                const SizedBox(height: 10),
                _HowToStep(num: '1', text: 'Copy the code above'),
                const SizedBox(height: 6),
                _HowToStep(num: '2', text: 'Go to ${gc.brand} website or app'),
                const SizedBox(height: 6),
                _HowToStep(num: '3', text: 'Apply the code at checkout or in "Redeem Gift Card" section'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _HowToStep extends StatelessWidget {
  final String num;
  final String text;
  const _HowToStep({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Text(num, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))),
      ],
    );
  }
}

// ─── Cash Out Tab ───

class _CashOutTab extends ConsumerWidget {
  const _CashOutTab();

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
    final wallet = ref.watch(walletProvider);
    final requests = ref.watch(cashOutRequestsProvider);
    final canCashOut = wallet.totalPoints >= EconomyConstants.cashOutMinBalance;
    final progressToGoal = (wallet.totalPoints / EconomyConstants.cashOutMinBalance).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Text('Your Balance', style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                Text(Formatters.number(wallet.totalPoints), style: AppTypography.number.copyWith(fontSize: 36)),
                Text('points', style: AppTypography.caption),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cash out goal', style: AppTypography.caption),
                        Text('${Formatters.number(wallet.totalPoints)} / ${Formatters.number(EconomyConstants.cashOutMinBalance)}', style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressToGoal,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: canCashOut ? AppColors.successGradient : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!canCashOut) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${Formatters.number(EconomyConstants.cashOutMinBalance - wallet.totalPoints)} more points to unlock',
                        style: AppTypography.caption.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Withdrawal Methods', style: AppTypography.headlineMedium),
          const SizedBox(height: 12),
          _CashOutMethod(
            icon: Icons.account_balance_wallet_rounded,
            title: 'PayPal',
            subtitle: 'Instant transfer to your PayPal',
            minAmount: '${Formatters.number(EconomyConstants.cashOutMinBalance)} pts',
            enabled: canCashOut,
            onTap: () => _showCashOutFlow(context, 'PayPal'),
          ),
          const SizedBox(height: 10),
          _CashOutMethod(
            icon: Icons.credit_card_rounded,
            title: 'Bank Card',
            subtitle: 'Direct transfer, 1-3 business days',
            minAmount: '${Formatters.number(EconomyConstants.cashOutMinBalance)} pts',
            enabled: canCashOut,
            onTap: () => _showCashOutFlow(context, 'Bank Card'),
          ),
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Requests', style: AppTypography.headlineMedium),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      AppPageRoute(page: const CashOutHistoryScreen()),
                    );
                  },
                  child: Text('View All', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...requests.take(3).map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        req.method == 'PayPal' ? Icons.account_balance_wallet_rounded : Icons.credit_card_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor(req.status)),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(_formatDate(req.createdAt), style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _showCashOutFlow(BuildContext context, String method) {
    HapticFeedback.mediumImpact();
    showAppBottomSheet(
      context,
      isScrollControlled: true,
      builder: (_) => _CashOutSheet(method: method),
    );
  }
}

class _CashOutSheet extends ConsumerStatefulWidget {
  final String method;
  const _CashOutSheet({required this.method});

  @override
  ConsumerState<_CashOutSheet> createState() => _CashOutSheetState();
}

class _CashOutSheetState extends ConsumerState<_CashOutSheet> {
  final _destController = TextEditingController();
  int? _selectedAmount;
  static const _presetAmounts = [5000, 10000, 25000, 50000];

  bool get _isDestValid {
    final text = _destController.text.trim();
    if (text.isEmpty) return false;
    if (widget.method == 'PayPal') {
      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    }
    return text.replaceAll(' ', '').length >= 13;
  }

  bool get _canSubmit {
    if (!_isDestValid) return false;
    if (_selectedAmount == null) return false;
    final wallet = ref.read(walletProvider);
    return wallet.totalPoints >= _selectedAmount!;
  }

  @override
  void initState() {
    super.initState();
    _destController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    final amount = _selectedAmount!;
    final dest = _destController.text.trim();

    ref.read(cashOutRequestsProvider.notifier).add(CashOutRequest(
      id: 'co_${DateTime.now().millisecondsSinceEpoch}',
      method: widget.method,
      destination: dest,
      pointsAmount: amount,
      createdAt: DateTime.now(),
    ));
    ref.read(walletProvider.notifier).spendPoints(
      amount,
      '${widget.method} cash out',
      TransactionType.cashOut,
    );

    Navigator.pop(context);
    HapticFeedback.heavyImpact();
    AppToast.show(context, message: 'Cash out request submitted! Processing in 1-3 days.', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Text('Cash Out via ${widget.method}', style: AppTypography.headlineLarge),
          const SizedBox(height: 20),
          Text(widget.method == 'PayPal' ? 'PayPal email' : 'Card number', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _destController,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
            keyboardType: widget.method == 'PayPal' ? TextInputType.emailAddress : TextInputType.number,
            decoration: InputDecoration(
              hintText: widget.method == 'PayPal' ? 'your@email.com' : '4242 **** **** ****',
              hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceMid,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (_destController.text.isNotEmpty && !_isDestValid) ...[
            const SizedBox(height: 6),
            Text(
              widget.method == 'PayPal' ? 'Enter a valid email address' : 'Card number must be at least 13 digits',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 20),
          Text('Amount', style: AppTypography.labelMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetAmounts.map((amount) {
              final selected = _selectedAmount == amount;
              final affordable = wallet.totalPoints >= amount;
              return GestureDetector(
                onTap: affordable ? () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAmount = amount);
                } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${Formatters.number(amount)} pts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !affordable
                          ? AppColors.textTertiary
                          : selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedAmount != null && wallet.totalPoints < _selectedAmount!) ...[
            const SizedBox(height: 6),
            Text(
              'Not enough points',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Submit Request',
            gradient: AppColors.primaryGradient,
            enabled: _canSubmit,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CashOutMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String minAmount;
  final bool enabled;
  final VoidCallback onTap;

  const _CashOutMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.minAmount,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: enabled ? AppColors.border : AppColors.borderLight,
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (enabled ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: enabled ? AppColors.primary : AppColors.textTertiary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall.copyWith(color: enabled ? AppColors.textPrimary : AppColors.textTertiary)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Min: $minAmount', style: AppTypography.caption),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
            color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
