import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/wallet_model.dart';
import 'exercise_screen.dart';

enum _UnlockOption { watchAd, exercise }

class UnlockModal extends ConsumerStatefulWidget {
  final VoidCallback? onUnlocked;
  const UnlockModal({super.key, this.onUnlocked});

  @override
  ConsumerState<UnlockModal> createState() => _UnlockModalState();
}

class _UnlockModalState extends ConsumerState<UnlockModal> {
  _UnlockOption _selected = _UnlockOption.watchAd;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dailyStatsProvider);
    final remaining = stats.exerciseUnlocksRemaining;
    final exerciseAvailable = remaining > 0;

    if (!exerciseAvailable && _selected == _UnlockOption.exercise) {
      _selected = _UnlockOption.watchAd;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            Text('Unlock Apps', style: AppTypography.headlineLarge),
            const SizedBox(height: 6),
            Text(
              'Choose how to unlock for 15 minutes',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 24),
            _OptionCard(
              selected: _selected == _UnlockOption.watchAd,
              enabled: true,
              emoji: '🎬',
              title: 'Watch Ad',
              subtitle: 'Watch a short video',
              coinReward: EconomyConstants.adUnlockReward,
              onTap: () => setState(() => _selected = _UnlockOption.watchAd),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              selected: _selected == _UnlockOption.exercise,
              enabled: exerciseAvailable,
              emoji: '🏋️',
              title: 'Exercise',
              subtitle: exerciseAvailable
                  ? 'Push-ups'
                  : 'No exercises left today',
              trailing: exerciseAvailable
                  ? '$remaining/5 left'
                  : null,
              onTap: exerciseAvailable
                  ? () => setState(() => _selected = _UnlockOption.exercise)
                  : null,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Cancel',
                    outlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue →',
                    onPressed: () => _onContinue(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.inactive,
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  void _onContinue(BuildContext context) {
    HapticFeedback.mediumImpact();

    if (_selected == _UnlockOption.watchAd) {
      ref.read(walletProvider.notifier).addCoins(
        EconomyConstants.adUnlockReward,
        'Ad unlock',
        TransactionType.adUnlock,
      );
      ref.read(dailyStatsProvider.notifier).recordAdWatch(
        EconomyConstants.adUnlockReward,
      );
      Navigator.of(context).pop();
      widget.onUnlocked?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+${EconomyConstants.adUnlockReward} coins — apps unlocked for 15 min',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ExerciseScreen()),
      ).then((_) {
        widget.onUnlocked?.call();
      });
    }
  }
}

class _OptionCard extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final String emoji;
  final String title;
  final String subtitle;
  final String? trailing;
  final int? coinReward;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.selected,
    required this.enabled,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.coinReward,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected && enabled
                ? AppColors.primary
                : AppColors.border,
            width: selected && enabled ? 2 : 1,
          ),
          boxShadow: selected && enabled ? AppColors.cardShadow : null,
        ),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.45,
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: enabled
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trailing!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (coinReward != null)
                CoinBadge(amount: coinReward!, showPlus: true),
            ],
          ),
        ),
      ),
    );
  }
}
