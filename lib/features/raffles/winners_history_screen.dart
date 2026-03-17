import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/api_providers.dart';
import '../../data/dto/raffle_dto.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';

class WinnersHistoryScreen extends ConsumerWidget {
  const WinnersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnersAsync = ref.watch(apiRaffleWinnersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: winnersAsync.when(
                  data: (winners) {
                    if (winners.isEmpty) {
                      return Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events_outlined,
                                  size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              Text('No winners yet',
                                  style: AppTypography.bodyMedium),
                            ]),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      physics: const BouncingScrollPhysics(),
                      itemCount: winners.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final w = winners[i];
                        return _WinnerCard(winner: w, rank: i + 1)
                            .animate()
                            .fadeIn(
                                duration: 400.ms,
                                delay: Duration(milliseconds: 50 * i))
                            .slideY(begin: 0.03, end: 0);
                      },
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: List.generate(
                        5,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child:
                              ShimmerPlaceholder(height: 76, borderRadius: 16),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text('Could not load winners',
                              style: AppTypography.bodyMedium),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                ref.invalidate(apiRaffleWinnersProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Retry',
                                  style: AppTypography.labelMedium
                                      .copyWith(color: AppColors.primary)),
                            ),
                          ),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Winners', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final RaffleWinnerDto winner;
  final int rank;
  const _WinnerCard({required this.winner, required this.rank});

  Color get _rankColor {
    if (rank == 1) return AppColors.warning;
    if (rank == 2) return AppColors.textSecondary;
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _rankColor.withValues(alpha: 0.2),
                  _rankColor.withValues(alpha: 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _rankColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: winner.winnerAvatar != null
                  ? ClipOval(
                      child: Image.network(winner.winnerAvatar!,
                          width: 44, height: 44, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                                winner.winnerUsername
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _rankColor),
                              )))
                  : Text(
                      winner.winnerUsername.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _rankColor),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(winner.winnerUsername,
                    style: AppTypography.headlineSmall),
                const SizedBox(height: 2),
                Text(winner.raffleTitle, style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${Formatters.points(winner.prizeAmount)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success)),
              const SizedBox(height: 2),
              Text(_timeAgo(winner.drawnAt), style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
