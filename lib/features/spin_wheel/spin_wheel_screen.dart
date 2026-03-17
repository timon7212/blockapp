import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/providers/auth_notifier.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/result_sheet.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../design_system/widgets/shimmer_placeholder.dart';
import '../../core/utils/formatters.dart';
import '../../services/ad_service.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late ConfettiController _confettiController;
  bool _isSpinning = false;
  double _currentAngle = 0;
  int? _apiSpinsRemaining; // Updated after each API spin

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin(List<_WheelSegment> prizes) async {
    final int spinsLeft = _apiSpinsRemaining ?? 0;
    if (spinsLeft <= 0 || _isSpinning) return;

    HapticFeedback.mediumImpact();

    // Show ad first
    bool adCompleted = false;
    if (mounted) {
      AppToast.show(context, message: 'Loading ad...', type: ToastType.info);
    }
    await AdService.showRewardedAd(
      onRewarded: () => adCompleted = true,
      onFailed: () {
        if (mounted) {
          AppToast.show(context,
              message: 'Ad failed to load. Try again.', type: ToastType.error);
        }
      },
    );
    if (!adCompleted || !mounted) return;

    HapticFeedback.heavyImpact();
    setState(() => _isSpinning = true);

    // ── Call API spin ──
    double resultValueRaw;
    String resultLabel;
    int? newSpinsRemaining;

    try {
      final response = await ref.read(eventsRepoProvider).spin();
      resultValueRaw = response.prizeValue;
      resultLabel = response.prizeLabel;
      newSpinsRemaining = response.spinsRemaining;

      // Refresh wallet balance from API
      ref.invalidate(apiWalletProvider);
      ref.invalidate(apiDailyStatsProvider);

      debugPrint(
          '🎰 API spin result: $resultLabel ($resultValueRaw) – spins left: $newSpinsRemaining');
    } catch (e) {
      debugPrint('🎰 API spin failed: $e');
      if (mounted) {
        setState(() => _isSpinning = false);
        AppToast.show(context,
            message: 'Spin failed: $e', type: ToastType.error);
      }
      return; // Don't animate — no result
    }

    if (!mounted) return;

    // Find the prize index on the wheel — match by LABEL first
    // (matching by value is unreliable because different prize types
    //  can share the same rounded value, e.g. "1.5x Bonus" → 2 vs "2x Bonus" → 2)
    int prizeIndex = prizes.indexWhere(
        (p) => p.label.toLowerCase() == resultLabel.toLowerCase());
    if (prizeIndex < 0) {
      // Fallback: match by original (unrounded) value
      prizeIndex = prizes.indexWhere((p) => p.originalValue == resultValueRaw);
    }
    if (prizeIndex < 0) {
      // Last resort: match by rounded value
      prizeIndex =
          prizes.indexWhere((p) => p.displayValue == resultValueRaw.round());
    }
    if (prizeIndex < 0) prizeIndex = 0; // safety fallback

    final segmentAngle = 2 * pi / prizes.length;
    final desiredFinalAngle = (prizeIndex + 0.5) * segmentAngle;
    final currentMod = _currentAngle % (2 * pi);
    var delta = desiredFinalAngle - currentMod;
    if (delta < 0) delta += 2 * pi;
    final targetAngle = _currentAngle + (2 * pi * 5) + delta;

    _spinController.reset();
    final animation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    animation.addListener(() {
      setState(() => _currentAngle = animation.value);
    });

    _spinController.forward().then((_) {
      _currentAngle = targetAngle % (2 * pi);
      setState(() {
        _isSpinning = false;
        if (newSpinsRemaining != null) {
          _apiSpinsRemaining = newSpinsRemaining;
        }
      });

      HapticFeedback.heavyImpact();
      if (resultValueRaw >= 250) _confettiController.play();

      _showResult(resultLabel, resultValueRaw);
    });
  }

  void _showResult(String label, double value) {
    final isPoints = value >= 10; // Points prizes are 50, 100, 200+
    final isNothing = value == 0;
    final isBig = value >= 200;

    ResultSheet.show(
      context,
      icon: isNothing
          ? Icons.refresh_rounded
          : isBig
              ? Icons.auto_awesome_rounded
              : Icons.stars_rounded,
      iconColor: isNothing
          ? AppColors.textTertiary
          : isBig
              ? AppColors.primary
              : AppColors.success,
      title: isNothing
          ? 'Try Again!'
          : isBig
              ? 'Incredible!'
              : 'Nice Spin!',
      subtitle: isNothing ? 'Better luck next time' : 'Added to your balance',
      valueWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isNothing ? label : '+$label',
            style: AppTypography.number.copyWith(fontSize: 30),
          ),
        ],
      ),
      buttonLabel: 'Continue',
    );
  }

  String _rarity(int value) {
    if (value >= 1000) return 'Legendary';
    if (value >= 500) return 'Epic';
    if (value >= 100) return 'Rare';
    return 'Common';
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Legendary':
        return AppColors.primary;
      case 'Epic':
        return AppColors.accent;
      case 'Rare':
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prizesAsync = ref.watch(apiSpinPrizesProvider);
    final authState = ref.watch(authNotifierProvider);

    // Initialize spinsAvailable from user profile (once)
    if (_apiSpinsRemaining == null && authState.user != null) {
      _apiSpinsRemaining = authState.user!.spinsAvailable;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: prizesAsync.when(
            data: (apiPrizes) {
              if (apiPrizes.isEmpty) {
                return _buildErrorState('No spin prizes available', ref);
              }

              final prizes = apiPrizes
                  .map((p) => _WheelSegment(
                        label: p.label,
                        originalValue: p.value,
                        displayValue: p.value.round(),
                      ))
                  .toList();

              final int spinsLeft = _apiSpinsRemaining ?? 0;

              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(context, spinsLeft),
                      const Spacer(),
                      _buildWheel(prizes),
                      const Spacer(),
                      _buildLegend(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: PrimaryButton(
                          label: spinsLeft > 0 ? 'SPIN' : 'No Spins Left',
                          enabled: spinsLeft > 0 && !_isSpinning,
                          gradient: AppColors.primaryGradient,
                          icon: Icons.casino_rounded,
                          onPressed: () => _spin(prizes),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                      if (spinsLeft == 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Resets at midnight',
                            style: AppTypography.caption,
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      maxBlastForce: 20,
                      minBlastForce: 8,
                      numberOfParticles: 30,
                      colors: const [
                        AppColors.primary,
                        AppColors.accent,
                        AppColors.success,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerPlaceholder(height: 280, width: 280, borderRadius: 140),
                  const SizedBox(height: 24),
                  Text('Loading prizes...', style: AppTypography.bodySmall),
                ],
              ),
            ),
            error: (e, st) {
              debugPrint('Spin prizes API error: $e');
              return _buildErrorState('Could not load spin prizes: $e', ref);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int spinsLeft) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
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
          Text('Spin & Win', style: AppTypography.headlineLarge),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '$spinsLeft left',
              style: AppTypography.labelMedium.copyWith(
                color: spinsLeft > 0
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildWheel(List<_WheelSegment> prizes) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            painter: _WheelPainter(
              segments: prizes,
              rotation: _currentAngle,
            ),
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Icon(
            _isSpinning
                ? Icons.hourglass_top_rounded
                : Icons.play_arrow_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        Positioned(
          top: 0,
          child: Icon(Icons.arrow_drop_down_rounded,
              size: 40, color: AppColors.textPrimary),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Common', 'Rare', 'Epic', 'Legendary'].map((r) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _rarityColor(r).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _rarityColor(r).withValues(alpha: 0.2)),
              ),
              child: Text(
                r,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _rarityColor(r)),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildErrorState(String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.error),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                ref.invalidate(apiSpinPrizesProvider);
              },
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Go Back',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Simple segment data ───
class _WheelSegment {
  final String label;
  final double originalValue; // Raw value from API (e.g. 1.5 for multiplier)
  final int displayValue; // Rounded for display on wheel
  const _WheelSegment({
    required this.label,
    required this.originalValue,
    required this.displayValue,
  });
}

class _WheelPainter extends CustomPainter {
  final List<_WheelSegment> segments;
  final double rotation;

  _WheelPainter({required this.segments, required this.rotation});

  static const _segmentColors = [
    Color(0xFF6D5DD3),
    Color(0xFF1E1B4B),
    Color(0xFF7C3AED),
    Color(0xFF1F1847),
    Color(0xFF8B7CF6),
    Color(0xFF262050),
    Color(0xFFA78BFA),
    Color(0xFF312A5E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation);

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = _segmentColors[i % _segmentColors.length];

      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      canvas.save();
      canvas.rotate(startAngle + segmentAngle / 2 + pi / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -radius * 0.65));
      canvas.restore();
    }

    canvas.restore();

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      rotation != oldDelegate.rotation;
}
