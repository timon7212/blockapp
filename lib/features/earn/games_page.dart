import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/app_card.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  static const _games = [
    _GameOffer(
      name: 'Monopoly GO!',
      icon: '🎩',
      description: 'Classic board game reimagined',
      color: Color(0xFF00875A),
      milestones: [
        _Milestone('Install the game', 0, 0),
        _Milestone('Reach Level 10', 10, 150),
        _Milestone('Reach Level 50', 50, 500),
        _Milestone('Reach Level 100', 100, 1200),
        _Milestone('Reach Level 500', 500, 3000),
      ],
      totalReward: 4850,
    ),
    _GameOffer(
      name: 'Puzzle Quest',
      icon: '🧩',
      description: 'Match-3 puzzle adventure',
      color: Color(0xFF5856D6),
      milestones: [
        _Milestone('Install the game', 0, 0),
        _Milestone('Reach Level 10', 10, 100),
        _Milestone('Reach Level 50', 50, 350),
        _Milestone('Reach Level 100', 100, 800),
        _Milestone('Reach Level 250', 250, 2000),
      ],
      totalReward: 3250,
    ),
    _GameOffer(
      name: 'Coin Master',
      icon: '🪙',
      description: 'Spin, attack & build villages',
      color: Color(0xFFFF9500),
      milestones: [
        _Milestone('Install the game', 0, 0),
        _Milestone('Complete Village 3', 3, 120),
        _Milestone('Complete Village 10', 10, 400),
        _Milestone('Complete Village 25', 25, 900),
        _Milestone('Complete Village 50', 50, 2500),
      ],
      totalReward: 3920,
    ),
    _GameOffer(
      name: 'Royal Match',
      icon: '👑',
      description: 'Colorful puzzle kingdom',
      color: Color(0xFFFF2D55),
      milestones: [
        _Milestone('Install the game', 0, 0),
        _Milestone('Reach Level 20', 20, 100),
        _Milestone('Reach Level 75', 75, 400),
        _Milestone('Reach Level 150', 150, 1000),
        _Milestone('Reach Level 300', 300, 2800),
      ],
      totalReward: 4300,
    ),
    _GameOffer(
      name: 'Merge Dragons',
      icon: '🐉',
      description: 'Merge everything in a magical world',
      color: Color(0xFF34C759),
      milestones: [
        _Milestone('Install the game', 0, 0),
        _Milestone('Reach Level 5', 5, 80),
        _Milestone('Reach Level 15', 15, 250),
        _Milestone('Reach Level 30', 30, 600),
        _Milestone('Reach Level 60', 60, 1500),
      ],
      totalReward: 2430,
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
                itemCount: _games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _GameOfferCard(game: _games[i]),
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
          Text('Games', style: AppTypography.headlineLarge),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(8)),
            child: Text('${_games.length} games', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green)),
          ),
        ],
      ),
    );
  }
}

class _GameOffer {
  final String name;
  final String icon;
  final String description;
  final Color color;
  final List<_Milestone> milestones;
  final int totalReward;
  const _GameOffer({required this.name, required this.icon, required this.description, required this.color, required this.milestones, required this.totalReward});
}

class _Milestone {
  final String title;
  final int level;
  final int reward;
  const _Milestone(this.title, this.level, this.reward);
}

class _GameOfferCard extends StatelessWidget {
  final _GameOffer game;
  const _GameOfferCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: game.color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: game.color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(game.icon, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.name, style: AppTypography.headlineMedium),
                      const SizedBox(height: 2),
                      Text(game.description, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('up to', style: AppTypography.caption.copyWith(fontSize: 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle),
                          child: const Center(child: Text('M', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                        ),
                        const SizedBox(width: 4),
                        Text('${game.totalReward}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.coin)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                ...game.milestones.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  final isInstall = m.reward == 0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < game.milestones.length - 1 ? 8 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isInstall ? AppColors.surfaceSecondary : game.color.withOpacity(0.1),
                            border: Border.all(color: isInstall ? AppColors.border : game.color.withOpacity(0.3), width: 1),
                          ),
                          child: Center(
                            child: isInstall
                                ? Icon(Icons.download_rounded, size: 12, color: AppColors.textTertiary)
                                : Text('${i}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: game.color)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(m.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        ),
                        if (m.reward > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 10, height: 10, decoration: const BoxDecoration(gradient: AppColors.coinGradient, shape: BoxShape.circle)),
                              const SizedBox(width: 3),
                              Text('+${m.reward}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coin)),
                            ],
                          )
                        else
                          Text('Free', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Opening ${game.name}...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  child: Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(color: game.color, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Play Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
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
