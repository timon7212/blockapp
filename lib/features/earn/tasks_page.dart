import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  static const _offers = [
    _TaskOffer(
      appName: 'Crypto.com',
      appIcon: '💎',
      description: 'Start your crypto journey',
      color: Color(0xFF002D72),
      steps: [
        _TaskStep('Download & install app', 50, true),
        _TaskStep('Complete KYC verification', 200, false),
        _TaskStep('Deposit \$1 or more', 500, false),
      ],
      totalReward: 750,
    ),
    _TaskOffer(
      appName: 'Binance',
      appIcon: '🟡',
      description: 'World\'s largest crypto exchange',
      color: Color(0xFFF0B90B),
      steps: [
        _TaskStep('Download & install app', 50, true),
        _TaskStep('Create an account', 150, false),
      ],
      totalReward: 200,
    ),
    _TaskOffer(
      appName: 'Netflix',
      appIcon: '🎬',
      description: 'Stream movies & shows',
      color: Color(0xFFE50914),
      steps: [
        _TaskStep('Download & create account', 30, true),
        _TaskStep('Purchase a subscription', 400, false),
      ],
      totalReward: 430,
    ),
    _TaskOffer(
      appName: 'Spotify',
      appIcon: '🎵',
      description: 'Music streaming service',
      color: Color(0xFF1DB954),
      steps: [
        _TaskStep('Download & sign up', 30, true),
        _TaskStep('Listen to 30 minutes of music', 80, false),
        _TaskStep('Subscribe to Premium', 350, false),
      ],
      totalReward: 460,
    ),
    _TaskOffer(
      appName: 'Revolut',
      appIcon: '💳',
      description: 'Digital banking made easy',
      color: Color(0xFF0075EB),
      steps: [
        _TaskStep('Download & register', 50, true),
        _TaskStep('Complete identity verification', 150, false),
        _TaskStep('Make your first transaction', 300, false),
      ],
      totalReward: 500,
    ),
    _TaskOffer(
      appName: 'Duolingo',
      appIcon: '🦉',
      description: 'Learn a new language',
      color: Color(0xFF58CC02),
      steps: [
        _TaskStep('Download & create account', 20, true),
        _TaskStep('Complete 5 lessons', 80, false),
        _TaskStep('Reach a 7-day streak', 200, false),
      ],
      totalReward: 300,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: _offers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _TaskOfferCard(offer: _offers[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text('Tasks', style: AppTypography.headlineLarge),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Text('${_offers.length} offers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _TaskOffer {
  final String appName;
  final String appIcon;
  final String description;
  final Color color;
  final List<_TaskStep> steps;
  final int totalReward;
  const _TaskOffer({required this.appName, required this.appIcon, required this.description, required this.color, required this.steps, required this.totalReward});
}

class _TaskStep {
  final String title;
  final int reward;
  final bool completed;
  const _TaskStep(this.title, this.reward, this.completed);
}

class _TaskOfferCard extends StatelessWidget {
  final _TaskOffer offer;
  const _TaskOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final completedSteps = offer.steps.where((s) => s.completed).length;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: offer.color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: offer.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(offer.appIcon, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.appName, style: AppTypography.headlineMedium),
                      const SizedBox(height: 2),
                      Text(offer.description, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                          child: const Center(child: Text('M', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                        ),
                        const SizedBox(width: 4),
                        Text('${offer.totalReward}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.coin)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('$completedSteps/${offer.steps.length} done', style: AppTypography.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                ...offer.steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < offer.steps.length - 1 ? 10 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step.completed ? AppColors.green : AppColors.surfaceSecondary,
                            border: step.completed ? null : Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: step.completed
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : Center(child: Text('${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: step.completed ? AppColors.textTertiary : AppColors.textPrimary,
                              decoration: step.completed ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '+${step.reward}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: step.completed ? AppColors.textTertiary : AppColors.coin),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Opening ${offer.appName}...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  child: Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(color: offer.color, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text('Start Task', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
