class EconomyConstants {
  EconomyConstants._();

  static const int exerciseUnlockReward = 50;
  static const int adUnlockReward = 100;
  static const int dailyMissionBonus = 200;
  static const int spinWheelMinReward = 10;
  static const int spinWheelMaxReward = 500;
  static const int streakShieldAdCost = 3;

  static const int giftCardMinBalance = 5000;
  static const int cashOutMinBalance = 10000;

  static const int maxSpinsPerDay = 5;

  static const List<int> spinWheelRewards = [10, 25, 50, 100, 25, 50, 10, 500];

  static const List<SpinWheelPrize> spinWheelPrizes = [
    SpinWheelPrize(label: '10', type: SpinPrizeType.coins, value: 10),
    SpinWheelPrize(label: '+15 min', type: SpinPrizeType.unlockTime, value: 15),
    SpinWheelPrize(label: '50', type: SpinPrizeType.coins, value: 50),
    SpinWheelPrize(label: 'x2', type: SpinPrizeType.multiplier, value: 2),
    SpinWheelPrize(label: '25', type: SpinPrizeType.coins, value: 25),
    SpinWheelPrize(label: '+15 min', type: SpinPrizeType.unlockTime, value: 15),
    SpinWheelPrize(label: '100', type: SpinPrizeType.coins, value: 100),
    SpinWheelPrize(label: '500', type: SpinPrizeType.coins, value: 500),
  ];
}

enum SpinPrizeType { coins, unlockTime, multiplier }

class SpinWheelPrize {
  final String label;
  final SpinPrizeType type;
  final int value;
  const SpinWheelPrize({required this.label, required this.type, required this.value});
}
