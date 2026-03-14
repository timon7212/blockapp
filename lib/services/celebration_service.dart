import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/colors/app_colors.dart';
import '../design_system/typography/app_typography.dart';
import '../core/constants/economy_constants.dart';
import '../core/utils/formatters.dart';

/// Centralized celebration system for dopamine-hacking moments.
///
/// Types of celebrations:
/// 1. **Points Claimed** — Success overlay with counter animation
/// 2. **Streak Milestone** — Full-screen confetti + badge animation
/// 3. **Rank Up** — Epic full-screen celebration
/// 4. **Spin Win** — Variable based on prize size
/// 5. **Daily Goals Complete** — Satisfying completion animation
/// 6. **Mystery Box** — Suspenseful reveal
class CelebrationService {
  /// Show a points claimed celebration overlay
  static void showPointsClaimed(
    BuildContext context, {
    required int points,
    required String multiplierLabel,
  }) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _PointsClaimedOverlay(
        points: points,
        multiplierLabel: multiplierLabel,
      ),
    );
  }

  /// Show a streak milestone celebration
  static void showStreakMilestone(
    BuildContext context, {
    required int days,
    required String tierName,
    required String multiplierLabel,
  }) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => _StreakMilestoneOverlay(
        days: days,
        tierName: tierName,
        multiplierLabel: multiplierLabel,
      ),
    );
  }

  /// Show a rank up celebration
  static void showRankUp(
    BuildContext context, {
    required RankTier newRank,
  }) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => _RankUpOverlay(rank: newRank),
    );
  }

  /// Show daily goals completed celebration
  static void showDailyGoalsComplete(
    BuildContext context, {
    required int bonusPoints,
  }) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) =>
          _DailyGoalsCompleteOverlay(bonusPoints: bonusPoints),
    );
  }

  /// Generate a mystery box prize
  static MysteryBoxPrize generateMysteryBoxPrize() {
    final rng = Random();
    final prizes = EconomyConstants.mysteryBoxPrizes;
    final totalWeight = prizes.fold<int>(0, (sum, p) => sum + p.weight);
    var roll = rng.nextInt(totalWeight);
    for (final prize in prizes) {
      roll -= prize.weight;
      if (roll < 0) return prize;
    }
    return prizes.last;
  }
}

// ─── Points Claimed Overlay ───
class _PointsClaimedOverlay extends StatefulWidget {
  final int points;
  final String multiplierLabel;

  const _PointsClaimedOverlay({
    required this.points,
    required this.multiplierLabel,
  });

  @override
  State<_PointsClaimedOverlay> createState() => _PointsClaimedOverlayState();
}

class _PointsClaimedOverlayState extends State<_PointsClaimedOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
    // Auto-dismiss after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded,
                        size: 42, color: AppColors.success),
                  ),
                )
                    .animate()
                    .scaleXY(
                        begin: 0.3, end: 1.0,
                        duration: 400.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 200.ms),
                const SizedBox(height: 20),
                Text(
                  '+${Formatters.number(widget.points)}',
                  style: AppTypography.number.copyWith(
                    fontSize: 48,
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 4),
                Text(
                  'points claimed',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.multiplierLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              gravity: 0.3,
              colors: const [
                AppColors.success,
                AppColors.accent,
                AppColors.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak Milestone Overlay ───
class _StreakMilestoneOverlay extends StatefulWidget {
  final int days;
  final String tierName;
  final String multiplierLabel;

  const _StreakMilestoneOverlay({
    required this.days,
    required this.tierName,
    required this.multiplierLabel,
  });

  @override
  State<_StreakMilestoneOverlay> createState() =>
      _StreakMilestoneOverlayState();
}

class _StreakMilestoneOverlayState extends State<_StreakMilestoneOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated fire
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.warning.withValues(alpha: 0.3),
                          AppColors.warning.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 72,
                        color: AppColors.warning,
                      ),
                    ),
                  )
                      .animate()
                      .scaleXY(
                          begin: 0.2,
                          end: 1.0,
                          duration: 600.ms,
                          curve: Curves.elasticOut)
                      .then()
                      .scaleXY(
                          begin: 1.0,
                          end: 1.08,
                          duration: 1200.ms)
                      .then()
                      .scaleXY(begin: 1.08, end: 1.0, duration: 1200.ms),
                  const SizedBox(height: 20),
                  Text(
                    '${widget.days}-Day Streak!',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    widget.tierName,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.multiplierLabel} Multiplier Unlocked!',
                      style: AppTypography.button
                          .copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 700.ms).scaleXY(
                      begin: 0.8, end: 1.0),
                  const SizedBox(height: 24),
                  Text(
                    'Tap to continue',
                    style: AppTypography.bodySmall,
                  )
                      .animate(
                          onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: 1200.ms)
                      .then()
                      .fadeIn()
                      .then()
                      .fade(begin: 1, end: 0.4, duration: 800.ms),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.04,
              numberOfParticles: 30,
              maxBlastForce: 25,
              gravity: 0.2,
              colors: const [
                AppColors.warning,
                Color(0xFFFF6B35),
                Color(0xFFFFD700),
                AppColors.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rank Up Overlay ───
class _RankUpOverlay extends StatefulWidget {
  final RankTier rank;

  const _RankUpOverlay({required this.rank});

  @override
  State<_RankUpOverlay> createState() => _RankUpOverlayState();
}

class _RankUpOverlayState extends State<_RankUpOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.rank.icon,
                    style: const TextStyle(fontSize: 72),
                  )
                      .animate()
                      .scaleXY(
                          begin: 0.1,
                          end: 1.0,
                          duration: 600.ms,
                          curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    'RANK UP!',
                    style: AppTypography.displaySmall.copyWith(
                      color: Color(widget.rank.color),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    widget.rank.name,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(widget.rank.color)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Color(widget.rank.color)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Unlocked:',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.rank.maxSpins} daily spins · +${widget.rank.extraSessionBonus} session bonus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(widget.rank.color),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                  const SizedBox(height: 24),
                  Text('Tap to continue', style: AppTypography.bodySmall)
                      .animate(
                          onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: 1200.ms)
                      .then()
                      .fadeIn()
                      .then()
                      .fade(begin: 1, end: 0.4, duration: 800.ms),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.04,
              numberOfParticles: 40,
              maxBlastForce: 30,
              gravity: 0.15,
              colors: [
                Color(widget.rank.color),
                AppColors.primary,
                AppColors.accent,
                AppColors.success,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Daily Goals Complete Overlay ───
class _DailyGoalsCompleteOverlay extends StatefulWidget {
  final int bonusPoints;

  const _DailyGoalsCompleteOverlay({required this.bonusPoints});

  @override
  State<_DailyGoalsCompleteOverlay> createState() =>
      _DailyGoalsCompleteOverlayState();
}

class _DailyGoalsCompleteOverlayState
    extends State<_DailyGoalsCompleteOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.successGradient,
                  ),
                  child: const Center(
                    child: Icon(Icons.star_rounded,
                        size: 48, color: Colors.white),
                  ),
                )
                    .animate()
                    .scaleXY(
                        begin: 0.2,
                        end: 1.0,
                        duration: 500.ms,
                        curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  'Daily Goals Complete!',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.success,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  '+${Formatters.number(widget.bonusPoints)} bonus points',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              colors: const [
                AppColors.success,
                AppColors.accent,
                AppColors.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
