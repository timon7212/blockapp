import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../shared/providers/app_providers.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/typography/app_typography.dart';
import '../../design_system/widgets/primary_button.dart';
import '../../design_system/widgets/coin_badge.dart';
import '../../core/constants/economy_constants.dart';
import '../../models/wallet_model.dart';
import '../../models/user_model.dart';
import '../../services/exercise_detection_service.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final int _targetReps;
  late final ExerciseType _exerciseType;

  int _currentReps = 0;
  bool _completed = false;
  late AnimationController _pulseController;

  bool _cameraAvailable = false;
  CameraController? _cameraController;
  ExerciseDetectionService? _detectionService;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProvider);
    _targetReps = user.exerciseDifficulty;
    _exerciseType = user.preferredExercise;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      _detectionService = ExerciseDetectionService(
        exerciseType: _exerciseType,
      );

      _cameraController = controller;

      await controller.startImageStream((image) {
        _processCameraFrame(image, frontCamera);
      });

      setState(() {
        _cameraAvailable = true;
      });
    } catch (_) {
      // Camera not available — fall back to tap mode silently
    }
  }

  Future<void> _processCameraFrame(
    CameraImage img,
    CameraDescription camera,
  ) async {
    if (_isProcessingFrame || _completed || _detectionService == null) return;
    _isProcessingFrame = true;

    try {
      final bytes = img.planes[0].bytes;

      final image = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(img.width.toDouble(), img.height.toDouble()),
          rotation: _getRotation(camera.sensorOrientation),
          format: InputImageFormat.nv21,
          bytesPerRow: img.planes[0].bytesPerRow,
        ),
      );

      final reps = await _detectionService!.processFrame(image);

      if (!mounted) return;

      if (reps != _currentReps) {
        HapticFeedback.lightImpact();
        _pulseController.reverse().then((_) => _pulseController.forward());

        setState(() {
          _currentReps = reps;
          if (_currentReps >= _targetReps) {
            _completed = true;
            HapticFeedback.heavyImpact();
            _stopCamera();
            _awardCoins();
          }
        });
      }
    } catch (_) {
      // Skip frame on error
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImageRotation _getRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void _stopCamera() {
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
  }

  void _onTap() {
    if (_completed || _cameraAvailable) return;
    HapticFeedback.lightImpact();
    _pulseController.reverse().then((_) => _pulseController.forward());

    setState(() {
      _currentReps++;
      if (_currentReps >= _targetReps) {
        _completed = true;
        HapticFeedback.heavyImpact();
        _awardCoins();
      }
    });
  }

  void _awardCoins() {
    ref.read(walletProvider.notifier).addCoins(
      EconomyConstants.exerciseUnlockReward,
      'Exercise unlock',
      TransactionType.exerciseUnlock,
    );
    ref.read(dailyStatsProvider.notifier).recordExercise(
      _targetReps,
      EconomyConstants.exerciseUnlockReward,
    );
  }

  @override
  void dispose() {
    _stopCamera();
    _cameraController?.dispose();
    _detectionService?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentReps / _targetReps;

    if (_cameraAvailable && _cameraController != null) {
      return _buildCameraMode(progress);
    }
    return _buildTapMode(progress);
  }

  // ─── Camera Mode ───

  Widget _buildCameraMode(double progress) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.2, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildCameraTopBar(),
                const Spacer(),
                ScaleTransition(
                  scale: _pulseController,
                  child: _buildProgressRing(progress),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_currentReps / $_targetReps',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (!_completed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_exerciseType.emoji} ${_exerciseType.label}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                if (_completed) _buildCelebration(cameraMode: true),
                const Spacer(),
                if (_completed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PrimaryButton(
                      label: 'Done',
                      color: AppColors.green,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_exerciseType.emoji} ${_exerciseType.label}',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ─── Tap Mode ───

  Widget _buildTapMode(double progress) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            Text(
              '${_exerciseType.label} ${_exerciseType.emoji}',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _onTap,
              child: ScaleTransition(
                scale: _pulseController,
                child: _buildProgressRing(progress),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_currentReps / $_targetReps',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (!_completed)
              Text(
                'Tap to simulate rep',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            if (_completed) _buildCelebration(),
            const Spacer(),
            if (_completed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  label: 'Done',
                  color: AppColors.green,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ─── Shared Widgets ───

  Widget _buildProgressRing(double progress) {
    final isCam = _cameraAvailable;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _RingPainter(
              progress: progress,
              trackColor:
                  isCam ? Colors.white24 : AppColors.borderLight,
              progressColor:
                  _completed ? AppColors.green : AppColors.primary,
              strokeWidth: 10,
            ),
          ),
          Text(
            '$_currentReps',
            style: AppTypography.repCount.copyWith(
              color: _completed
                  ? AppColors.green
                  : isCam
                      ? Colors.white
                      : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebration({bool cameraMode = false}) {
    final textColor = cameraMode ? Colors.white : AppColors.green;

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('🎉', style: TextStyle(fontSize: 48))
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 12),
        Text(
          'Great job!',
          style: AppTypography.headlineLarge.copyWith(color: textColor),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        CoinBadge(
          amount: EconomyConstants.exerciseUnlockReward,
          showPlus: true,
          fontSize: 20,
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 6),
        Text(
          'Apps unlocked for 15 minutes',
          style: AppTypography.bodyMedium.copyWith(
            color: cameraMode ? Colors.white70 : null,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor;
}
