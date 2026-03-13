import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/gradient_background.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/result_sheet.dart';
import '../../design_system/widgets/app_toast.dart';
import '../../core/constants/economy_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_model.dart';
import '../../services/ad_service.dart';
import '../../services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin() async {
    final spinsLeft = ref.read(spinsRemainingProvider);
    if (spinsLeft <= 0 || _isSpinning) return;

    HapticFeedback.mediumImpact();

    bool adCompleted = false;
    if (mounted) {
      AppToast.show(context, message: 'Loading ad...', type: ToastType.info);
    }
    await AdService.showRewardedAd(
      onRewarded: () => adCompleted = true,
      onFailed: () {
        if (mounted) AppToast.show(context, message: 'Ad failed to load. Try again.', type: ToastType.error);
      },
    );
    if (!adCompleted || !mounted) return;

    HapticFeedback.heavyImpact();
    setState(() => _isSpinning = true);

    final result = generateWeightedSpinResult();
    final prizeIndex = EconomyConstants.spinWheelPrizes.indexWhere((p) => p.value == result);
    final segmentAngle = 2 * pi / EconomyConstants.spinWheelPrizes.length;
    final targetAngle = _currentAngle + (2 * pi * 5) + (segmentAngle * prizeIndex) + (segmentAngle / 2);

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
      setState(() => _isSpinning = false);

      ref.read(spinsRemainingProvider.notifier).state = spinsLeft - 1;
      ref.read(walletProvider.notifier).addPoints(result, 'Spin Wheel win', TransactionType.spinWheel);

      HapticFeedback.heavyImpact();
      if (result >= 250) _confettiController.play();

      _showResult(result);
    });
  }

  void _showResult(int points) {
    ResultSheet.show(
      context,
      icon: points >= 500 ? Icons.auto_awesome_rounded : Icons.stars_rounded,
      iconColor: points >= 500 ? AppColors.primary : AppColors.success,
      title: points >= 500 ? 'Incredible!' : 'Nice Spin!',
      subtitle: 'Added to your balance',
      valueWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '+${Formatters.number(points)}',
            style: AppTypography.number.copyWith(fontSize: 36),
          ),
          const SizedBox(width: 6),
          Text('pts', style: AppTypography.bodyMedium),
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
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = StorageService.lastSpinDate;
    if (lastDate != today) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(spinsRemainingProvider.notifier).state = EconomyConstants.maxSpinsPerDay;
        StorageService.setLastSpinDate(today);
      });
    }

    final spinsLeft = ref.watch(spinsRemainingProvider);
    const prizes = EconomyConstants.spinWheelPrizes;

    final rarities = <String>{};
    for (final p in prizes) {
      rarities.add(_rarity(p.value));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
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
                            child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Spin & Win', style: AppTypography.headlineLarge),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '$spinsLeft left',
                            style: AppTypography.labelMedium.copyWith(
                              color: spinsLeft > 0 ? AppColors.textPrimary : AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _WheelPainter(
                            prizes: prizes,
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
                          _isSpinning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Icon(Icons.arrow_drop_down_rounded, size: 40, color: AppColors.textPrimary),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Common', 'Rare', 'Epic', 'Legendary'].map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _rarityColor(r).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _rarityColor(r).withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _rarityColor(r)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: PrimaryButton(
                      label: spinsLeft > 0 ? 'SPIN' : 'No Spins Left',
                      enabled: spinsLeft > 0 && !_isSpinning,
                      gradient: AppColors.primaryGradient,
                      icon: Icons.casino_rounded,
                      onPressed: _spin,
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
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<SpinWheelPrize> prizes;
  final double rotation;

  _WheelPainter({required this.prizes, required this.rotation});

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
    final segmentAngle = 2 * pi / prizes.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation);

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()..color = _segmentColors[i % _segmentColors.length];

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
          text: prizes[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -radius * 0.65));
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
