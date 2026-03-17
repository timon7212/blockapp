import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/gift_card_dto.dart';
import '../../data/dto/cashout_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/glass_card.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/economy_constants.dart';
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
  final _tabs = ['Store', 'Gift Cards', 'Cash Out'];

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(apiWalletProvider);
    final balance = walletAsync.valueOrNull?.totalPoints ?? 0;

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.toll_rounded,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        walletAsync.when(
                          data: (w) => Text(
                            'Balance ${Formatters.number(w.totalPoints)}',
                            style: AppTypography.labelMedium
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          loading: () => SizedBox(
                            width: 60,
                            height: 14,
                            child: ShimmerPlaceholder(
                                height: 14, borderRadius: 4),
                          ),
                          error: (_, __) => Text(
                            'Balance --',
                            style: AppTypography.labelMedium
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
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

// ─── Partner Offers Tab (no API yet — coming soon placeholder) ───

class _PartnerOffersTab extends StatelessWidget {
  const _PartnerOffersTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_outlined,
                  size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text('Partner Offers Coming Soon',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Exclusive discounts from our partners will appear here. Stay tuned!',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
  const _SegmentedControl(
      {required this.tabs, required this.selected, required this.onTap});

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
                    color:
                        active ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: active
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textTertiary),
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

// ─── Gift Cards Tab (API-only) ───

class _GiftCardsTab extends ConsumerWidget {
  const _GiftCardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiGiftCardsAsync = ref.watch(apiGiftCardsProvider);
    final walletAsync = ref.watch(apiWalletProvider);
    final balance = walletAsync.valueOrNull?.totalPoints ?? 0;

    return apiGiftCardsAsync.when(
      data: (apiCards) {
        if (apiCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard_outlined,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('No gift cards available',
                    style: AppTypography.bodyMedium),
                const SizedBox(height: 6),
                Text('Check back soon', style: AppTypography.caption),
              ],
            ),
          );
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final gc = apiCards[i];
                    final cost = gc.coinCost ?? 0;
                    final canAfford = balance >= cost;
                    return _ApiGiftCardItem(
                      card: gc,
                      canAfford: canAfford,
                      onRedeem: () {
                        HapticFeedback.mediumImpact();
                        if (!canAfford) {
                          AppToast.show(context,
                              message:
                                  'Need ${Formatters.number(cost - balance)} more points',
                              type: ToastType.error);
                          return;
                        }
                        showAppBottomSheet(
                          context,
                          isScrollControlled: true,
                          builder: (_) => _ApiRedeemConfirmSheet(
                              gc: gc, balance: balance),
                        );
                      },
                    ).animate().fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: 50 * i));
                  },
                  childCount: apiCards.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ShimmerCardList(count: 4, itemHeight: 160),
      ),
      error: (e, st) {
        debugPrint('Gift cards API error: $e');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load gift cards',
                  style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => ref.invalidate(apiGiftCardsProvider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Retry',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── API Gift Card Item ───

class _ApiGiftCardItem extends StatelessWidget {
  final GiftCardDto card;
  final bool canAfford;
  final VoidCallback onRedeem;
  const _ApiGiftCardItem(
      {required this.card,
      required this.canAfford,
      required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final cost = card.coinCost ?? 0;
    final minValue = card.skus.isNotEmpty ? card.skus.first.min : 0.0;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      onTap: canAfford ? onRedeem : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (card.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                card.imageUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.card_giftcard_rounded,
                      color: AppColors.primary, size: 26),
                ),
              ),
            )
          else
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12)),
              ),
              child: Icon(Icons.card_giftcard_rounded,
                  color: AppColors.primary, size: 26),
            ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              card.name,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            minValue > 0
                ? '\$${minValue.toStringAsFixed(0)}+ Gift Card'
                : 'Gift Card',
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (cost > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.toll_rounded,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${Formatters.number(cost)} pts',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
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
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: canAfford
                        ? Colors.white
                        : AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── API Redeem Confirm Sheet ───

class _ApiRedeemConfirmSheet extends ConsumerWidget {
  final GiftCardDto gc;
  final int balance;
  const _ApiRedeemConfirmSheet(
      {required this.gc, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cost = gc.coinCost ?? 0;
    final minValue = gc.skus.isNotEmpty ? gc.skus.first.min : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: gc.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(gc.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.card_giftcard_rounded,
                            color: AppColors.primary,
                            size: 28)),
                  )
                : Icon(Icons.card_giftcard_rounded,
                    color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Redeem ${gc.name}?',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (minValue > 0)
            Text('\$${minValue.toStringAsFixed(0)} Gift Card',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center),
          const SizedBox(height: 12),
          if (cost > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.toll_rounded,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text('${Formatters.number(cost)} pts',
                      style: AppTypography.headlineSmall),
                ],
              ),
            ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Confirm Redeem',
            gradient: AppColors.successGradient,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(storeRepoProvider)
                    .redeemGiftCard(RedeemGiftCardRequest(
                      productId: gc.id,
                      amount: minValue,
                    ));
                ref.invalidate(apiWalletProvider);
                ref.invalidate(apiGiftCardsProvider);
                HapticFeedback.heavyImpact();
                if (context.mounted) {
                  AppToast.show(context,
                      message:
                          'Card redeemed! Check your email or "My Cards".',
                      type: ToastType.success);
                }
              } catch (e) {
                debugPrint('Redeem gift card failed: $e');
                if (context.mounted) {
                  AppToast.show(context,
                      message: 'Redeem failed: $e',
                      type: ToastType.error);
                }
              }
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
              child: Text('Cancel',
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cash Out Tab (API-only) ───

class _CashOutTab extends ConsumerWidget {
  const _CashOutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(apiWalletProvider);
    final totalPoints = walletAsync.valueOrNull?.totalPoints ?? 0;
    final canCashOut = totalPoints >= EconomyConstants.cashOutMinBalance;
    final progressToGoal =
        (totalPoints / EconomyConstants.cashOutMinBalance).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Text('Your Balance', style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                walletAsync.when(
                  data: (w) => Text(
                      Formatters.number(w.totalPoints),
                      style: AppTypography.number
                          .copyWith(fontSize: 36)),
                  loading: () => ShimmerPlaceholder(
                      height: 40, width: 120, borderRadius: 8),
                  error: (_, __) => Text('--',
                      style: AppTypography.number
                          .copyWith(fontSize: 36)),
                ),
                Text('points', style: AppTypography.caption),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cash out goal',
                            style: AppTypography.caption),
                        Text(
                            '${Formatters.number(totalPoints)} / ${Formatters.number(EconomyConstants.cashOutMinBalance)}',
                            style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressToGoal,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: canCashOut
                                  ? AppColors.successGradient
                                  : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!canCashOut) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${Formatters.number(EconomyConstants.cashOutMinBalance - totalPoints)} more points to unlock',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Withdrawal Methods',
              style: AppTypography.headlineMedium),
          const SizedBox(height: 12),
          _CashOutMethod(
            icon: Icons.account_balance_wallet_rounded,
            title: 'PayPal',
            subtitle: 'Instant transfer to your PayPal',
            minAmount:
                '${Formatters.number(EconomyConstants.cashOutMinBalance)} pts',
            enabled: canCashOut,
            onTap: () => _showCashOutFlow(context, ref, 'PayPal'),
          ),
          const SizedBox(height: 10),
          _CashOutMethod(
            icon: Icons.credit_card_rounded,
            title: 'Bank Card',
            subtitle: 'Direct transfer, 1-3 business days',
            minAmount:
                '${Formatters.number(EconomyConstants.cashOutMinBalance)} pts',
            enabled: canCashOut,
            onTap: () => _showCashOutFlow(context, ref, 'Bank Card'),
          ),
        ],
      ),
    );
  }

  void _showCashOutFlow(
      BuildContext context, WidgetRef ref, String method) {
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
  bool _isSubmitting = false;
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
    final balance =
        ref.read(apiWalletProvider).valueOrNull?.totalPoints ?? 0;
    return balance >= _selectedAmount! && !_isSubmitting;
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

  void _submit() async {
    if (!_canSubmit) return;
    final amount = _selectedAmount!;
    final dest = _destController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      await ref.read(storeRepoProvider).requestCashOut(CashOutRequest(
            coinAmount: amount,
            paymentMethod:
                widget.method == 'PayPal' ? 'paypal' : 'bank_transfer',
            paymentDetails: dest,
          ));
      ref.invalidate(apiWalletProvider);
      if (mounted) {
        Navigator.pop(context);
        HapticFeedback.heavyImpact();
        AppToast.show(context,
            message:
                'Cash out request submitted! Processing in 1-3 days.',
            type: ToastType.success);
      }
    } catch (e) {
      debugPrint('Cash out failed: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppToast.show(context,
            message: 'Cash out failed: $e', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(apiWalletProvider);
    final totalPoints = walletAsync.valueOrNull?.totalPoints ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Text('Cash Out via ${widget.method}',
              style: AppTypography.headlineLarge),
          const SizedBox(height: 20),
          Text(
              widget.method == 'PayPal'
                  ? 'PayPal email'
                  : 'Card number',
              style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _destController,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textPrimary),
            keyboardType: widget.method == 'PayPal'
                ? TextInputType.emailAddress
                : TextInputType.number,
            decoration: InputDecoration(
              hintText: widget.method == 'PayPal'
                  ? 'your@email.com'
                  : '4242 **** **** ****',
              hintStyle: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceMid,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          if (_destController.text.isNotEmpty && !_isDestValid) ...[
            const SizedBox(height: 6),
            Text(
              widget.method == 'PayPal'
                  ? 'Enter a valid email address'
                  : 'Card number must be at least 13 digits',
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
              final affordable = totalPoints >= amount;
              return GestureDetector(
                onTap: affordable
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedAmount = amount);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
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
          if (_selectedAmount != null &&
              totalPoints < _selectedAmount!) ...[
            const SizedBox(height: 6),
            Text(
              'Not enough points',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: _isSubmitting ? 'Submitting...' : 'Submit Request',
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
              color: (enabled
                      ? AppColors.primary
                      : AppColors.textTertiary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: enabled
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.headlineSmall.copyWith(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textTertiary)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Min: $minAmount',
                    style: AppTypography.caption),
              ],
            ),
          ),
          Icon(
            enabled
                ? Icons.chevron_right_rounded
                : Icons.lock_outline_rounded,
            color: enabled
                ? AppColors.textSecondary
                : AppColors.textTertiary,
            size: 20,
          ),
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
          child: Center(
              child: Text(num,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary))),
      ],
    );
  }
}
