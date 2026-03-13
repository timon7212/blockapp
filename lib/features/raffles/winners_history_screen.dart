import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/surface_card.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../core/utils/formatters.dart';

class WinnersHistoryScreen extends StatefulWidget {
  const WinnersHistoryScreen({super.key});

  @override
  State<WinnersHistoryScreen> createState() => _WinnersHistoryScreenState();
}

class _WinnersHistoryScreenState extends State<WinnersHistoryScreen> {
  int _tab = 0;
  static const _tabs = ['Daily', 'Weekly', 'Monthly'];

  static final _mockWinners = {
    0: [
      _WinnerData('Alex K.', '@alex_k', 5000, DateTime.now().subtract(const Duration(hours: 3))),
      _WinnerData('Maria S.', '@maria_s', 5000, DateTime.now().subtract(const Duration(hours: 27))),
      _WinnerData('John D.', '@john_d', 5000, DateTime.now().subtract(const Duration(hours: 51))),
      _WinnerData('Elena P.', '@elena_p', 5000, DateTime.now().subtract(const Duration(hours: 75))),
      _WinnerData('Mike R.', '@mike_r', 5000, DateTime.now().subtract(const Duration(hours: 99))),
    ],
    1: [
      _WinnerData('Sarah L.', '@sarah_l', 25000, DateTime.now().subtract(const Duration(days: 2))),
      _WinnerData('David W.', '@david_w', 25000, DateTime.now().subtract(const Duration(days: 9))),
      _WinnerData('Anna B.', '@anna_b', 25000, DateTime.now().subtract(const Duration(days: 16))),
    ],
    2: [
      _WinnerData('Chris T.', '@chris_t', 100000, DateTime.now().subtract(const Duration(days: 10))),
      _WinnerData('Lisa M.', '@lisa_m', 100000, DateTime.now().subtract(const Duration(days: 40))),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final winners = _mockWinners[_tab] ?? [];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              Expanded(
                child: winners.isEmpty
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No winners yet', style: AppTypography.bodyMedium),
                        ]),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: winners.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final w = winners[i];
                          return _WinnerCard(winner: w, rank: i + 1)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * i))
                              .slideY(begin: 0.03, end: 0);
                        },
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
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
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
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Winners', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = _tab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _tab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: active ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
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

class _WinnerCard extends StatelessWidget {
  final _WinnerData winner;
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
                colors: [_rankColor.withValues(alpha: 0.2), _rankColor.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _rankColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                winner.name.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _rankColor),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(winner.name, style: AppTypography.headlineSmall),
                const SizedBox(height: 2),
                Text(winner.handle, style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${Formatters.points(winner.prize)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
              const SizedBox(height: 2),
              Text(_timeAgo(winner.date), style: AppTypography.caption),
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

class _WinnerData {
  final String name;
  final String handle;
  final int prize;
  final DateTime date;
  const _WinnerData(this.name, this.handle, this.prize, this.date);
}
