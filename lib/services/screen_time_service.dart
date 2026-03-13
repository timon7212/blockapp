import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/economy_constants.dart';
import '../models/screen_time_model.dart';

class ScreenTimeService {
  Timer? _timer;
  final ValueNotifier<ScreenTimeModel> state = ValueNotifier(
    const ScreenTimeModel(),
  );

  void startTracking() {
    if (_timer != null) return;
    state.value = state.value.copyWith(
      lastTrackingStart: DateTime.now(),
    );
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tick();
    });
    debugPrint('[ScreenTimeService] Tracking started');
  }

  void _tick() {
    final current = state.value;
    if (current.isCapped) return;

    final newMinutes = current.accumulatedMinutes + 1;
    final newPoints = newMinutes * EconomyConstants.pointsPerMinute;
    final capped = newMinutes >= EconomyConstants.maxAccumulationMinutes;

    state.value = current.copyWith(
      accumulatedMinutes: newMinutes,
      accumulatedPoints: newPoints,
      isCapped: capped,
    );
  }

  void simulateAccumulation(int minutes) {
    final clamped = minutes.clamp(0, EconomyConstants.maxAccumulationMinutes);
    state.value = ScreenTimeModel(
      accumulatedMinutes: clamped,
      accumulatedPoints: clamped * EconomyConstants.pointsPerMinute,
      isCapped: clamped >= EconomyConstants.maxAccumulationMinutes,
      lastTrackingStart: DateTime.now().subtract(Duration(minutes: clamped)),
    );
  }

  int claim() {
    final points = state.value.accumulatedPoints;
    state.value = ScreenTimeModel(
      accumulatedMinutes: 0,
      accumulatedPoints: 0,
      isCapped: false,
      lastClaimTime: DateTime.now(),
    );
    return points;
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopTracking();
    state.dispose();
  }
}
