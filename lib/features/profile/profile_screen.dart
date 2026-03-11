import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/setting_tile.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Text('Profile', style: AppTypography.displaySmall),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: AppTypography.headlineLarge),
                          const SizedBox(height: 4),
                          CoinBadge(amount: wallet.totalCoins),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            const SectionHeader(title: 'Settings'),
            const SizedBox(height: 8),

            _buildSettingsSection(context, ref, user),

            const SizedBox(height: 28),
            const SectionHeader(title: 'Account'),
            const SizedBox(height: 8),

            _buildAccountSection(context, ref),

            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, UserModel user) {
    final blockedApps = ref.watch(blockedAppsProvider);
    final activeCount = blockedApps.where((a) => a.isActive).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.block_rounded, color: AppColors.primary, size: 22),
            ),
            title: 'Blocked Apps',
            subtitle: '$activeCount apps active',
            onTap: () => _showBlockedAppsSheet(context, ref),
          ),
          const SizedBox(height: 10),
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.preferredExercise.emoji,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            title: 'Exercise Type',
            subtitle: user.preferredExercise.label,
            onTap: () => _showExercisePicker(context, ref),
          ),
          const SizedBox(height: 10),
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.coinLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: AppColors.coin, size: 22),
            ),
            title: 'Exercise Difficulty',
            subtitle: '${user.exerciseDifficulty} reps per unlock',
            onTap: () => _showDifficultyPicker(context, ref),
          ),
          const SizedBox(height: 10),
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.language_rounded, color: AppColors.textSecondary, size: 22),
            ),
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 22),
            ),
            title: 'Manage Account',
            subtitle: 'Account settings & preferences',
            onTap: () => _showManageAccount(context),
          ),
          const SizedBox(height: 10),
          SettingTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.red, size: 22),
            ),
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            titleColor: AppColors.red,
            trailing: const SizedBox.shrink(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign out not available in demo')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBlockedAppsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BlockedAppsSheet(),
    );
  }

  void _showExercisePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExercisePickerSheet(),
    );
  }

  void _showDifficultyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DifficultyPickerSheet(),
    );
  }

  void _showManageAccount(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const _ManageAccountScreen(),
    ));
  }
}

class _BlockedAppsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(blockedAppsProvider);
    final activeCount = apps.where((a) => a.isActive).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Blocked Apps', style: AppTypography.headlineLarge),
          const SizedBox(height: 4),
          Text('$activeCount apps active', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),
          ...apps.map((app) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(blockedAppsProvider.notifier).toggleApp(app.id);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: app.isActive ? AppColors.primaryLight : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: app.isActive
                      ? Border.all(color: AppColors.primary.withOpacity(0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(app.iconEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(app.name, style: AppTypography.headlineMedium),
                    ),
                    if (app.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ExercisePickerSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Choose Exercise', style: AppTypography.headlineLarge),
          const SizedBox(height: 20),
          ...ExerciseType.values.map((type) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(userProvider.notifier).state =
                    user.copyWith(preferredExercise: type);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: user.preferredExercise == type
                      ? AppColors.primaryLight
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: user.preferredExercise == type
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Text(type.label, style: AppTypography.headlineMedium),
                    const Spacer(),
                    if (user.preferredExercise == type)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _DifficultyPickerSheet extends ConsumerWidget {
  static const _options = [5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Reps per Unlock', style: AppTypography.headlineLarge),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((reps) {
              final selected = user.exerciseDifficulty == reps;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(userProvider.notifier).state =
                      user.copyWith(exerciseDifficulty: reps);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$reps',
                      style: AppTypography.headlineLarge.copyWith(
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ManageAccountScreen extends StatelessWidget {
  const _ManageAccountScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Text('Manage Account', style: AppTypography.displaySmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SettingTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 22),
                    ),
                    title: 'Delete Account',
                    titleColor: AppColors.red,
                    trailing: const SizedBox.shrink(),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SettingTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
                    ),
                    title: 'Terms of Use',
                    trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.textTertiary, size: 20),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SettingTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 22),
                    ),
                    title: 'Privacy Policy',
                    trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.textTertiary, size: 20),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Text('Version 1.0.0', style: AppTypography.caption),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
