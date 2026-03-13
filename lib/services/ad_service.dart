import 'package:flutter/foundation.dart';

class AdService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initialized = true;
    debugPrint('[AdService] Initialized (mock mode)');
  }

  static Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) async {
    debugPrint('[AdService] Showing rewarded ad (mock)...');
    await Future.delayed(const Duration(milliseconds: 800));
    onRewarded();
    onDismissed?.call();
    return true;
  }

  static bool get isReady => _initialized;

  static void dispose() {
    _initialized = false;
  }
}
