import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/wallet_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EarnScreen extends ConsumerWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _Header(coins: ref.watch(walletProvider).totalCoins),
              const SizedBox(height: 20),
              const _SpinWheelSection(),
              const SizedBox(height: 28),
              _EarnMoreSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int coins;
  const _Header({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text('Earn', style: AppTypography.displaySmall),
          const Spacer(),
          CoinBadge(amount: coins),
        ],
      ),
    );
  }
}

class _SpinWheelSection extends ConsumerStatefulWidget {
  const _SpinWheelSection();

  @override
  ConsumerState<_SpinWheelSection> createState() => _SpinWheelSectionState();
}

class _SpinWheelSectionState extends ConsumerState<_SpinWheelSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  bool _spinning = false;
  SpinWheelPrize? _resultPrize;
  bool _showResult = false;

  static const _prizes = EconomyConstants.spinWheelPrizes;
  static const _segmentColors = [
    Color(0xFFFF6B6B),
    Color(0xFF34C759),
    Color(0xFFFFB800),
    Color(0xFF5856D6),
    Color(0xFF5AC8FA),
    Color(0xFFFF9500),
    Color(0xFF007AFF),
    Color(0xFFFF2D55),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _rotation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    final remaining = ref.read(spinsRemainingProvider);
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('No spins left today — come back tomorrow!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('📺 Watching ad...'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 1),
    ));

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _performSpin();
    });
  }

  void _performSpin() {
    final rng = Random();
    final resultIndex = rng.nextInt(_prizes.length);
    final result = _prizes[resultIndex];
    final segmentAngle = (2 * pi) / _prizes.length;
    final targetAngle = -resultIndex * segmentAngle - segmentAngle / 2;
    final fullSpins = 5 + rng.nextInt(3);
    final endAngle = fullSpins * 2 * pi + targetAngle;

    setState(() {
      _spinning = true;
      _showResult = false;
      _resultPrize = result;
    });

    _controller.reset();
    _rotation = Tween<double>(begin: 0, end: endAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward().then((_) {
      HapticFeedback.heavyImpact();
      ref.read(spinsRemainingProvider.notifier).state--;

      switch (result.type) {
        case SpinPrizeType.coins:
          ref.read(walletProvider.notifier).addCoins(
            result.value,
            'Spin wheel',
            TransactionType.spinWheel,
          );
          break;
        case SpinPrizeType.unlockTime:
        case SpinPrizeType.multiplier:
          break;
      }

      setState(() {
        _spinning = false;
        _showResult = true;
      });
    });
  }

  String _prizeDescription(SpinWheelPrize prize) {
    switch (prize.type) {
      case SpinPrizeType.coins:
        return '+${prize.value} coins!';
      case SpinPrizeType.unlockTime:
        return '+${prize.value} min unlock!';
      case SpinPrizeType.multiplier:
        return 'x${prize.value} earnings boost!';
    }
  }

  IconData _prizeIcon(SpinPrizeType type) {
    switch (type) {
      case SpinPrizeType.coins:
        return Icons.monetization_on_rounded;
      case SpinPrizeType.unlockTime:
        return Icons.timer_rounded;
      case SpinPrizeType.multiplier:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spinsRemaining = ref.watch(spinsRemainingProvider);
    final canSpin = spinsRemaining > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C2E), Color(0xFF2D1B4E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5856D6).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Text(
                  'Spin & Win',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$spinsRemaining/${EconomyConstants.maxSpinsPerDay} spins left today',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              width: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _rotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotation.value,
                        child: child,
                      );
                    },
                    child: CustomPaint(
                      size: const Size(250, 250),
                      painter: _WheelPainter(
                        prizes: _prizes,
                        colors: _segmentColors,
                      ),
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.coinGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coin.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('V', style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      )),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: const Size(24, 20),
                      painter: _PointerPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_showResult && _resultPrize != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Icon(_prizeIcon(_resultPrize!.type), color: AppColors.coin, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      _prizeDescription(_resultPrize!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                  ),
            if (_showResult) const SizedBox(height: 16),
            GestureDetector(
              onTap: _spin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: canSpin && !_spinning
                      ? const LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF9500)],
                        )
                      : null,
                  color: canSpin && !_spinning ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _spinning
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              canSpin ? Icons.play_arrow_rounded : Icons.timer_outlined,
                              color: canSpin ? Colors.white : Colors.white54,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              canSpin
                                  ? 'Watch Ad & Spin'
                                  : 'No Spins Left Today',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: canSpin ? Colors.white : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<SpinWheelPrize> prizes;
  final List<Color> colors;

  _WheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / prizes.length;

    final outerRing = Paint()
      ..color = const Color(0xFFFFB800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, outerRing);

    final innerRadius = radius - 4;

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -pi / 2 + i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -pi / 2 + i * segmentAngle,
        segmentAngle,
        true,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final prize = prizes[i];
      final textAngle = -pi / 2 + i * segmentAngle + segmentAngle / 2;
      final textRadius = innerRadius * 0.62;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      String displayText;
      switch (prize.type) {
        case SpinPrizeType.coins:
          displayText = '🪙${prize.value}';
          break;
        case SpinPrizeType.unlockTime:
          displayText = '⏱️+${prize.value}m';
          break;
        case SpinPrizeType.multiplier:
          displayText = '⚡x${prize.value}';
          break;
      }

      final tp = TextPainter(
        text: TextSpan(
          text: displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    final dotCount = prizes.length * 3;
    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i;
      final dotX = center.dx + (radius - 2) * cos(angle);
      final dotY = center.dy + (radius - 2) * sin(angle);
      canvas.drawCircle(
        Offset(dotX, dotY),
        2.5,
        Paint()..color = i % 2 == 0 ? Colors.white : const Color(0xFFFFB800),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFB800));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EarnMoreSection extends StatelessWidget {
  static const _items = [
    _EarnItem('📋', 'Tasks', 'Complete tasks, earn coins', '10–100'),
    _EarnItem('📊', 'Surveys', 'Share opinions for coins', '30–200'),
    _EarnItem('🎮', 'Games', 'Play & earn rewards', '5–50'),
    _EarnItem('🎁', 'Offerwall', 'Discover offers & deals', '50–500'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Earn More', style: AppTypography.headlineMedium),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) => _EarnCard(item: _items[i]),
          ),
        ),
      ],
    );
  }
}

class _EarnItem {
  final String emoji;
  final String title;
  final String subtitle;
  final String rewardRange;
  const _EarnItem(this.emoji, this.title, this.subtitle, this.rewardRange);
}

class _EarnCard extends StatelessWidget {
  final _EarnItem item;
  const _EarnCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${item.title} — Coming Soon!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(item.title, style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.coinLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      gradient: AppColors.coinGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('V', style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.rewardRange,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.coin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
