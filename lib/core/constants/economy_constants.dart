class EconomyConstants {
  EconomyConstants._();

  static const int pointsPerMinute = 100;
  static const int maxPendingPoints = 2000;
  static const int maxAccumulationMinutes = 20;

  static const int giftCardMinBalance = 5000;
  static const int cashOutMinBalance = 10000;

  static const int maxSpinsPerDay = 4;

  static const List<SpinWheelPrize> spinWheelPrizes = [
    SpinWheelPrize(label: '10', value: 10, weight: 25),
    SpinWheelPrize(label: '25', value: 25, weight: 22),
    SpinWheelPrize(label: '50', value: 50, weight: 20),
    SpinWheelPrize(label: '100', value: 100, weight: 15),
    SpinWheelPrize(label: '250', value: 250, weight: 10),
    SpinWheelPrize(label: '500', value: 500, weight: 5),
    SpinWheelPrize(label: '1000', value: 1000, weight: 2),
    SpinWheelPrize(label: '5000', value: 5000, weight: 1),
  ];
}

class SpinWheelPrize {
  final String label;
  final int value;
  final int weight;
  const SpinWheelPrize({
    required this.label,
    required this.value,
    required this.weight,
  });
}
