import 'package:intl/intl.dart';

class TTTimeFormatter {
  static String format(DateTime? dateTime) {
    if (dateTime == null) return '---';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Формат часу (наприклад, 18:30)
    final timeFormat = DateFormat('HH:mm');
    final timeStr = timeFormat.format(dateTime);

    if (dateToCheck == today) {
      return 'Сьогодні в $timeStr';
    } else if (dateToCheck == yesterday) {
      return 'Вчора в $timeStr';
    } else if (dateTime.year == now.year) {
      // Якщо поточний рік: "24 травня, 14:00"
      final dateFormat = DateFormat('d MMMM, HH:mm', 'uk_UA');
      return dateFormat.format(dateTime);
    } else {
      // Якщо минулі роки: "24.05.2025, 14:00"
      final dateFormat = DateFormat('dd.MM.yyyy, HH:mm', 'uk_UA');
      return dateFormat.format(dateTime);
    }
  }
}