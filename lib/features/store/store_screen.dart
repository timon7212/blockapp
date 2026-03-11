import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/gift_card_model.dart';
import '../../models/wallet_model.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _tab = 0;
  final _tabs = ['Gift Cards', 'Cash Out', 'Charity'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _Header(coins: ref.watch(walletProvider).totalCoins),
            const SizedBox(height: 16),
            _TabBar(
              tabs: _tabs,
              selected: _tab,
              onTap: (i) {
                HapticFeedback.selectionClick();
                setState(() => _tab = i);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _GiftCardsTab(),
                  _CashOutTab(),
                  _CharityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───

class _Header extends StatelessWidget {
  final int coins;
  const _Header({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('Store', style: AppTypography.displaySmall),
          const Spacer(),
          CoinBadge(amount: coins),
        ],
      ),
    );
  }
}

// ─── Tab Bar ───

class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  const _TabBar({
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
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
                    boxShadow: active ? AppColors.cardShadow : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
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

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: giftCards.length,
      itemBuilder: (context, i) {
        final gc = giftCards[i];
        final canAfford = wallet.totalCoins >= gc.coinCost;
        return _GiftCardItem(
          card: gc,
          canAfford: canAfford,
          onRedeem: () => _redeemGiftCard(context, ref, gc),
        );
      },
    );
  }

  void _redeemGiftCard(
    BuildContext context,
    WidgetRef ref,
    GiftCardModel gc,
  ) {
    HapticFeedback.mediumImpact();
    final wallet = ref.read(walletProvider);
    if (wallet.totalCoins < gc.coinCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Not enough coins — need ${Formatters.number(gc.coinCost)}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Redeem ${gc.brand}?'),
        content: Text(
          'Spend ${Formatters.number(gc.coinCost)} coins for a '
          '${Formatters.currency(gc.faceValue)} ${gc.brand} gift card?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(walletProvider.notifier).spendCoins(
                    gc.coinCost,
                    '${gc.brand} gift card',
                    TransactionType.giftCardPurchase,
                  );
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '🎉 ${gc.brand} ${Formatters.currency(gc.faceValue)} redeemed!',
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.all(16),
              ));
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _GiftCardItem extends StatelessWidget {
  final GiftCardModel card;
  final bool canAfford;
  final VoidCallback onRedeem;

  const _GiftCardItem({
    required this.card,
    required this.canAfford,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(card.emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 10),
          Text(
            card.brand,
            style: AppTypography.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.currency(card.faceValue),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          CoinBadge(amount: card.coinCost, fontSize: 13),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: canAfford ? onRedeem : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                color: canAfford ? AppColors.textPrimary : AppColors.inactive,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Redeem',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canAfford
                        ? Colors.white
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cash Out Tab ───

class _CashOutTab extends ConsumerWidget {
  const _CashOutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final coins = wallet.totalCoins;
    final canCashOut = coins >= EconomyConstants.cashOutMinBalance;
    final cashValue = coins / 1000;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Text(
                  'Your Balance',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                CoinBadge(amount: coins, fontSize: 32),
                const SizedBox(height: 8),
                Text(
                  '≈ ${Formatters.currency(cashValue)}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Exchange Rate',
                  value: '1,000 coins = \$1.00',
                ),
                const Divider(height: 24, color: AppColors.borderLight),
                _InfoRow(
                  label: 'Minimum Cash Out',
                  value: '${Formatters.number(EconomyConstants.cashOutMinBalance)} coins',
                ),
                const Divider(height: 24, color: AppColors.borderLight),
                _InfoRow(
                  label: 'Processing Time',
                  value: '1–3 business days',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!canCashOut)
            AppCard(
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.orange.withOpacity(0.3),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You need ${Formatters.number(EconomyConstants.cashOutMinBalance - coins)} more coins to cash out.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: canCashOut ? 'Cash Out' : 'Not Enough Coins',
            enabled: canCashOut,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Cash out processing — Coming Soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.all(16),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

// ─── Charity Tab ───

class _CharityTab extends ConsumerStatefulWidget {
  const _CharityTab();

  @override
  ConsumerState<_CharityTab> createState() => _CharityTabState();
}

class _CharityTabState extends ConsumerState<_CharityTab> {
  final _amountController = TextEditingController(text: '100');

  static const _charities = [
    _CharityData('💧', 'Water.org', 'Provide clean water access to communities in need.', AppColors.teal),
    _CharityData('🏥', 'Red Cross', 'Support disaster relief and emergency assistance.', AppColors.red),
    _CharityData('🌍', 'UNICEF', 'Help children worldwide with education and health.', AppColors.primary),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('❤️', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  'Donate your coins\nto make a difference',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Every coin donated goes directly to verified charities.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Amount input
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text('Amount:', style: AppTypography.labelLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.coin,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '100',
                      hintStyle: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      suffixText: 'coins',
                      suffixStyle: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_charities.length, (i) {
            final c = _charities[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _charities.length - 1 ? 12 : 0),
              child: _CharityCard(
                data: c,
                onDonate: () => _donate(context, c),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _donate(BuildContext context, _CharityData charity) {
    HapticFeedback.mediumImpact();
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Enter a valid donation amount'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    final wallet = ref.read(walletProvider);
    if (wallet.totalCoins < amount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Not enough coins for this donation'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    ref.read(walletProvider.notifier).spendCoins(
          amount,
          'Donation to ${charity.name}',
          TransactionType.donation,
        );
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        '❤️ Donated $amount coins to ${charity.name}!',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
    ));
  }
}

class _CharityData {
  final String emoji;
  final String name;
  final String description;
  final Color color;
  const _CharityData(this.emoji, this.name, this.description, this.color);
}

class _CharityCard extends StatelessWidget {
  final _CharityData data;
  final VoidCallback onDonate;

  const _CharityCard({required this.data, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: AppTypography.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onDonate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Donate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

