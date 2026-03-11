import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compactFormat = NumberFormat.compact();
  static final _numberFormat = NumberFormat('#,###');

  static String currency(double value) => _currencyFormat.format(value);
  static String compact(num value) => _compactFormat.format(value);
  static String number(num value) => _numberFormat.format(value);

  static String coins(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  static String duration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }

  static String timerMinSec(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String percentage(double value) => '${value.toStringAsFixed(0)}%';

  static String multiplier(double value) => '${value.toStringAsFixed(1)}x';

  static String streakDays(int days) => '$days day${days == 1 ? '' : 's'}';
}
