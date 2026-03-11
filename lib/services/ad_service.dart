import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static bool get isRewardedAdReady => _rewardedAd != null;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();
  }

  static Future<void> _loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: ${error.message}');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) async {
    if (_rewardedAd == null) {
      onFailed?.call();
      await _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        onFailed?.call();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        onRewarded();
      },
    );
  }

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
