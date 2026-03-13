import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String number(num value) => NumberFormat('#,##0').format(value);

  static String compact(num value) => NumberFormat.compact().format(value);

  static String fiatValue(double value) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  static String points(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}K';
    return number(value);
  }

  static String duration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }

  static String timeMinSec(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
